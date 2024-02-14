{{ config(materialized="bridge_incremental") }}

{%- set yaml_metadata -%}
source_model: hub_supplier
src_pk: SUPPLIER_PK
src_ldts: LOAD_DATE
as_of_dates_table: as_of_date_table
bridge_walk:
  sat_inv_supplier_details:
    bridge_link_pk: BR_SUPPLIER_PK
    bridge_end_date: BR_EFFECTIVE_FROM
    bridge_load_date: LOAD_DATE
    link_table: link_supplier_nation
    link_pk: SUPPLIER_PK
    link_fk1: SUPPLIER_PK
    link_fk2: NATION_PK
    eff_sat_table: pit_supplier
    eff_sat_pk: SUPPLIER_PK
    eff_sat_end_date: as_of_date
    eff_sat_load_date: sat_inv_supp_nation_details_ldts
stage_tables_ldts:
  v_stg_inventory: LOAD_DATE
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