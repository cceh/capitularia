#!/bin/bash

. scripts/env

for i in xml/*xml # $PUBLIC $INARBEIT
do
    xmlstarlet sel -N tei='http://www.tei-c.org/ns/1.0' -t \
               -i "not (//tei:origPlace[contains (@ref, 'geonames') or contains (@ref, '/gnd/')])" \
               -f -n $i
done
