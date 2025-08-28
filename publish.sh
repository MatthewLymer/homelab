#!/bin/bash

SSH_CREDS="deployer@truenas.local"
GOOGLE_PROJECT="matthewlymer-production"
WORKSPACE_ROOT="/mnt/main/home/deployer/homelab"

TRANSMISSION_OPENVPN_USERNAME=
TRANSMISSION_OPENVPN_PASSWORD=

dc() {
    DOCKER_HOST="ssh://${SSH_CREDS}" \
    WORKSPACE_ROOT=$WORKSPACE_ROOT \
    TRANSMISSION_OPENVPN_USERNAME=$TRANSMISSION_OPENVPN_USERNAME \
    TRANSMISSION_OPENVPN_PASSWORD=$TRANSMISSION_OPENVPN_PASSWORD \
    docker compose \
    -f docker-compose.yml \
    -f docker-compose.production.yml \
    "$@"
}

sshq() {
    ssh $SSH_CREDS "$@"
}

echo "Grant access to user"

sshq -C 'sudo adduser deployer docker'

echo "Setting up initial directories."

sshq -C "mkdir -p $WORKSPACE_ROOT && echo Workspace root: $WORKSPACE_ROOT"

echo "Pushing config changes."

# certbot
CERTBOT_DIR=$WORKSPACE_ROOT/certbot
sshq -C "mkdir -p $CERTBOT_DIR"
gcloud secrets versions access latest --project=$GOOGLE_PROJECT --secret=onprem-certbot_sa_key | sshq -C "cat - > $CERTBOT_DIR/certbot_sa_key.json && chmod 600 $CERTBOT_DIR/certbot_sa_key.json"

# homelink
HOMELINK_DIR=$WORKSPACE_ROOT/homelink
sshq -C "mkdir -p $HOMELINK_DIR"
gcloud secrets versions access latest --project=$GOOGLE_PROJECT --secret=onprem-homelink_sa_key | sshq -C "cat - > $HOMELINK_DIR/homelink_sa_key.json && chmod 600 $HOMELINK_DIR/homelink_sa_key.json"

# nginx
NGINX_DIR=$WORKSPACE_ROOT/nginx
sshq -C "mkdir -p $NGINX_DIR && find $NGINX_DIR -type f -delete" # delete files but keep directories
tar -C ./workloads/nginx -cf - . | sshq -C "tar -C $NGINX_DIR -xf -"

# actual
ACTUAL_DIR=$WORKSPACE_ROOT/actual
sshq -C "mkdir -p $ACTUAL_DIR/data"

# jellyfin
JELLYFIN_DIR=$WORKSPACE_ROOT/jellyfin
sshq -C "mkdir -p $JELLYFIN_DIR/cache && mkdir -p $JELLYFIN_DIR/config"

# transmission
TRANSMISSION_DIR=$WORKSPACE_ROOT/transmission
sshq -C "mkdir -p $TRANSMISSION_DIR/scripts && find $TRANSMISSION_DIR/scripts -type f -delete"
tar -C ./workloads/transmission/scripts -cf - . | sshq -C "tar -C $TRANSMISSION_DIR/scripts -xf -"
TRANSMISSION_OPENVPN_USERNAME=$(gcloud secrets versions access latest --project=$GOOGLE_PROJECT --secret=transmission-openvpn-username)
TRANSMISSION_OPENVPN_PASSWORD=$(gcloud secrets versions access latest --project=$GOOGLE_PROJECT --secret=transmission-openvpn-password)

echo "Starting workloads."

dc up --detach

echo "Reloading nginx."

dc kill --signal HUP nginx

echo "All Done."
