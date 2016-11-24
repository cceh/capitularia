#!/bin/bash

for i in ~/uni/capitularia/http/docs/cap/publ/mss/*.xml
do
   xmlstarlet sel -N tei='http://www.tei-c.org/ns/1.0' -t -i "//tei:subst/tei:del[@hand]" -o $i -n $i
done
