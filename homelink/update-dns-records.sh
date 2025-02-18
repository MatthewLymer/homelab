#!/bin/bash

trap 'exit' ERR

PROJECT=matthewlymer-production
DNS_NAME=home.lymer.ca.
ZONE=lymer-ca
LOCATION=

CURRENT_IP=$(curl -sSL https://icanhazip.com)

echo Current IP $CURRENT_IP.

CURRENT_RRDATA=$(gcloud dns record-sets list \
    --name=$DNS_NAME \
    --type=A \
    --zone=$ZONE \
    --project=$PROJECT \
    --format=json | jq -r '.[0].rrdatas[0]')

echo Current RRDATA $CURRENT_RRDATA.

if [[ "$CURRENT_RRDATA" == "null" ]]; then
    echo Creating new record-set.

    gcloud dns record-sets create $DNS_NAME \
        --rrdatas=$CURRENT_IP \
        --type=A \
        --ttl=300 \
        --zone=$ZONE \
        --project=$PROJECT

elif [[ "$CURRENT_IP" != "$CURRENT_RRDATA" ]]; then
    echo Updated existing record-set.

    gcloud dns record-sets update $DNS_NAME \
        --rrdatas=$CURRENT_IP \
        --type=A \
        --ttl=300 \
        --zone=$ZONE \
        --project=$PROJECT
else
    echo No changes required.
fi
