.. _postgres-database:

Postgres Database Structure
===========================


Schema *capitularia:*
---------------------

The teiHeader contains in msDesc/msPart references to capitularies and loci but
no reference to chapters.  The teiHeader includes capitularies not yet
transcribed.  This relation is caught in table `mss_capitularies`.  The map
client uses this relation.

The body contains finer grained references to chapters and loci in the @corresp
and @xml:id, but only for already transcribed material.  This relation is caught
in table `mss_chapters`.  The collation tool uses this relation.

The `mss_chapters_text` table contains the chapter's text preprocessed for the
collation tool.

Note that the relation between the `mss_chapters` and `msparts` tables was
inferred using the loci, because there are no milestones for msParts/msItems in
the body.

Note that the mscap_n of the `mss_capitularies` and `mss_chapters` tables do not
indicate the same concept.


.. Palette https://github.com/d3/d3-scale-chromatic/blob/master/src/categorical/Paired.js

.. minilang:: sauml -i manuscripts -i msparts -i capitularies -i chapters -i mss_capitularies
               -i mss_chapters -i mss_chapters_text
   :caption: Schema *capitularia*
   :align: center
   :svg-width: 100%

.. { rank=same; manuscripts, capitularies }


Schema *gis:*
-------------

Note: the `gis.geonames` table and relatives contain standard hierarchies of place
names, extracted from the geonames, dnb, and viaf databases.

Note: the `gis.geoplaces` table and relatives contain a different, custom hierarchy of
place names, which is the one displayed in the manuscript search box.  This hierarchy is
extracted from the file :file:`mss/lists/capitularia_geo.xml`.  Unfortunately it is
linked to manuscripts and not to manuscript parts.

.. minilang:: sauml -s gis
   :caption: Schema *gis*
   :align: center
   :svg-width: 100%


db.py
-----

.. automodule:: db
   :members:
