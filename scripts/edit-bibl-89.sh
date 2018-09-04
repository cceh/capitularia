#!/bin/bash

. scripts/env

for i in xml/*.xml # $PUBL $INARBEIT
do
    xsltproc scripts/edit-bibl-89.xsl "$i" > "$i.89.tmp"
    mv "$i.89.tmp" "$i"
done
