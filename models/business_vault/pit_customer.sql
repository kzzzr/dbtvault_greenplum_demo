{{ config(materialized='pit_incremental') }}

{%- set source_model = "hub_customer" -%}
{%- set src_pk = "CUSTOMER_PK" -%}
{%- set src_ldts = "LOAD_DATE" -%}
{%- set as_of_dates_table = "as_of_dates_table" -%}
{%- set satellites = "sat_order_customer_details" -%}

{%- set yaml_metadata -%}
source_model: hub_customer
src_pk: CUSTOMER_PK
as_of_dates_table: as_of_dates_table
satellites: 
  sat_order_customer_details:
    pk:
      PK: CUSTOMER_PK
    ldts:
      LDTS: LOAD_DATE
src_ldts: LOAD_DATE
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{% set source_model = metadata_dict['source_model'] %}
{% set src_pk = metadata_dict['src_pk'] %}
{% set as_of_dates_table = metadata_dict['as_of_dates_table'] %}
{% set satellites = metadata_dict['satellites'] %}
{% set stage_tables_ldts = metadata_dict['stage_tables_ldts'] %}
{% set src_ldts = metadata_dict['src_ldts'] %}

{{ automate_dv.pit(source_model=source_model, src_pk=src_pk,
                   as_of_dates_table=as_of_dates_table,
                   satellites=satellites,
                   src_ldts=src_ldts) }}