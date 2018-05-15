#!/bin/bash

. scripts/env

DIR="$CAP/publ/capit"
DATE=`date +%F-%T`

zip "$DIR/backup-$DATE.zip" "$DIR/*.xml"

for i in "$DIR/*.xml"
do
    xsltproc scripts/edit-capit-refs-79.xsl "$i" > "$i.79.tmp"
    mv "$i.79.tmp" "$i"
done
