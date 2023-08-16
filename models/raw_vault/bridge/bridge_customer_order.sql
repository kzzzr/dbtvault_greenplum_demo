{{ config(materialized="bridge_incremental") }}

{%- set source_model = "hub_customer" -%}
{%- set src_pk = "CUSTOMER_PK" -%}
{%- set src_ldts = "LOAD_DATE" -%}
{%- set as_of_dates_table = "as_of_date" -%}
{%- set bridge_walk = "CUSTOMER_ORDER" -%}

{%- set yaml_metadata -%}
source_model: hub_customer
src_pk: CUSTOMER_PK
src_ldts: LOAD_DATE
as_of_dates_table: as_of_date
bridge_walk:
  CUSTOMER_ORDER:
    bridge_link_pk: BRIDGE_PK
    bridge_load_date: BRIDGE_LOAD_DATE
    link_table: link_customer_order
    link_pk: ORDER_CUSTOMER_PK
    link_fk1: CUSTOMER_PK
    link_fk2: ORDER_PK
    eff_sat_table: sat_order_customer_details
    eff_sat_pk: customer_pk
    eff_sat_end_date: EFFECTIVE_FROM
    eff_sat_load_date: LOAD_DATE
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{% set source_model = metadata_dict["source_model"] %}
{% set src_pk = metadata_dict["src_pk"] %}
{% set src_ldts = metadata_dict["src_ldts"] %}
{% set as_of_dates_table = metadata_dict["as_of_dates_table"] %}
{% set bridge_walk = metadata_dict["bridge_walk"] %}

{{ automate_dv.bridge(source_model=source_model, src_pk=src_pk,
                      src_ldts=src_ldts,
                      bridge_walk=bridge_walk,
                      as_of_dates_table=as_of_dates_table) }}
