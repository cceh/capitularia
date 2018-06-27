#!/bin/bash
#

XML="$1"
OUT="$2"

./sequential.py --repeats "$XML" | sed "s/ \\$//g" | sort > $OUT/max_repeats.txt

# collections found by maximal repeats
while read line
do
    ./sequential.py    -o $OUT/sequence-collection-{include-bks}-date.png  \
                       --title="Capitulars {include-bks} in Manuscripts" \
                       --include-bks="$line" "$XML" &
done < <(cut -d ' ' -f 2- $OUT/max_repeats.txt)
