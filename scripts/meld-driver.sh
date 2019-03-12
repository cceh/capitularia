#!/bin/bash
#
# Side-by-side compare the output of 2 xslt stylesheets to find errors
# introduced while refactoring.
#
# Usage:
#   meld-driver.sh tei-file
#

XSLT="${2-mss-transcript.xsl}"
XSLT1="xslt/$XSLT"
XSLT2=~/uni/capitularia/http/docs/cap/publ/transform/$XSLT

meld <(xsltproc "$XSLT1" "$1") \
     <(xsltproc "$XSLT2" "$1")
