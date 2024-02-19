{{ config(materialized="bridge_incremental") }}

{%- set yaml_metadata -%}
source_model: hub_customer
src_pk: CUSTOMER_PK
src_ldts: LOAD_DATE
as_of_dates_table: as_of_date
bridge_walk:
  CUSTOMER_NATION:
    bridge_link_pk: LINK_CUSTOMER_NATION_PK
    bridge_end_date: EFF_SAT_CUSTOMER_NATION_ENDDATE
    bridge_load_date: EFF_SAT_CUSTOMER_NATION_LOADDATE
    link_table: link_customer_nation
    link_pk: LINK_CUSTOMER_NATION_PK
    link_fk1: CUSTOMER_PK
    link_fk2: NATION_PK
    eff_sat_table: eff_sat_customer_nation
    eff_sat_pk: LINK_CUSTOMER_NATION_PK
    eff_sat_end_date: END_DATE
    eff_sat_load_date: LOAD_DATE
  NATION_REGION:
    bridge_link_pk: LINK_NATION_REGION_PK
    bridge_end_date: EFF_SAT_NATION_REGION_ENDDATE
    bridge_load_date: EFF_SAT_NATION_REGION_LOADDATE
    link_table: link_nation_region
    link_pk: NATION_REGION_PK
    link_fk1: NATION_PK
    link_fk2: REGION_PK
    eff_sat_table: eff_sat_nation_region
    eff_sat_pk: NATION_REGION_PK
    eff_sat_end_date: END_DATE
    eff_sat_load_date: LOAD_DATE
stage_tables_ldts:
  v_stg_orders: LOAD_DATE
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{% set source_model = metadata_dict["source_model"] %}
{% set src_pk = metadata_dict["src_pk"] %}
{% set src_ldts = metadata_dict["src_ldts"] %}
{% set as_of_dates_table = metadata_dict["as_of_dates_table"] %}
{% set bridge_walk = metadata_dict["bridge_walk"] %}
{% set stage_tables_ldts = metadata_dict["stage_tables_ldts"] %}

{{ automate_dv.bridge(source_model=source_model, src_pk=src_pk,
                      src_ldts=src_ldts,
                      bridge_walk=bridge_walk,
                      as_of_dates_table=as_of_dates_table,
                      stage_tables_ldts=stage_tables_ldts) }}
