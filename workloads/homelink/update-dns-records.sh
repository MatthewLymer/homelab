#!/bin/bash

trap 'exit' ERR

GOOGLE_PROJECT=${GOOGLE_PROJECT?"Required"}
DNS_NAME=${DNS_NAME?"Required"}
ZONE=${ZONE?"Required"}

CURRENT_IP=$(curl -sSL https://icanhazip.com)

echo Current IP $CURRENT_IP.

CURRENT_RRDATA=$(gcloud dns record-sets list \
    --name=$DNS_NAME \
    --type=A \
    --zone=$ZONE \
    --project=$GOOGLE_PROJECT \
    --format=json | jq -r '.[0].rrdatas[0]')

echo Current RRDATA $CURRENT_RRDATA.

if [[ "$CURRENT_RRDATA" == "null" ]]; then
    echo Creating new record-set.

    gcloud dns record-sets create $DNS_NAME \
        --rrdatas=$CURRENT_IP \
        --type=A \
        --ttl=300 \
        --zone=$ZONE \
        --project=$GOOGLE_PROJECT

elif [[ "$CURRENT_IP" != "$CURRENT_RRDATA" ]]; then
    echo Updating existing record-set.

    gcloud dns record-sets update $DNS_NAME \
        --rrdatas=$CURRENT_IP \
        --type=A \
        --ttl=300 \
        --zone=$ZONE \
        --project=$GOOGLE_PROJECT
else
    echo No changes required.
fi
