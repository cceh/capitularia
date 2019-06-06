#!/bin/bash

. scripts/env

for i in $PUBL $INARBEIT
do
    xsltproc scripts/edit-add-gap-editorial-81.xsl "$i" > "$i.81.tmp"
    mv "$i.81.tmp" "$i"
done
