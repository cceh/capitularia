#!/bin/bash
#
# Side-by-side compare the output of 2 xslt stylesheets to find errors
# introduced while refactoring.
#
# Usage:
#   meld-driver-bib.sh
#

XML="/afs/rrz.uni-koeln.de/vol/www/projekt/capitularia/http/docs/cap/publ/bibl/Bibliographie_Capitularia.xml"

XSLT1="xslt/bib-bibliography-1.xsl.backup"
XSLT2="xslt/bib-bibliography.xsl"

meld <(xsltproc "$XSLT1" "$XML") \
     <(saxon -xsl:"$XSLT2" -s:"$XML")
