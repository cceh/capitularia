#!/bin/bash
#
# Side-by-side compare the output of 2 xslt stylesheets to find errors
# introduced while refactoring.
#
# Usage:
#   meld-driver-transcript.sh ID
#

REMOTE_CACHE="$CAPITULARIA_REMOTE_FS/cap/publ/cache"
LOCAL_CACHE="$CAPITULARIA_PRJ/cache"

ID=$1

#ID="paris-bn-lat-9654"
#ID="wolfenbuettel-hab-blankenb-130"
#ID="gotha-flb-memb-i-84"
#ID="paris-bn-lat-4628a"
#ID="newhaven-bl-413"
#ID="berlin-sb-phill-1737"
#ID="muenchen-bsb-lat-3853"
#ID="vatikan-bav-chigi-f-iv-75"
#ID="paris-bn-lat-4631"
#ID="ivrea-bc-xxxiv"

#HTML1="/afs/rrz.uni-koeln.de/vol/www/projekt/capitularia/http/docs/cap/publ/cache/mss/$ID.transcript.html"
HTML1="$REMOTE_CACHE/mss/$ID.transcript.html"
HTML2="$LOCAL_CACHE/mss/$ID.transcript.html"

cd xslt
CACHE_DIR="$LOCAL_CACHE" make -e -r $HTML2 || exit 1

Q='"'

SED="sed -E -e s|id=$Q[-0-9a-z]+$Q|id=XXX|g -e s|<span.class=$Q.enerated$Q></span>||g -e s|<span></span>||g -e s|index.tei-hi|index|g -e s!\s?rend-(glossa|nota)!!g"

# echo $SED

PP="php -f $CAPITULARIA_PRJ/plugins/cap-file-includer/post-process-cli.php"

LINT="tidy -q -ashtml -utf8 -i -w 120 --drop-empty-elements no --sort-attributes alpha"
#LINT="xmllint --encode utf-8 --format"

meld <(cat $HTML1 | $SED | $LINT) \
     <(cat $HTML2 | $SED | $LINT)

cd ..
