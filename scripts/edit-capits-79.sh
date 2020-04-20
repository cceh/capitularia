#!/bin/bash

. scripts/env

for i in $CAPITS
do
    echo $i
    saxon -xsl:scripts/edit-capits-79.xsl -s:"$i" > "$i.79.tmp"
    mv "$i.79.tmp" "$i"
done
