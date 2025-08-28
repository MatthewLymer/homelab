#!/bin/bash

set -e

if [[ -z "$TR_TORRENT_DIR" ]]; then
    echo \$TR_TORRENT_DIR is not set.
    exit 1
fi

if [[ -z "$TR_TORRENT_NAME" ]]; then
    echo \$TR_TORRENT_NAME is not set.
    exit 1
fi

TORRENT_PATH="$TR_TORRENT_DIR/$TR_TORRENT_NAME"

find "$TORRENT_PATH" -name \*.rar -maxdepth 1 | xargs -I{} unrar e -o- {} "$TORRENT_PATH"
