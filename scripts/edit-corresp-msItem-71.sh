#!/bin/bash

. scripts/env

for i in $PUBL $INARBEIT
do
    xsltproc scripts/edit-corresp-msItem-71.xsl "$i" > "$i.71.tmp"
    mv "$i.71.tmp" "$i"
done
