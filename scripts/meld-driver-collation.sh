#!/bin/bash
#
# Side-by-side compare the output of 2 xslt stylesheets to find errors
# introduced while refactoring.
#
# Usage:
#   meld-driver-collation.sh tei-file
#

XSLT1=xslt/mss-transcript-collation.xsl
XSLT2=~/uni/capitularia/http/docs/cap/publ/transform/transkription_LesEdi_CapKoll.xsl

meld <(xsltproc --param include-later-hand "true()" "$XSLT1" "$1" | \
          sed -r 's/<[^>]*>//g
                  s/[-.,:;!?*\/]//g
                  y/ęĘ/eE/
                  s/ae/e/g
                  s/A[Ee]/E/g
                  s/ / /g
                  s/ +$//mg' | \
          sed -r '/^\s*$/d') \
     <(xsltproc "$XSLT2" "$1" | \
          sed -r '/^\s*$/d')
