{%- set yaml_metadata -%}
source_model: h_order
src_pk: ORDER_HK
src_ldts: LOAD_DATE
as_of_dates_table: as_of_date
bridge_walk:
  ORDER_CUSTOMER:
    bridge_link_pk: CUSTOMER__ORDER_HK
    bridge_end_date: EFF_S_CUSTOMER__ORDER_ENDDATE
    bridge_load_date: EFF_S_CUSTOMER__ORDER_LOADDATE
    link_table: l_customer__order
    link_pk: CUSTOMER__ORDER_HK
    link_fk1: ORDER_HK
    link_fk2: CUSTOMER_HK
    eff_sat_table: eff_s_customer__order
    eff_sat_pk: CUSTOMER__ORDER_HK
    eff_sat_end_date: END_DATE
    eff_sat_load_date: LOAD_DATE
  CUSTOMER__NATION:
    bridge_link_pk: CUSTOMER__NATION_HK
    bridge_end_date: EFF_S_CUSTOMER__NATION_ENDDATE
    bridge_load_date: EFF_S_CUSTOMER__NATION_LOADDATE
    link_table: l_customer__nation
    link_pk: CUSTOMER__NATION_HK
    link_fk1: CUSTOMER_HK
    link_fk2: NATION_HK
    eff_sat_table: eff_s_customer__nation
    eff_sat_pk: CUSTOMER__NATION_HK
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