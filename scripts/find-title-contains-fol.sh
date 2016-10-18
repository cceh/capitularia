#!/bin/bash

for i in ~/uni/capitularia/http/docs/cap/publ/mss/*.xml
do
   xsltproc remove-filiation.xsl $i | xmlstarlet sel -N tei='http://www.tei-c.org/ns/1.0' -t -i "//tei:title[@type='main' and (contains (., 'fol.') or contains (., 'foll.'))]" -o $i -n
done
