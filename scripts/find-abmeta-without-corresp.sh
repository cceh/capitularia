#!/bin/bash

#for i in ~/uni/capitularia/http/docs/cap/publ/mss/*.xml
#do
#   xsltproc remove-nums.xsl "$i" | xmlstarlet sel -N tei='http://www.tei-c.org/ns/1.0' -t -i "//tei:ab[@type='meta-text' and normalize-space (translate (., '.', '')) and not (@corresp)]" -o "$i" -n | cut -d '/' -f 11
#done

for i in ~/uni/capitularia/http/docs/cap/publ/mss/*.xml
do
    xmlstarlet sel -N tei='http://www.tei-c.org/ns/1.0' -t -m "//tei:ab[@type='meta-text' and not (@corresp) and .//text()[not (ancestor::tei:seg[@type='num']) and not (ancestor::tei:seg[@type='numDenom']) and not (ancestor::tei:note) and normalize-space (translate (., '.', ''))]]" -f -v "' '" -v "." -n "$i" | cut -d '/' -f 11
done
