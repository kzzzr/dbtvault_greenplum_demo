# 1. Create Greenplum cluster on Yandex.Cloud

**[Data Warehouse Analyst – Analytics Engineer @ OTUS.ru](https://otus.ru/lessons/dwh/)**

Request access to Manged Greenplum Service (beta), than create a cluster.

Configuration I have used:

![](https://habrastorage.org/webt/hu/tf/6s/hutf6sstdjvtxgujcmhchocjpws.png)


# 2. Generate data with DBGen

Spin up a virtual machine, install libs, generate data.

Or just get what I have prepared for you from `s3://otus-dwh/tpch-dbgen/` (Yandex Object Storage)

```bash

ssh -i ~/.ssh/key dbgen@{ip}  # ssh to VM

sudo apt-get install -y gcc git awscli postgresql # install libs

git clone https://github.com/electrum/tpch-dbgen.git # TPCH generator
make makefile.suite

./dbgen -v -h -s 10 # generate data

for i in `ls *.tbl`; do sed 's/|$//' $i > ${i/tbl/csv}; echo $i; done; # convert to a CSV format compatible with PostgreSQL

aws configure # to sync with S3

aws --endpoint-url=https://storage.yandexcloud.net s3 sync . s3://otus-dwh/tpch-dbgen/ \
	--exclude=* \
	--include=*.csv \
	--acl=public-read \
	--dryrun

```

Read more at:
- https://github.com/RunningJon/TPC-H
- https://github.com/wangguoke/blog/blob/master/How%20to%20use%20the%20pg_tpch.md


# 3. COPY to database

First create table definitions.

Then load data into it.


```sql
-- DDL scripts to create table

CREATE TABLE customer
(C_CUSTKEY INT, 
C_NAME VARCHAR(25),
C_ADDRESS VARCHAR(40),
C_NATIONKEY INTEGER,
C_PHONE CHAR(15),
C_ACCTBAL DECIMAL(15,2),
C_MKTSEGMENT CHAR(10),
C_COMMENT VARCHAR(117))
WITH (appendonly=true, orientation=column)
DISTRIBUTED BY (C_CUSTKEY);

CREATE TABLE lineitem
(L_ORDERKEY BIGINT,
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
L_COMMENT VARCHAR(44))
WITH (appendonly=true, orientation=column, compresstype=ZSTD)
DISTRIBUTED BY (L_ORDERKEY,L_LINENUMBER)
PARTITION BY RANGE (L_SHIPDATE)
(start('1992-01-01') INCLUSIVE end ('1998-12-31') INCLUSIVE every (30),
default partition others);

CREATE TABLE nation
(N_NATIONKEY INTEGER, 
N_NAME CHAR(25), 
N_REGIONKEY INTEGER, 
N_COMMENT VARCHAR(152))
WITH (appendonly=true, orientation=column)
DISTRIBUTED BY (N_NATIONKEY);

CREATE TABLE orders
(O_ORDERKEY BIGINT,
O_CUSTKEY INT,
O_ORDERSTATUS CHAR(1),
O_TOTALPRICE DECIMAL(15,2),
O_ORDERDATE DATE,
O_ORDERPRIORITY CHAR(15), 
O_CLERK  CHAR(15), 
O_SHIPPRIORITY INTEGER,
O_COMMENT VARCHAR(79))
WITH (appendonly=true, orientation=column, compresstype=ZSTD)
DISTRIBUTED BY (O_ORDERKEY)
PARTITION BY RANGE (O_ORDERDATE)
(start('1992-01-01') INCLUSIVE end ('1998-12-31') INCLUSIVE every (30),
default partition others);

CREATE TABLE part
(P_PARTKEY INT,
P_NAME VARCHAR(55),
P_MFGR CHAR(25),
P_BRAND CHAR(10),
P_TYPE VARCHAR(25),
P_SIZE INTEGER,
P_CONTAINER CHAR(10),
P_RETAILPRICE DECIMAL(15,2),
P_COMMENT VARCHAR(23))
WITH (appendonly=true, orientation=column)
DISTRIBUTED BY (P_PARTKEY);

CREATE TABLE partsupp
(PS_PARTKEY INT,
PS_SUPPKEY INT,
PS_AVAILQTY INTEGER,
PS_SUPPLYCOST DECIMAL(15,2),
PS_COMMENT VARCHAR(199))
WITH (appendonly=true, orientation=column)
DISTRIBUTED BY (PS_PARTKEY,PS_SUPPKEY);

CREATE TABLE region
(R_REGIONKEY INTEGER, 
R_NAME CHAR(25),
R_COMMENT VARCHAR(152))
WITH (appendonly=true, orientation=column)
DISTRIBUTED BY (R_REGIONKEY);

CREATE TABLE supplier 
(S_SUPPKEY INT,
S_NAME CHAR(25),
S_ADDRESS VARCHAR(40),
S_NATIONKEY INTEGER,
S_PHONE CHAR(15),
S_ACCTBAL DECIMAL(15,2),
S_COMMENT VARCHAR(101))
WITH (appendonly=true, orientation=column)
DISTRIBUTED BY (S_SUPPKEY);
```

On a VM with installed psql execute COPY pointing to local csv files:

```bash
export GREENPLUM_URI="postgres://greenplum:<pass>@<host>:5432/postgres"
psql $GREENPLUM_URI

\copy customer from  '/home/dbgen/tpch-dbgen/data/customer.csv' WITH (FORMAT csv, DELIMITER '|');
\copy lineitem from  '/home/dbgen/tpch-dbgen/data/lineitem.csv' WITH (FORMAT csv, DELIMITER '|');
\copy nation from  '/home/dbgen/tpch-dbgen/data/nation.csv' WITH (FORMAT csv, DELIMITER '|');
\copy orders from  '/home/dbgen/tpch-dbgen/data/orders.csv' WITH (FORMAT csv, DELIMITER '|');
\copy part from  '/home/dbgen/tpch-dbgen/data/part.csv' WITH (FORMAT csv, DELIMITER '|');
\copy partsupp from  '/home/dbgen/tpch-dbgen/data/partsupp.csv' WITH (FORMAT csv, DELIMITER '|');
\copy region from  '/home/dbgen/tpch-dbgen/data/region.csv' WITH (FORMAT csv, DELIMITER '|');
\copy supplier from  '/home/dbgen/tpch-dbgen/data/supplier.csv' WITH (FORMAT csv, DELIMITER '|');
```

# 4. Run dbtVault + Greenplum demo 

**1. First read the official guide:**

[dbtVault worked example](https://dbtvault.readthedocs.io/en/latest/worked_example/we_worked_example/)

**2. Clone repo with dbt project**

Clone demo repo: https://github.com/kzzzr/dbtvault_greenplum_demo

```bash
git clone https://github.com/kzzzr/dbtvault_greenplum_demo.git
```

**3. Configure database connection**

Example `profiles.yml`

```yaml
config:
  send_anonymous_usage_stats: False
  use_colors: True
  partial_parse: True

dbtvault_greenplum_demo:
  outputs:
    dev:
      type: postgres
      threads: 2
      host: {yc-greenplum-host}
      port: 5432
      user: greenplum
      pass: {yc-greenplum-pass}
      dbname: postgres
      schema: public
  target: dev

```

**4. Make sure you run on `dbt==0.19.0`**

You may use repo's Pipfile with pipenv or install dbt yourself

```bash
pipenv install
pipenv shell

dbt debug # check if OK
```

**5. Install dependencies**

Initial repo is intended to run on Snowflake only.

I have forked it and adapted to run on Greenplum/PostgreSQL.
Check out what has been changed: [47e0261cea67c3284ea409c86dacdc31b1175a39](https://github.com/kzzzr/dbtvault/tree/47e0261cea67c3284ea409c86dacdc31b1175a39)

`packages.yml`:

```yaml
packages:
  # - package: Datavault-UK/dbtvault
  #   version: 0.7.3
  - git: "https://github.com/kzzzr/dbtvault.git"
    revision: master
    warn-unpinned: false
```

Install package:

```bash
dbt deps

```

**6. Adapt models to Greenplum/PostgreSQL**

Check out the [commit history](https://github.com/kzzzr/dbtvault_greenplum_demo/commits/master).

* [a97a224](https://github.com/kzzzr/dbtvault_greenplum_demo/commit/a97a22431a182e59c9cb8be807200f0292672b0f) - adapt prepared staging layer for greenplum - Artemiy Kozyr (HEAD -> master, kzzzr/master)
* [dfc5866](https://github.com/kzzzr/dbtvault_greenplum_demo/commit/dfc5866a63e81393f5bfc0b163cc84b56efc6354) - configure raw layer for greenplum - Artemiy Kozyr
* [bba7437](https://github.com/kzzzr/dbtvault_greenplum_demo/commit/bba7437a7d29fd5dd9c383bff49c4604fc84d2ab) - configure data sources for greenplum - Artemiy Kozyr
* [aa25600](https://github.com/kzzzr/dbtvault_greenplum_demo/commit/aa2560071b27b2e7f6de924222b7d465e28d8af2) - configure package (adapted dbt_vault) for greenplum - Artemiy Kozyr
* [eafed95](https://github.com/kzzzr/dbtvault_greenplum_demo/commit/eafed95ad5b912daf9339d877dfa0ee246bd089f) - configure dbt_project.yml for greenplum - Artemiy Kozyr


**7. Run models step-by-step**

Load one day to Data Vault structures:

```bash
dbt run -m tag:raw
dbt run -m tag:stage
dbt run -m tag:hub
dbt run -m tag:link
dbt run -m tag:satellite
dbt run -m tag:t_link
```

**8. Load next day**

Simulate next day load by incrementing `load_date` varible:

```yaml dbt_profiles.yml
# dbt_profiles.yml

vars:
  load_date: '1992-01-08' # increment by one day '1992-01-09'

```
