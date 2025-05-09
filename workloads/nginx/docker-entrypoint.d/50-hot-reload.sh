#!/bin/sh

set -e

# CONFIG_PATH="/etc/nginx/conf.d/custom"
POLL_FREQUENCY=60m

entrypoint_log() {
    if [ -z "${NGINX_ENTRYPOINT_QUIET_LOGS:-}" ]; then
        echo "$@"
    fi
}

reload_nginx() {
    entrypoint_log "$@"
    nginx -s reload
}

get_checksum() {
    # find ${CONFIG_PATH} -maxdepth 1 -type f -exec sh -c 'echo -n "{} "; stat -c %Y {}' \; | sort
    echo "${NGINX_SSL_CERTIFICATE} $(stat -c %Y $NGINX_SSL_CERTIFICATE 2> /dev/null)"
    echo "${NGINX_SSL_CERTIFICATE_KEY} $(stat -c %Y $NGINX_SSL_CERTIFICATE_KEY 2> /dev/null)"
}

last_checksum=$(get_checksum)

while true; do
    sleep $POLL_FREQUENCY

    curr_checksum=$(get_checksum)

    if [ "$last_checksum" != "$curr_checksum" ]; then
        last_checksum=$curr_checksum
        reload_nginx "Detected change, reloading nginx."
    fi
done &

exit 0