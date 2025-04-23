#!/bin/bash

#
# see https://wiki.qnap.com/wiki/Add_items_to_crontab
# for documentation on QNAP cron implementation
#

SCRIPT_PATH=/share/homes/admin/certbot/run-certbot.sh
CRONTAB_PATH=/etc/config/crontab

if [[ "$(cat $CRONTAB_PATH)" != *"$SCRIPT_PATH"* ]]; then
    # run every 14 days, at a random minute and hour
    echo "H H */14 * * ${SCRIPT_PATH}" >> $CRONTAB_PATH

    # restart crontab
    crontab /etc/config/crontab && /etc/init.d/crond.sh restart
fi
