{{ config(materialized="bridge_incremental") }}

{%- set yaml_metadata -%}
source_model: hub_supplier
src_pk: SUPPLIER_PK
src_ldts: LOAD_DATE
as_of_dates_table: as_of_dates_table
bridge_walk:
  CUSTOMER_ORDER:
    bridge_link_pk: BRIDGE_PK
    <--bridge_end_date: EFF_SAT_CUSTOMER_ORDER_ENDDATE
    bridge_load_date: BRIDGE_LOAD_DATE
    link_table: LINK_INVENTORY
    link_pk: INVENTORY_PK
    link_fk1: SUPPLIER_PK
    link_fk2: PART_PK
    eff_sat_table: sat_inv_supplier_details
    eff_sat_pk: SUPPLIER_PK
    eff_sat_end_date: EFFECTIVE_FROM
    eff_sat_load_date: LOAD_DATE
 /* ORDER_PRODUCT:
    bridge_link_pk: LINK_ORDER_PRODUCT_PK
    bridge_end_date: EFF_SAT_ORDER_PRODUCT_ENDDATE
    bridge_load_date: EFF_SAT_ORDER_PRODUCT_LOADDATE
    link_table: LINK_ORDER_PRODUCT
    link_pk: ORDER_PRODUCT_PK
    link_fk1: ORDER_FK
    link_fk2: PRODUCT_FK
    eff_sat_table: EFF_SAT_ORDER_PRODUCT
    eff_sat_pk: ORDER_PRODUCT_PK
    eff_sat_end_date: END_DATE
    eff_sat_load_date: LOAD_DATETIME --> */
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
