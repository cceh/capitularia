#!/bin/bash

# Count `difficult´ constructs in the TEI input files

FILES=/home/highlander/uni/capitularia/http/docs/cap/publ/mss/*.xml
SEL="xmlstarlet sel -N tei=http://www.tei-c.org/ns/1.0"

echo `ls $FILES | wc -l` files

for i in //tei:add //tei:del //tei:subst //tei:abbr //tei:expan //tei:choice \
                   //tei:add//tei:choice //tei:del//tei:choice //tei:subst//tei:choice \
                   //tei:abbr//tei:add //tei:abbr//tei:del \
                   //tei:expan//tei:add //tei:expan//tei:del \
                   //tei:add//tei:add //tei:add//tei:del \
                   //tei:del//tei:add //tei:del//tei:del
do
    echo "$i" `$SEL -t -m "$i" -f -n $FILES | wc -l`
    # echo $SEL -t -m "$i" -f -n "$FILES"
done
