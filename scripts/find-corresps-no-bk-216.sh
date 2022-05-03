#!/bin/bash

. scripts/env

PUBL="$CAP/publ/mss/"
IA="$CAP/intern/InArbeit"
INARBEIT="$IA/Alina $IA/Britta  $IA/Dominik* $IA/Lea $IA/Soeren"

rm /tmp/corresps.txt

for i in $PUBL # $INARBEIT
do
    echo $i
    saxon -it:main -xsl:scripts/find-corresps-no-bk-216.xsl dir="$i" >> /tmp/corresps.txt
done

scripts/find-corresps-no-bk-216.py < /tmp/corresps.txt
