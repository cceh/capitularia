#!/bin/bash
#
# Side-by-side compare the output of 2 xslt stylesheets to find errors
# introduced while refactoring.
#
# Usage:
#   meld-driver.sh tei-file
#

XSLT1=xslt/mss-transcript.xsl
XSLT2=~/uni/capitularia/http/docs/cap/publ/transform/mss-transcript.xsl

meld <(xsltproc "$XSLT1" "$1") \
     <(xsltproc "$XSLT2" "$1")
