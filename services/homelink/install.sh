#!/bin/bash

#
# see https://wiki.qnap.com/wiki/Add_items_to_crontab
# for documentation on QNAP cron implementation
#

SCRIPT_PATH=/share/homes/admin/homelink/cron.sh
CRONTAB_PATH=/etc/config/crontab

if [[ "$(cat $CRONTAB_PATH)" != *"$SCRIPT_PATH"* ]]; then
    # run every 15 minutes, offset by some random amount
    echo "H/15 * * * * ${SCRIPT_PATH}" >> $CRONTAB_PATH

    # restart crontab
    crontab /etc/config/crontab && /etc/init.d/crond.sh restart
fi
