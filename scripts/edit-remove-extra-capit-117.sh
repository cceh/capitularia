#!/bin/bash

. scripts/env

for i in capit/lists/capit_all.xml
do
    xsltproc scripts/edit-remove-extra-capit-117.xsl "$i" > "$i.117.tmp"
    mv "$i.117.tmp" "$i"
done
