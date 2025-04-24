#!/bin/bash

docker run --rm \
    --volume "/share/homes/admin/certbot/etc_letsencrypt:/etc/letsencrypt" \
    --volume "/share/homes/admin/certbot/sa.json:/root/.config/sa.json:ro" \
    certbot/dns-google certonly \
    --agree-tos \
    --noninteractive \
    --preferred-challenges dns \
    --domain "home.lymer.ca" \
    --domain "*.home.lymer.ca" \
    --dns-google \
    --dns-google-credentials /root/.config/sa.json
