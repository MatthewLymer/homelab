#!/bin/bash

function fail() {
    exit 1
}

trap 'fail' ERR

export DOCKER_HOST="ssh://qnappy@qnappy"

docker ps
