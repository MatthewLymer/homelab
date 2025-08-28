#!/bin/bash

err() {
	echo "$@" 1>&2
}

SEARCH_DIR=$1
OUTPUT_DIR=$2

if [[ -z "$SEARCH_DIR" ]] || [[ -z "$OUTPUT_DIR" ]]; then
	err Usage: $0 SEARCH_DIR OUTPUT_DIR
	exit 1
fi

find $SEARCH_DIR -iname '*.mkv' -o -iname '*.avi' -o -iname '*.mp4' | grep -iP '\bS[0-9][0-9]E[0-9][0-9]\b' | while read line || [[ -n $line ]]
do
	filename=$(basename "$line")
	extension=${filename##*.}
        normalized=$(echo "$filename" | tr '[:upper:]' '[:lower:]' | tr ' ' '.' | sed -r 's/[^a-z0-9]+/./g')
	title=$( echo $normalized | grep -oP '(.+)(?=\bs[0-9]{2}e[0-9]{2})' | sed -r 's/(\.[12]{1}[0-9]{3})?\.$//' )
        season_and_episode=$( echo $normalized | grep -oP '(\bs[0-9][0-9]e[0-9][0-9]\b)' )
        season=${season_and_episode:1:2}
        episode=${season_and_episode:4:2}
        
	season_dir="$OUTPUT_DIR/$title/Season ${season_and_episode:1:2}"

	mkdir -p "$season_dir"

	link="$season_dir/$season_and_episode.$extension"
	file=$(realpath -s --relative-to="$season_dir" "$line")

	ln -sf "$file" "$link"
done
