#!/bin/bash

xmlstarlet sel -N tei="http://www.tei-c.org/ns/1.0" -t -m "//tei:*[@corresp and @next]" -i "//tei:*[concat('#', @xml:id) = current()/@next and @corresp != current()/@corresp]" -v "@xml:id" -o " " -v "@corresp" -n ~/uni/capitularia/http/docs/cap/publ/mss/*.xml ~/uni/capitularia/http/docs/cap/intern/Transkriptionen/Transkriptionsauftraege/FertigeTranskriptionen/*.xml | sort | uniq
