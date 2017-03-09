#!/bin/bash

for i in ~/uni/capitularia/http/docs/cap/publ/mss/*.xml
do
    xmlstarlet sel -N tei='http://www.tei-c.org/ns/1.0' -t -m "//@corresp[contains (., 'Ansegis')]" -f -v "' '" -v "." -n "$i" | cut -d '/' -f 11
done
