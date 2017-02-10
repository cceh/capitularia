#!/bin/bash

#- alle @corresp in ab meta-text, die zwischen einem milestone
#- unit="capitulatio" und dem anchor "capitulatio_fins" (evtl. mit
#- Namenserweiterungen wie _1, _2 etc.) bzw. dem folgenden milestone stehen und
#- deren Wert KEIN "_c" enthält.

for i in ~/uni/capitularia/http/docs/cap/publ/mss/*.xml
do
    xmlstarlet sel -N tei='http://www.tei-c.org/ns/1.0' -t -m "//tei:milestone[@unit='capitulatio']" -m "following::tei:ab[@type='meta-text' and @corresp and not (contains (@corresp, '_c'))][following::tei:anchor[@xml:id=substring (current()/@spanTo, 2)]]" -f -v "' '" -v '@corresp' -n $i | cut -d '/' -f 11

    xmlstarlet sel -N tei='http://www.tei-c.org/ns/1.0' -t -m "//tei:milestone[@unit='capitulatio'][not (@spanTo)]" -f -v "' capitulatio ohne spanTo '" -v '@xml:id' -n $i | cut -d '/' -f 11
done
