#!/bin/bash

. scripts/env

for i in $CAPITS
do
    echo $i
    saxon -xsl:scripts/edit-capits-149.xsl -s:"$i" > "$i.149.tmp"
    mv "$i.149.tmp" "$i"
done
