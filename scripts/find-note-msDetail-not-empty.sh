#!/bin/bash

for i in ~/uni/capitularia/http/docs/cap/publ/mss/*.xml
do
   xmlstarlet sel -N tei='http://www.tei-c.org/ns/1.0' -t -i "//tei:note[@type='msDetail'][normalize-space (.)]" -f -v "//tei:note[@type='msDetail'][normalize-space (.)]" -n $i | cut -d '/' -f 11
done
