.. _collation-tool-troubleshooting:


Troubleshooting the Collation Tool
==================================

Manuscripts do not show up
--------------------------

Manuscripts that contain a certain chapter do not show up in the collation tool
when that chapter is selected.

This command rebuilds all intermediate files and re-imports them into the
database.  (But will not clear surplus entries in the database.)

Warning: Takes a long time to run.

.. code:: shell

   ssh capitularia@capitularia.uni-koeln.de

.. code:: shell

   cd ~/prj/capitularia/capitularia/xslt
   solo -port=6666 make -B -k -r -j 4 corpus fulltext scrape_fulltext
