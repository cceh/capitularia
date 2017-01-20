#!/bin/bash
#

ROOT="/afs/rrz/vol/www/projekt/capitularia/http/docs/cap/publ"

MYSQL_LIST="capit/lists/capit_mysql.xml"
CAPIT_LIST="capit/lists/capit_all.xml"

cd "$ROOT"

mysql --xml -e "select post_title, meta_value from wp_posts, wp_postmeta where post_id = ID and meta_key = 'tei-xml-id' and post_status = 'publish' order by meta_value" > "$MYSQL_LIST"

xsltproc --stringparam path "../$MYSQL_LIST" transform/Add-Corresp-To-Capit-List.xsl "$CAPIT_LIST" > "$CAPIT_LIST".new
mv -b "$CAPIT_LIST".new "$CAPIT_LIST"

saxon -xsl:transform/Kapitularienseiten_generieren.xsl -s:"$CAPIT_LIST"
