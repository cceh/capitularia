#!/bin/bash

for i in ~/uni/capitularia/http/docs/cap/publ/mss/*.xml
do
   xsltproc remove-nums.xsl $i | xmlstarlet sel -N tei='http://www.tei-c.org/ns/1.0' -t -i "//tei:ab[@type='meta-text' and normalize-space (.) and not (@corresp)]" -o $i -n
done
