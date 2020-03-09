#!/bin/bash
#
# Side-by-side compare the output of 2 xslt stylesheets to find errors
# introduced while refactoring.
#
# Usage:
#   meld-driver-footer.sh
#

XML="/afs/rrz.uni-koeln.de/vol/www/projekt/capitularia/http/docs/cap/publ/mss/barcelona-aca-ripoll-40.xml"

XSLT1="xslt/mss-footer.xsl"
XSLT2="xslt/mss-footer-3.xsl"

LINT="tidy -ashtml -utf8 -i -w -"

meld <(xsltproc      "$XSLT1"    "$XML" | $LINT) \
     <(saxon    -xsl:"$XSLT2" -s:"$XML" | $LINT)
