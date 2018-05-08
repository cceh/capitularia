#!/bin/bash
#
# replace path of relax-ng and schematron files
#

ROOT="http://capitularia.uni-koeln.de/cap/publ/schemata"

. scripts/env

for i in $PUBL $INARBEIT
do
    echo "$i"
    # -0777 == slurp files whole
    perl -0777 -p -i.86-backup -e "s!<\?xml-model .*?\?>\s*!!sgu" "$i"
    perl -0777 -p -i -e "s!<TEI !<?xml-model href=\"$ROOT/capitularia-msDesc-Transcription.rnc\" type=\"application/relax-ng-compact-syntax\"?>
<?xml-model href=\"$ROOT/capitularia.sch\" type=\"application/xml\"
schematypens=\"http://purl.oclc.org/dsdl/schematron\"?>

<TEI !sgu" "$i"
done
