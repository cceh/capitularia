.. _transformations:

XSLT Transformations
====================

The transformations used to produce HTML from TEI.

The XSLT stylesheets were first written in XSLT 1 for historical reasons.  We
are currently (Feb. 2020) rewriting them in XSLT 3.  XSLT 3 transformation is
done with Saxon.  XSLT 1 transformation is done with xsltproc.

See also the overview: :ref:`html-generation`.


Capitulary Pages
----------------

.. pic:: xslt_dep_html

   capit.xsl


Manuscript Pages
----------------

.. pic:: xslt_dep_html

   mss-header.xsl
   mss-transcript.xsl
   mss-footer.xsl


Lists of Capitularies
---------------------

.. pic:: xslt_dep_html

   capit-list.xsl


Lists of Manuscripts
--------------------

.. pic:: xslt_dep_html

   mss-table.xsl
   mss-capit.xsl
   mss-idno.xsl
   mss-key.xsl


Other Lists
-----------

.. pic:: xslt_dep_html

   bib-bibliography.xsl
   changes.xsl
   downloads.xsl


Other Transformations
---------------------

.. pic:: xslt_dep_html

   corpus.xsl
   mss-extract-chapters.xsl
   mss-transcript-with-comments.xsl


Stylesheet Dependencies
-----------------------

.. pic:: xslt_dep_dot

   *.xsl
