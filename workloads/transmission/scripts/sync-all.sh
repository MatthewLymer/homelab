#!/bin/bash

if [[ -z "$TR_TORRENT_DIR" ]]; then
    echo TR_TORRENT_DIR is not set.
    exit 1
fi

ls -1 "$TR_TORRENT_DIR" | while read TR_TORRENT_NAME || [[ -n $TR_TORRENT_NAME ]]
do
    TR_TORRENT_DIR="$TR_TORRENT_DIR" TR_TORRENT_NAME="$TR_TORRENT_NAME" ./on-torrent-done.sh
done
