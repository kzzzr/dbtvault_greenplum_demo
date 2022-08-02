ARG DBT_VERSION=0.19.0
FROM fishtownanalytics/dbt:${DBT_VERSION}

# ARG DBT_VERSION
# RUN set -ex \
#     && pip install dbt-clickhouse==${DBT_VERSION}

ENV DBT_PROFILES_DIR=.

# COPY profiles.yml profiles.yml    

ENTRYPOINT ["tail", "-f", "/dev/null"]