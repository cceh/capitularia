#!/bin/bash
#
# Side-by-side compare the output of 2 xslt stylesheets to find errors
# introduced while refactoring.
#
# Usage:
#   meld-driver-header.sh file
#

CACHE1="/afs/rrz.uni-koeln.de/vol/www/projekt/capitularia/http/docs/cap/publ/cache"
CACHE2="../cache"

CACHE_DIR=$CACHE2 make -e $CACHE2/$1

LINT="tidy -ashtml -utf8 -i -w -"

meld <(cat $CACHE1/$1 | $LINT) \
     <(cat $CACHE2/$1 | $LINT)
