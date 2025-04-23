#!/bin/sh

source /etc/profile.d/python3.bash

CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE=/share/homes/admin/homelink/matthewlymer-production-b2e5ab52c4ad.json \
    GOOGLE_PROJECT=matthewlymer-production \
    PATH="${PATH}:/share/homes/admin/google-cloud-sdk/bin" \
    source /share/homes/admin/homelink/update-dns-records.sh
