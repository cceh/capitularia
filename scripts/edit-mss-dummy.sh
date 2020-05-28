#!/bin/bash

. scripts/env

for i in mss/*.xml # $MSS
do
    echo $i
    saxon -xsl:scripts/edit-dummy.xsl -s:"$i" > "$i.dummy.tmp"
    mv "$i.dummy.tmp" "$i"
done
