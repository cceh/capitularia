#!/bin/bash
# apply-transform xslt directory
#   applies xslt to all *.xml files in directory

if [ $# -ne 2 ]
then
    echo "Usage: apply-transform.sh xslfile directory"
    exit 1
fi

XSLT=$1
DIR=$2

for i in `find "$DIR" -maxdepth 1 -name "*.xml"`
do
    TMPFILE=/tmp/$(basename $i)

    xsltproc "$XSLT" "$i" > "$TMPFILE"
    #saxon -xsl:"$XSLT" -s:"$i" > "$TMPFILE"
    if [ "$?" = 0 ]; then
        #cp --backup=numbered "$TMPFILE" "$i"
        echo OK "$i"
    else
        echo ERRORS "$i"
    fi
    #rm "$TMPFILE"
done
