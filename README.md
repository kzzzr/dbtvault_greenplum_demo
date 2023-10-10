# Data Vault powered by dbtVault and Greenplum

- Build Data Vault powered by [dbtVault](https://dbtvault.readthedocs.io/) and [Greenplum](https://greenplum.org/)
- Deploy Infrastructure as Code with [Terraform](https://www.terraform.io/) and [Yandex.Cloud](https://cloud.yandex.com/en-ru/)
- Instant development with [Github Codespaces](https://docs.github.com/en/codespaces)
- Assignment checks with [Github Actions](https://github.com/features/actions)

## Assignment TODO

⚠️ Attention! Always delete resources after you finish your work!

- [ ] [Fork this repository](https://docs.github.com/en/get-started/quickstart/fork-a-repo)
- [ ] [Configure Developer Environment]()
- [ ] [Deploy Infrastructure]()
- [ ] [Check database connection]()
- [ ] [Populate Data Vault day-by-day]()
- [ ] [Build Business Vault on top of Data Vault]()
- [ ] [Create and submit PR]()

## Configure Developer Environment

You have got several options to set up:
 
<details><summary>Start with GitHub Codespaces</summary>
<p>

![GitHub Codespaces](./docs/github_codespaces.png)

</p>
</details>

<details><summary>Use devcontainer (locally)</summary>
<p>

1. Install [Docker](https://docs.docker.com/desktop/#download-and-install) on your local machine.

1. Install devcontainer CLI:

    Open command palette (CMD + SHIFT+ P) type *Install devcontainer CLI*

    ![](./docs/install_devcontainer_cli.png)

1. Next build and open dev container:

    ```bash
    # build dev container
    devcontainer build .

    # open dev container
    devcontainer open .
    ```

</p>
</details>

Verify you are in a development container by running commands:

```bash
terraform -v

yc --version

dbt --version
```

If any of these commands fails printing out used software version then you are probably running it on your local machine not in a dev container!

## Deploy Infrastructure

1. Get familiar with Managed Service for Greenplum

    ![](./docs/managed_greenplum_ui.png)

1. Install and configure `yc` CLI: [Getting started with the command-line interface by Yandex Cloud](https://cloud.yandex.com/en/docs/cli/quickstart#install)

    ```bash
    yc init
    ```

1. Populate `.env` file

    `.env` is used to store secrets as environment variables.

    Copy template file [.env.template](./.env.template) to `.env` file:
    
    ```bash
    cp .env.template .env
    ```

    Open file in editor and set your own values.

    > ❗️ Never commit secrets to git

1. Set environment variables:

    ```bash
    export YC_TOKEN=$(yc iam create-token)
    export YC_CLOUD_ID=$(yc config get cloud-id)
    export YC_FOLDER_ID=$(yc config get folder-id)
    export TF_VAR_folder_id=$(yc config get folder-id)
    export $(xargs <.env)
    ```

1. Deploy using Terraform

    Configure YC Terraform provider:
    
    ```bash
    cp terraformrc ~/.terraformrc
    ```

    ```bash
    terraform init
    terraform validate
    terraform fmt
    terraform plan
    terraform apply
    ```

    Store terraform output values as Environment Variables:

    ```bash
    export DBT_HOST=$(terraform output -raw greenplum_host_fqdn)
    export DBT_USER='greenplum'
    export DBT_PASSWORD=${TF_VAR_greenplum_password}
    export S3_ACCESSKEY=$(terraform output -raw access_key)
    export S3_SECRETKEY=$(terraform output -raw secret_key)
    ```

    [EN] Reference: [Getting started with Terraform by Yandex Cloud](https://cloud.yandex.com/en/docs/tutorials/infrastructure-management/terraform-quickstart)
    
    [RU] Reference: [Начало работы с Terraform by Yandex Cloud](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-quickstart)

1. Alternatively, deploy using yc CLI

    <details><summary>Deploy using yc CLI:</summary>
    <p>

    Checklist:
    - Egress NAT (required to access s3): https://cloud.yandex.com/en/docs/vpc/operations/create-nat-gateway
    - S3 service account keys (required for external tables access): https://cloud.yandex.com/en/docs/iam/operations/sa/create-access-key
    - Greenplum: https://cloud.yandex.com/en/docs/cli/cli-ref/managed-services/managed-greenplum/

    ```bash
    yc managed-greenplum cluster create gp_datavault \
    --network-name default \
    --zone-id ru-central1-a \
    --environment prestable \
    --master-host-count 2 \
    --segment-host-count 2 \
    --master-config resource-id=s3-c2-m8,disk-size=30,disk-type=network-ssd \
    --segment-config resource-id=s3-c2-m8,disk-size=30,disk-type=network-ssd \
    --segment-in-host 1 \
    --user-name greenplum \
    --user-password $TF_VAR_greenplum_password \
    --greenplum-version 6.22 \
    --assign-public-ip

    yc vpc gateway create --name gp-gateway
    yc vpc route-table create --name=gp-route-table --network-name=default --route destination=0.0.0.0/0,gateway-id=<gateway_id>
    yc vpc subnet update <subnet_name> --route-table-name=gp-route-table

    yc managed-greenplum hosts list master --cluster-name gp_datavault

    export DBT_HOST=$DBT_HOST
    export DBT_USER=$DBT_USER
    export DBT_PASSWORD=$TF_VAR_greenplum_password
    export S3_ACCESSKEY=$S3_ACCESSKEY
    export S3_SECRETKEY=$S3_SECRETKEY
    ```
    </p>
    </details>

## Check database connection

[Configure JDBC (DBeaver) connection](https://cloud.yandex.ru/docs/managed-greenplum/operations/connect):


![DBeaver + Greenplum](./docs/dbeaver_greenplum.png)

Make sure dbt can connect to your target database:

```bash
dbt debug
```

![dbt + Greenplum connection](./docs/dbt_debug_greenplum.png)

If any errors check ENV values are present:

```bash
env | grep DBT_
```

## Populate Data Vault day-by-day

1. Initialize data sources (External tables)

```bash
dbt run-operation init_s3_sources
```

1. Install packages:

```bash
dbt deps
```

1. Run models step-by-step

Load one day to Data Vault structures:

```bash
dbt run -m tag:raw
dbt run -m tag:stage

dbt run -m tag:hub
dbt run -m tag:link
dbt run -m tag:satellite
dbt run -m tag:t_link
```

1. Load next day

Simulate next day load by incrementing `load_date` varible:

```yaml dbt_profiles.yml
# dbt_profiles.yml

vars:
  load_date: '1992-01-02' # increment by one day
```

And update data vault:

```bash
dbt build
```

## Build Business Vault on top of Data Vault

1. [Point In Time (PIT) table](https://automate-dv.readthedocs.io/en/latest/tutorial/tut_point_in_time/)
1. [Bridge Table](https://automate-dv.readthedocs.io/en/latest/tutorial/tut_bridges/)

## Create and submit PR
Changed Docker file:
```
ARG DBT_VERSION=1.5.4
#FROM fishtownanalytics/dbt:${DBT_VERSION}
FROM ghcr.io/dbt-labs/dbt-core:${DBT_VERSION}
```
Started Greenplum cluster:
![gp](https://github.com/DenGodunov/dbtvault_greenplum_demo/assets/7568117/84f1374f-0ca3-493d-a81f-2cb7d25b86ff)
Connected to GP cluster in YC via DBeaver:
![GP_DB](https://github.com/DenGodunov/dbtvault_greenplum_demo/assets/7568117/1f1450ba-2266-4981-a779-ab9720969b6c)

Created effective satelites models, one bridge and one pit models:
![Code_7yg7J47rPz](https://github.com/DenGodunov/dbtvault_greenplum_demo/assets/7568117/c931bf5c-2379-4bac-907f-e6a6854614c1)
