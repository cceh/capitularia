#!/bin/bash

. scripts/env

for i in $PUBL $INARBEIT
do
    sel -t -m "//tei:msItem[contains (@corresp, ' ')]" -f -v "' '" -v "@corresp" -n "$i" | cut -d '/' -f 9-
done
