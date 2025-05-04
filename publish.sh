#!/bin/bash

SSH_CREDS="qnappy@qnappy"
GOOGLE_PROJECT="matthewlymer-production"

# aliases
dc() {
    DOCKER_HOST="ssh://${SSH_CREDS}" \
    docker compose \
    -f docker-compose.yml \
    -f docker-compose.production.yml \
    "$@"
}

echo "Pushing config changes."

ssh $SSH_CREDS -C "[ -d ~/home-automation ] || mkdir ~/home-automation"
gcloud secrets versions access latest --project=$GOOGLE_PROJECT --secret=certbot_sa_key | ssh $SSH_CREDS -C 'cat - > ~/home-automation/certbot_sa_key.json && chmod 600 ~/home-automation/certbot_sa_key.json'
gcloud secrets versions access latest --project=$GOOGLE_PROJECT --secret=homelink_sa_key | ssh $SSH_CREDS -C 'cat - > ~/home-automation/homelink_sa_key.json && chmod 600 ~/home-automation/homelink_sa_key.json'

cat ./workloads/nginx/nginx.conf | ssh $SSH_CREDS -C "cat - > ~/home-automation/nginx.conf"

echo "Starting workloads."

dc up --detach

echo "Reloading nginx."

dc kill --signal HUP nginx

echo "All Done."
