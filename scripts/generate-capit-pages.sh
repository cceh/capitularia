#!/bin/bash
#

ROOT="/afs/rrz/vol/www/projekt/capitularia/http/docs/cap/publ"

MYSQL_LIST="capit/lists/capit_mysql.xml"
CAPIT_LIST="capit/lists/capit_all.xml"

cd "$ROOT"

mysql --xml -e "SELECT post_title, meta_value FROM wp_posts, wp_postmeta WHERE post_id = ID AND meta_key = 'tei-xml-id' AND post_status IN ('publish', 'private') ORDER BY meta_value" > "$MYSQL_LIST"

xsltproc --stringparam path "../$MYSQL_LIST" transform/Add-Corresp-To-Capit-List.xsl "$CAPIT_LIST" > "$CAPIT_LIST".new
mv -b "$CAPIT_LIST".new "$CAPIT_LIST"

saxon -xsl:transform/Kapitularienseiten_generieren.xsl -s:"$CAPIT_LIST"
