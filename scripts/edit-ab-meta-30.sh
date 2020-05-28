#!/bin/bash

. scripts/env

for i in mss/*.xml # $MSS
do
    echo $i
    saxon -xsl:scripts/edit-ab-meta-30.xsl -s:"$i" > "$i.30.tmp"
    mv "$i.30.tmp" "$i"
done
