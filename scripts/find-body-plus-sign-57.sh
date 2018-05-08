#!/bin/bash

. scripts/env

for i in $PUBL $INARBEIT
do
    sel -t -m "//tei:note[@type='editorial'][contains(.,'+')]" -f -n "$i"
    sel -t -m "//tei:del[contains(.,'+')]" -f -n "$i"
done
