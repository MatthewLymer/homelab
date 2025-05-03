#!/bin/bash

function fail() {
    exit 1
}

trap 'fail' ERR

CONTAINER_NAME=$(uuidgen)
SSH_CREDS="qnappy@qnappy"

export DOCKER_HOST="ssh://${SSH_CREDS}"

GOOGLE_PROJECT="matthewlymer-production"

REMOTE_HOME=$(ssh $SSH_CREDS -C 'echo $HOME')

# docker run --detach --rm --name $CONTAINER_NAME --volume "${REMOTE_HOME}/home-automation:/app" alpine sh -c 'sleep 5m'

# echo "attack at dawn" | docker exec -i $CONTAINER_NAME sh -c 'cat > /app/priv.txt'

ssh $SSH_CREDS -C "[ -d ~/home-automation ] || mkdir ~/home-automation"

echo "You know you want it" | ssh $SSH_CREDS -C 'cat - > ~/home-automation/goo.txt'

# docker ps

# gcloud secrets versions access latest --project=$GOOGLE_PROJECT --secret=certbot_sa_key 2>/dev/null
