#!/bin/bash

. scripts/env

for i in $PUBL $INARBEIT
do
    sel -t -m "//tei:note[@type='msDetail']" -f -v "." -n "$i"
done
