#!/bin/bash

. scripts/env

for i in $PUBL $INARBEIT
do
    saxon -xsl:scripts/find-unlinked-corresps-171.xsl -s:"$i"
done
