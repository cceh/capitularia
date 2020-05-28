#!/bin/bash

. scripts/env

for i in mss/*.xml # $MSS
do
    echo $i
    saxon -xsl:scripts/edit-persname-159.xsl -s:"$i" > "$i.159.tmp"
    mv "$i.159.tmp" "$i"
done
