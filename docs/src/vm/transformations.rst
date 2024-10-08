.. _transformations:

XSLT Transformations
--------------------

.. contents::
   :local:

The transformations used to produce HTML from TEI.

The xslt files reside at :file:`~capitularia/prj/capitularia/capitularia/xslt/`.
The transformations are driven by the :file:`Makefile` in that directory.

The XSLT stylesheets were first written in XSLT 1 because the WebProjekt setup
by the RRZK offered only an XSLT 1 processor (xsltproc through PHP).

After adding a VM to the Capitularia project and installing Saxon-HE on it we
rewrote all the stylesheets in XSLT 3.  (Rewrite completed in June 2020.)

.. seealso::

    - :ref:`html-generation-overview`
    - :ref:`makefile`

These graphs were generated by the tool :program:`python/xslt_dep.py`.


Graph of All Transformations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. minilang:: xslt_dep_dot

   update INSERT DATA { <http://capitularia.uni-koeln.de/$(CACHE_DIR)/lists/corpus.xml> cap:constraint "false" }
   update INSERT DATA { <http://capitularia.uni-koeln.de/$(CACHE_DIR)/extracted/%.xml> cap:constraint "false" }
   io
   dot


Graph of Stylesheet Dependencies
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. minilang:: xslt_dep_dot

   dep
   dot
