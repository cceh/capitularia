#!/bin/bash

for i in xml/*.xml
do
   xmlstarlet sel -N tei='http://www.tei-c.org/ns/1.0' -t -i "//tei:note[@type='editorial'][contains(.,'+')]" -f -v "' '" -v "normalize-space (//tei:note[@type='editorial'][contains(.,'+')])" -n $i
done
