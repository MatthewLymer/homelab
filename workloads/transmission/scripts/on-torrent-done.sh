#!/bin/bash

if [[ -z "$TR_TORRENT_DIR" ]]; then
    echo \$TR_TORRENT_DIR is not set.
    exit 1
fi

if [[ -z "$TR_TORRENT_NAME" ]]; then
    echo \$TR_TORRENT_NAME is not set.
    exit 1
fi

TORRENT_PATH="$TR_TORRENT_DIR/$TR_TORRENT_NAME"

find "$TORRENT_PATH" -type f -iname \*.mkv -o -type f -iname \*.mp4 -o -type f -iname \*.avi | while read src || [[ -n $src ]]
do
    echo Processing \'$src\'

    filename=$(basename "$src")
    normalized=$(echo "$filename" | tr '[:upper:]' '[:lower:]' | tr ' ' '.' | sed -r 's/[^a-z0-9]+/./g')
    episode_id=$(echo $normalized | grep -oe '\bs[0-9][0-9]e[0-9][0-9]\b')

    if [[ -n "$episode_id" ]]; then
        show_name=$(echo $normalized | grep -oe '.*\bs[0-9][0-9]e[0-9][0-9]\b' | sed -r 's/\.s[0-9][0-9]e[0-9][0-9]$//g' | sed -r 's/[^a-z0-9]+$/./g')
        episode_number=${episode_id:4:2}
        season_number=${episode_id:1:2}
        season_dir="/data/shows/$show_name/Season $season_number"
        extension=${filename##*.}

        dest="$season_dir/$episode_id.$extension"

        mkdir -p "$season_dir"

        # copy (hard)links recursively
        echo Copying \'$src\' to \'$dest\'
        cp -al "$src" "$dest"
    else
        movies_dir="/data/movies"

        mkdir -p "$movies_dir"

        # copy (hard)links recursively
        echo Copying \'$src\' to \'$movies_dir\'
        cp -al "$TORRENT_PATH" "$movies_dir"
    fi
done
