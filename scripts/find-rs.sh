#!/bin/bash

. scripts/env

LIST=$(
for i in xml/*xml # $PUBLIC $INARBEIT
do
    xmlstarlet sel -N tei='http://www.tei-c.org/ns/1.0' -t -m "//tei:rs" \
               -v "concat(./@type, ',\"', normalize-space(.), '\"')" -n $i
done
    )
echo "$LIST" | sort -t "," -k 1,1 | uniq -c
