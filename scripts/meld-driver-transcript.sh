#!/bin/bash
#
# Side-by-side compare the output of 2 xslt stylesheets to find errors
# introduced while refactoring.
#
# Usage:
#   meld-driver-transcript.sh
#

#ID="barcelona-aca-ripoll-40"
#ID="wolfenbuettel-hab-blankenb-130"
#ID="paris-bn-lat-4628a"
#ID="gotha-flb-memb-i-84"
ID="berlin-sb-phill-1737"

HTML1="/afs/rrz.uni-koeln.de/vol/www/projekt/capitularia/http/docs/cap/publ/cache/mss/$ID.transcript.html"
HTML2="cache/mss/$ID.transcript.html"

cd xslt
CACHE_DIR=../cache make -e ../$HTML2 || exit 1
cd ..

Q='"'

SED="sed -E -e s|id=$Q[-0-9a-z]+$Q|id=XXX|g -e s|<span.class=$Q.enerated$Q></span>||g -e s|<span></span>||g -e s|index.tei-hi|index|g -e s!\s?rend-(glossa|nota)!!g"

echo $SED

LINT="tidy -q -ashtml -utf8 -i -w 80 --drop-empty-elements no --sort-attributes alpha"
#LINT="xmllint --encode utf-8 --format"

meld <(cat $HTML1 | $SED | $LINT) \
     <(cat $HTML2 | $SED | $LINT)
