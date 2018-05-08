#!/bin/bash

# files=$(find ~/uni/capitularia/http/docs/cap/publ/mss/ -name "*.xml")

find ~/uni/capitularia/http/docs/cap/publ/mss/ -maxdepth 1 -name "*.xml" -exec \
     xmlstarlet sel -N tei='http://www.tei-c.org/ns/1.0' -t -i "//tei:note[@type='editorial'][contains (normalize-space(.), '$1')]" -f -v "' '" -v "count (//tei:note[@type='editorial'][contains (normalize-space (.), '$1')])" -n {} \; \
    | cut -d '/' -f 11-

find ~/uni/capitularia/http/docs/cap/intern/InArbeit/ -name "*.xml" -exec \
     xmlstarlet sel -N tei='http://www.tei-c.org/ns/1.0' -t -i "//tei:note[@type='editorial'][contains (normalize-space(.), '$1')]" -f -v "' '" -v "count (//tei:note[@type='editorial'][contains (normalize-space (.), '$1')])" -n {} \; \
    | cut -d '/' -f 10-
