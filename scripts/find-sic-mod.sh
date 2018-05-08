#!/bin/bash

for i in ~/uni/capitularia/http/docs/cap/publ/mss/*.xml
do
    xmlstarlet sel -N tei='http://www.tei-c.org/ns/1.0' -t \
               -m "//tei:sic[*[self::tei:mod or self::tei:add or self::tei:del or self::tei:subst]]" -o "$i" -n -v . -n "$i"
done
