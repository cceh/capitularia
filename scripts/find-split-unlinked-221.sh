#!/bin/bash

. scripts/env

for i in $MSS # $INARBEIT
do
    scripts/find-split-unlinked-221.py "$i"
done
