#!/bin/bash

SSH_CREDS="deployer@truenas.local"
GOOGLE_PROJECT=$(cat .env | grep 'GOOGLE_PROJECT=' | cut -d'=' -f2-)
WORKSPACE_ROOT="/mnt/main/home/deployer/homelab"

TRANSMISSION_OPENVPN_USERNAME=
TRANSMISSION_OPENVPN_PASSWORD=
OAUTH2_PROXY_GOOGLE_CLIENT_ID=
OAUTH2_PROXY_GOOGLE_CLIENT_SECRET=
OAUTH2_PROXY_COOKIE_SECRET=

dc() {
    DOCKER_HOST="ssh://${SSH_CREDS}" \
    WORKSPACE_ROOT=$WORKSPACE_ROOT \
    TRANSMISSION_OPENVPN_USERNAME=$TRANSMISSION_OPENVPN_USERNAME \
    TRANSMISSION_OPENVPN_PASSWORD=$TRANSMISSION_OPENVPN_PASSWORD \
    OAUTH2_PROXY_GOOGLE_CLIENT_ID=$OAUTH2_PROXY_GOOGLE_CLIENT_ID \
    OAUTH2_PROXY_GOOGLE_CLIENT_SECRET=$OAUTH2_PROXY_GOOGLE_CLIENT_SECRET \
    OAUTH2_PROXY_COOKIE_SECRET=$OAUTH2_PROXY_COOKIE_SECRET \
    docker compose \
    -f docker-compose.yml \
    -f docker-compose.production.yml \
    "$@"
}

sshq() {
    ssh $SSH_CREDS "$@"
}

# this is a TrueNAS specific instruction as by default only
# the "root" user has access to the docker socket, however,
# you can grant access to the "docker" group, but that appears
# to be ephemeral, so grant access every time we deploy and
# hope there's no race-condition.
echo "Grant access to user"
sshq -C 'sudo adduser deployer docker'

echo "Setting up initial directories."
sshq -C "mkdir -p $WORKSPACE_ROOT"

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

# sonarr
SONARR_DIR=$WORKSPACE_ROOT/sonarr
sshq -C "mkdir -p $SONARR_DIR/config"

# prowlarr
PROWLARR_DIR=$WORKSPACE_ROOT/prowlarr
sshq -C "mkdir -p $PROWLARR_DIR/config"

# oauth2-proxy
OAUTH2_PROXY_DIR=$WORKSPACE_ROOT/oauth2-proxy
sshq -C "mkdir -p $OAUTH2_PROXY_DIR"
gcloud secrets versions access latest --project=$GOOGLE_PROJECT --secret=oauth2-proxy-allowed-emails | sshq -C "cat - > $OAUTH2_PROXY_DIR/allowed-emails.txt"
OAUTH2_PROXY_GOOGLE_CLIENT_ID=$(gcloud secrets versions access latest --project=$GOOGLE_PROJECT --secret=oauth2-proxy-google-client-id)
OAUTH2_PROXY_GOOGLE_CLIENT_SECRET=$(gcloud secrets versions access latest --project=$GOOGLE_PROJECT --secret=oauth2-proxy-google-client-secret)
OAUTH2_PROXY_COOKIE_SECRET=$(gcloud secrets versions access latest --project=$GOOGLE_PROJECT --secret=oauth2-proxy-cookie-secret)

echo "Starting workloads."

dc up --detach

# Do not do `dc kill --signal HUP nginx` to send the SIGHUP signal, as
# it will make docker think we want to stop the container, and the
# "unless-stopped" restart policy will NOT restart it.
#
# Instead, we can send that signal from inside the container, working
# around the issue.
#
# The nginx master process should be operating on PID 1
#
# See https://github.com/moby/moby/issues/47792
#

echo "Reloading nginx configuration."
dc exec nginx /bin/sh -c "kill -s HUP 1"

echo "All Done."
