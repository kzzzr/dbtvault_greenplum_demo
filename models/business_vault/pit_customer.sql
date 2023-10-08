{%- set yaml_metadata -%}
source_model: h_customer
src_pk: CUSTOMER_HK
as_of_dates_table: as_of_date
satellites: 
  s_customer__customer_details:
    pk:
      PK: CUSTOMER_HK
    ldts:
      LDTS: LOAD_DATE
  s_customer__nation_details:
    pk:
      PK: CUSTOMER_HK
    ldts:
      LDTS: LOAD_DATE
  s_customer__region_details:
    pk:
      PK: CUSTOMER_HK
    ldts:
      LDTS: LOAD_DATE
stage_tables: 
  v_stg_orders: LOAD_DATE 
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
                   stage_tables_ldts=stage_tables_ldts,
                   src_ldts=src_ldts) }}