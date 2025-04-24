# the bitnami image supports ARM
FROM bitnami/google-cloud-sdk:latest

USER root

RUN apt-get update && apt-get install -y jq curl

WORKDIR /app

COPY update-dns-records.sh .
