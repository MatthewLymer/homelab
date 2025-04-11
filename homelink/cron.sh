#!/bin/sh

source /etc/profile.d/python3.bash

GOOGLE_APPLICATION_CREDENTIALS=/share/homes/admin/homelink/matthewlymer-production-b2e5ab52c4ad.json \
    GOOGLE_PROJECT=matthewlymer-production \
    PATH="${PATH}:/share/homes/admin/google-cloud-sdk/bin" \
    source update-dns-records.sh
