#!/bin/bash

. scripts/env

for i in $MSS $INARBEIT
do
    saxon -xsl:scripts/find-split-corresp-160.xsl -s:"$i"
done
