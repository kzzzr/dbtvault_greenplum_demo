{%- set yaml_metadata -%}
source_model: 'raw_orders'
derived_columns:
  CUSTOMER_KEY: 'CUSTOMERKEY'
  NATION_KEY: 'CUSTOMER_NATION_KEY'
  REGION_KEY: 'CUSTOMER_REGION_KEY'
  RECORD_SOURCE: '!TPCH-ORDERS'
  EFFECTIVE_FROM: 'ORDERDATE'
  START_DATE: 'ORDERDATE'
  END_DATE: "TO_DATE('9999/12/31', 'yyyy/mm/dd')"
hashed_columns:
  CUSTOMER_HK: 'CUSTOMERKEY'
  CUSTOMER__NATION_HK:
    - 'CUSTOMERKEY'
    - 'CUSTOMER_NATION_KEY'
  NATION_HK: 'CUSTOMER_NATION_KEY'
  REGION_HK: 'CUSTOMER_REGION_KEY'
  NATION__REGION_HK:
    - 'CUSTOMER_NATION_KEY'
    - 'CUSTOMER_REGION_KEY'
  ORDER_HK: 'ORDERKEY'
  CUSTOMER__ORDER_HK:
    - 'CUSTOMERKEY'
    - 'ORDERKEY'
  LINEITEM_HK: 
    - 'LINENUMBER'
    - 'ORDERKEY'
  ORDER__LINEITEM_HK:
    - 'ORDERKEY'
    - 'LINENUMBER'
  PART_HK: 'PARTKEY'
  SUPPLIER_HK: 'SUPPLIERKEY'
  INVENTORY_HK:
    - 'PARTKEY'
    - 'SUPPLIERKEY'
  INVENTORY__ALLOCATION_HK:
    - 'LINENUMBER'
    - 'PARTKEY'
    - 'SUPPLIERKEY'
  CUSTOMER_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CUSTOMERKEY'
      - 'CUSTOMER_NAME'
      - 'CUSTOMER_ADDRESS'
      - 'CUSTOMER_PHONE'
      - 'CUSTOMER_ACCBAL'
      - 'CUSTOMER_MKTSEGMENT'
      - 'CUSTOMER_COMMENT'
  CUSTOMER__NATION_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CUSTOMER_NATION_NAME'
      - 'CUSTOMER_NATION_COMMENT'
      - 'CUSTOMER_NATION_KEY'
  CUSTOMER__REGION_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CUSTOMER_REGION_NAME'
      - 'CUSTOMER_REGION_COMMENT'
      - 'CUSTOMER_REGION_KEY'
  LINEITEM_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ORDERKEY'
      - 'LINENUMBER'
      - 'COMMITDATE'
      - 'DISCOUNT'
      - 'EXTENDEDPRICE'
      - 'LINESTATUS'
      - 'LINE_COMMENT'
      - 'QUANTITY'
      - 'RECEIPTDATE'
      - 'RETURNFLAG'
      - 'SHIPDATE'
      - 'SHIPINSTRUCT'
      - 'SHIPMODE'
      - 'TAX'
  ORDER_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ORDERKEY'
      - 'CLERK'
      - 'ORDERDATE'
      - 'ORDERPRIORITY'
      - 'ORDERSTATUS'
      - 'ORDER_COMMENT'
      - 'SHIPPRIORITY'
      - 'TOTALPRICE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{% set source_model = metadata_dict['source_model'] %}

{% set derived_columns = metadata_dict['derived_columns'] %}

{% set hashed_columns = metadata_dict['hashed_columns'] %}

WITH staging AS (
{{ automate_dv.stage(include_source_columns=true,
                  source_model=source_model,
                  derived_columns=derived_columns,
                  hashed_columns=hashed_columns,
                  ranked_columns=none) }}
)

SELECT *,
       ('{{ var('load_date') }}')::DATE AS LOAD_DATE
FROM staging
