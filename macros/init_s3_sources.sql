{% macro init_s3_sources() -%}

    {% set sql %}
    
        --------------------------
        -- 1. S3 Object Storage --
        --------------------------

        -- 1.1. customer
        DROP EXTERNAL TABLE IF EXISTS src_customer ;
        CREATE EXTERNAL TABLE src_customer(
                        C_CUSTKEY INT, 
                        C_NAME VARCHAR(25),
                        C_ADDRESS VARCHAR(40),
                        C_NATIONKEY INTEGER,
                        C_PHONE CHAR(15),
                        C_ACCTBAL DECIMAL(15,2),
                        C_MKTSEGMENT CHAR(10),
                        C_COMMENT VARCHAR(117),
                        EXTRA VARCHAR(1)
        )
        LOCATION ('pxf://otus-dwh/tpch-dbgen-1g/customer.tbl?PROFILE=s3:text&accesskey={{ env_var("S3_ACCESSKEY") }}&secretkey={{ env_var("S3_SECRETKEY") }}&endpoint=storage.yandexcloud.net'
        )
        FORMAT 'TEXT' 
        (DELIMITER '|')
        ;
        {{ log('src_customer', info=True)}}

        -- 1.2. supplier
        DROP EXTERNAL TABLE IF EXISTS src_supplier ;
        CREATE EXTERNAL TABLE src_supplier(
            S_SUPPKEY INT,
            S_NAME CHAR(25),
            S_ADDRESS VARCHAR(40),
            S_NATIONKEY INTEGER,
            S_PHONE CHAR(15),
            S_ACCTBAL DECIMAL(15,2),
            S_COMMENT VARCHAR(101),
            EXTRA VARCHAR(1)
        )
        LOCATION ('pxf://otus-dwh/tpch-dbgen-1g/supplier.tbl?PROFILE=s3:text&accesskey={{ env_var("S3_ACCESSKEY") }}&secretkey={{ env_var("S3_SECRETKEY") }}&endpoint=storage.yandexcloud.net'
        )
        FORMAT 'TEXT' 
        (DELIMITER '|')
        ;
        {{ log('src_supplier', info=True)}}

        -- 1.3. part
        DROP EXTERNAL TABLE IF EXISTS src_part ;
        CREATE EXTERNAL TABLE src_part(
            P_PARTKEY INT,
            P_NAME VARCHAR(55),
            P_MFGR CHAR(25),
            P_BRAND CHAR(10),
            P_TYPE VARCHAR(25),
            P_SIZE INTEGER,
            P_CONTAINER CHAR(10),
            P_RETAILPRICE DECIMAL(15,2),
            P_COMMENT VARCHAR(23),
            EXTRA VARCHAR(1)
        )
        LOCATION ('pxf://otus-dwh/tpch-dbgen-1g/part.tbl?PROFILE=s3:text&accesskey={{ env_var("S3_ACCESSKEY") }}&secretkey={{ env_var("S3_SECRETKEY") }}&endpoint=storage.yandexcloud.net'
        )
        FORMAT 'TEXT' 
        (DELIMITER '|')
        ;
        {{ log('src_part', info=True)}}

        -- 1.4. lineorder
        DROP EXTERNAL TABLE IF EXISTS src_lineitem ;
        CREATE EXTERNAL TABLE src_lineitem(
            L_ORDERKEY BIGINT,
            L_PARTKEY INT,
            L_SUPPKEY INT,
            L_LINENUMBER INTEGER,
            L_QUANTITY DECIMAL(15,2),
            L_EXTENDEDPRICE DECIMAL(15,2),
            L_DISCOUNT DECIMAL(15,2),
            L_TAX DECIMAL(15,2),
            L_RETURNFLAG CHAR(1),
            L_LINESTATUS CHAR(1),
            L_SHIPDATE DATE,
            L_COMMITDATE DATE,
            L_RECEIPTDATE DATE,
            L_SHIPINSTRUCT CHAR(25),
            L_SHIPMODE CHAR(10),
            L_COMMENT VARCHAR(44),
            EXTRA VARCHAR(1)
        )
        LOCATION ('pxf://otus-dwh/tpch-dbgen-1g/lineitem.tbl?PROFILE=s3:text&accesskey={{ env_var("S3_ACCESSKEY") }}&secretkey={{ env_var("S3_SECRETKEY") }}&endpoint=storage.yandexcloud.net'
        )
        FORMAT 'TEXT' 
        (DELIMITER '|')
        ;
        {{ log('src_lineitem', info=True)}}

        -- 1.5. nation
        DROP EXTERNAL TABLE IF EXISTS src_nation ;
        CREATE EXTERNAL TABLE src_nation(
            N_NATIONKEY INTEGER, 
            N_NAME CHAR(25), 
            N_REGIONKEY INTEGER, 
            N_COMMENT VARCHAR(152),
            EXTRA VARCHAR(1)
        )
        LOCATION ('pxf://otus-dwh/tpch-dbgen-1g/nation.tbl?PROFILE=s3:text&accesskey={{ env_var("S3_ACCESSKEY") }}&secretkey={{ env_var("S3_SECRETKEY") }}&endpoint=storage.yandexcloud.net'
        )
        FORMAT 'TEXT' 
        (DELIMITER '|')
        ;
        {{ log('src_nation', info=True)}}

        -- 1.6. orders
        DROP EXTERNAL TABLE IF EXISTS src_orders ;
        CREATE EXTERNAL TABLE src_orders(
            O_ORDERKEY BIGINT,
            O_CUSTKEY INT,
            O_ORDERSTATUS CHAR(1),
            O_TOTALPRICE DECIMAL(15,2),
            O_ORDERDATE DATE,
            O_ORDERPRIORITY CHAR(15), 
            O_CLERK  CHAR(15), 
            O_SHIPPRIORITY INTEGER,
            O_COMMENT VARCHAR(79),
            EXTRA VARCHAR(1)
        )
        LOCATION ('pxf://otus-dwh/tpch-dbgen-1g/orders.tbl?PROFILE=s3:text&accesskey={{ env_var("S3_ACCESSKEY") }}&secretkey={{ env_var("S3_SECRETKEY") }}&endpoint=storage.yandexcloud.net'
        )
        FORMAT 'TEXT' 
        (DELIMITER '|')
        ;
        {{ log('src_orders', info=True)}}

        -- 1.7. partsupp
        DROP EXTERNAL TABLE IF EXISTS src_partsupp ;
        CREATE EXTERNAL TABLE src_partsupp(
            PS_PARTKEY INT,
            PS_SUPPKEY INT,
            PS_AVAILQTY INTEGER,
            PS_SUPPLYCOST DECIMAL(15,2),
            PS_COMMENT VARCHAR(199),
            EXTRA VARCHAR(1)
        )
        LOCATION ('pxf://otus-dwh/tpch-dbgen-1g/partsupp.tbl?PROFILE=s3:text&accesskey={{ env_var("S3_ACCESSKEY") }}&secretkey={{ env_var("S3_SECRETKEY") }}&endpoint=storage.yandexcloud.net'
        )
        FORMAT 'TEXT' 
        (DELIMITER '|')
        ;
        {{ log('src_partsupp', info=True)}}

        -- 1.8. region
        DROP EXTERNAL TABLE IF EXISTS src_region ;
        CREATE EXTERNAL TABLE src_region(
            R_REGIONKEY INTEGER, 
            R_NAME CHAR(25),
            R_COMMENT VARCHAR(152),
            EXTRA VARCHAR(1)
        )
        LOCATION ('pxf://otus-dwh/tpch-dbgen-1g/region.tbl?PROFILE=s3:text&accesskey={{ env_var("S3_ACCESSKEY") }}&secretkey={{ env_var("S3_SECRETKEY") }}&endpoint=storage.yandexcloud.net'
        )
        FORMAT 'TEXT' 
        (DELIMITER '|')
        ;
        {{ log('src_region', info=True)}}

    {% endset %}
    
    {% set table = run_query(sql) %}

{%- endmacro %}