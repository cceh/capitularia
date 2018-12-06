#!/bin/bash

. scripts/env

for i in $INARBEIT
do
    xsltproc scripts/edit-hi-rend-super-100.xsl "$i" > "$i.100.tmp"
    mv "$i.100.tmp" "$i"
done
