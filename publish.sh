#!/bin/bash

SSH_CREDS="qnappy@qnappy"
GOOGLE_PROJECT="matthewlymer-production"

dc() {
    DOCKER_HOST="ssh://${SSH_CREDS}" \
    docker compose \
    -f docker-compose.yml \
    -f docker-compose.production.yml \
    "$@"
}

sshq() {
    ssh $SSH_CREDS "$@"
}

echo "Pushing config changes."

sshq -C "[ -d ~/home-automation ] || mkdir ~/home-automation"

gcloud secrets versions access latest --project=$GOOGLE_PROJECT --secret=certbot_sa_key | sshq -C 'cat - > ~/home-automation/certbot_sa_key.json && chmod 600 ~/home-automation/certbot_sa_key.json'
gcloud secrets versions access latest --project=$GOOGLE_PROJECT --secret=homelink_sa_key | sshq -C 'cat - > ~/home-automation/homelink_sa_key.json && chmod 600 ~/home-automation/homelink_sa_key.json'

# nginx
sshq -C "[ -d ~/home-automation/nginx ] || mkdir ~/home-automation/nginx"
sshq -C 'find ~/home-automation/nginx -type f -delete' # delete files but keep directories
tar -C ./workloads/nginx -cf - . | sshq -C 'tar -C ~/home-automation/nginx -xf -'

# actual
sshq -C "([ -d ~/home-automation/actual ] || mkdir ~/home-automation/actual) && ([ -d ~/home-automation/actual/data ] || mkdir ~/home-automation/actual/data)"

# jellyfin
sshq -C "([ -d ~/home-automation/jellyfin ] || mkdir ~/home-automation/jellyfin) && ([ -d ~/home-automation/jellyfin/config ] || mkdir ~/home-automation/jellyfin/config) && ([ -d ~/home-automation/jellyfin/cache ] || mkdir ~/home-automation/jellyfin/cache)"

echo "Starting workloads."

dc up --detach

echo "Reloading nginx."

dc kill --signal HUP nginx

echo "All Done."
