#!/bin/bash

. scripts/env

for i in xml/*.xml # $PUBL $INARBEIT
do
    sel -t -m "//tei:msItem[@corresp and .//tei:title and not (.//tei:title[not (@corresp)])]" -f -v "' '" -v "@corresp" -n "$i"
done
