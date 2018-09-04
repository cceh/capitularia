#!/bin/bash

. scripts/env

for i in xml/*.xml # $PUBL $INARBEIT
do
    xsltproc scripts/edit-corresp-title-71.xsl "$i" > "$i.71.tmp"
    mv "$i.71.tmp" "$i"
done
