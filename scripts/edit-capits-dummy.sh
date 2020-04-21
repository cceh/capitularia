#!/bin/bash

. scripts/env

for i in $CAPITS
do
    echo $i
    saxon -xsl:scripts/edit-dummy.xsl -s:"$i" > "$i.dummy.tmp"
    mv "$i.dummy.tmp" "$i"
done
