#!/bin/bash

. scripts/env

for i in $PUBL $INARBEIT
do
    xsltproc scripts/edit-remove-num-90.xsl "$i" > "$i.90.tmp"
    mv "$i.90.tmp" "$i"
done
