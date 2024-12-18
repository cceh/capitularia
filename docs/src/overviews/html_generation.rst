.. _html-generation-overview:

HTML Generation Overview
========================

All TEI manuscript files are converted to one (or more) HTML files.  The HTML
files are then included into Wordpress pages with the :ref:`File Includer
plugin<file-includer>`.

XSLT Transformations
--------------------

.. minilang:: uml
   :caption: Data flow during HTML generation

   database  "Manuscript files\n(XML+TEI)" as tei
   note left of tei: publ/mss

   cloud "Capitularia VM" as vm {
     component "Cron"                       as cron
     component "Makefile"                   as make
     component saxon [mss-header.xsl
     mss-transcription.xsl
     mss-footer.xsl]
   }

   database  "Manuscript files\n(HTML)"   as html
   note left of html: publ/cache/mss

   tei      --> saxon
   saxon    --> html

   cron .> make
   make .> saxon


The :file:`Makefile` is run by cron on the Capitularia VM at regular intervals.

The :file:`Makefile` knows all the `dependencies <makefile>`_ between the files and runs
the appropriate tools to keep the HTML files up-to-date with the manuscript files.

The HTML files are stored in the cache directory.


User Delivery
-------------

.. minilang:: uml
   :align: center
   :caption: Data flow during user access

   database "Manuscript files\n(HTML)" as html
   note left of html: publ/cache/mss

   cloud "Apache" {
     database  "Database\n(mysql)" as db
     rectangle "Wordpress" {
       component "Footnotes\nPost-Processor\n(PHP)" as pp
       component "File Includer Plugin\n(PHP)" as fi
     }
   }
   component "User-Agent" as client

   html  --> pp
   pp    --> fi
   fi    --> client

   db    -> fi
   db    <- fi


When a user accesses a manuscript page, Wordpress finds a shortcode for the
:ref:`File Includer plugin<file-includer>` in it.  Control is passed to the File
Includer plugin which checks the date of the filum includendum.  If the file is
newer than the data stored in the database it refreshes the database.  Then it
inserts the file's content into the page, which is finally sent to the user.

.. note::

   The Footnotes Post-Processor is still written in PHP.
   We plan to rewrite it in Python. (Nov. 2019)
