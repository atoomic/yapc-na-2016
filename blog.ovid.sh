#!/bin/bash

tempfile=/tmp/$$allsubs.txt

WHAT="$1"

ack '^\s*sub\s+(\w+)\b' $WHAT |     \
    awk '/sub (\w*)/ { print $2 }' | \
    cut -d'(' -f1 |                  \
    sort |                           \
    uniq > $tempfile

for sub in $(cat $tempfile); do
    if [[ $(expr `git grep -E "\<$sub\>" |wc -l`) == 1 ]]; then
        echo $sub
    fi
done

rm $tempfile