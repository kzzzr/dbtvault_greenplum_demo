{{ config(materialized='pit_incremental') }}

{%- set yaml_metadata -%}
source_model: hub_supplier
src_pk: supplier_pk
as_of_dates_table: as_of_date
satellites: 
  sat_inv_supp_nation_details:
    pk:
      PK: supplier_pk
    ldts:
      LDTS: load_date
  sat_inv_supp_region_details:
    pk:
      PK: supplier_pk
    ldts:
      LDTS: load_date
  sat_inv_supplier_details:
    pk:
      PK: supplier_pk
    ldts:
      LDTS: load_date
src_ldts: load_date
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{% set source_model = metadata_dict['source_model'] %}
{% set src_pk = metadata_dict['src_pk'] %}
{% set as_of_dates_table = metadata_dict['as_of_dates_table'] %}
{% set satellites = metadata_dict['satellites'] %}
{% set src_ldts = metadata_dict['src_ldts'] %}

{{ automate_dv.pit(source_model=source_model, src_pk=src_pk,
                   as_of_dates_table=as_of_dates_table,
                   satellites=satellites,
                   stage_tables_ldts=stage_tables_ldts,
                   src_ldts=src_ldts) }}