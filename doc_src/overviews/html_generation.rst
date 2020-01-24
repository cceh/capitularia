.. _html-generation:

HTML Generation
===============

All TEI manuscript files are converted to one (or more) HTML files.  The HTML
files are then included into Wordpress pages with the :ref:`File Includer
plugin<file-includer>`.

XSLT Transformations
--------------------

.. uml::
   :align: center
   :caption: Data flow during HTML generation

   skinparam backgroundColor transparent
   skinparam DefaultTextAlignment center
   skinparam componentStyle uml2

   database  "Manuscript files\n(XML+TEI)" as tei
   note left of tei: AFS:publ/mss

   cloud "Capitularia VM" as vm {
     component "Cron"                       as cron
     component "Makefile"                   as make
     component saxon [mss-header.xsl
     mss-transcription.xsl
     mss-footer.xsl]
   }

   database  "Manuscript files\n(HTML)"   as html
   note left of html: AFS:publ/cache/mss

   tei      --> saxon
   saxon    --> html

   cron .> make
   make .> saxon


The Makefile is run by cron on the Capitularia VM at regular intervals.

The manuscript and HTML files reside in the AFS.  The AFS is mounted onto
the VM.

The Makefile knows all the dependencies between the files and runs the
appropriate tools to keep the HTML files up-to-date with the manuscript files.

The HTML files are stored in the cache directory.

.. note::

   The XSLT stylesheets are written in XSLT 1 for historical reasons.  That is
   why we still use xsltproc.  We plan to rewrite them in XSLT 3 and use Saxon
   as soon as possible. (Nov. 2019)


User Delivery
-------------

.. uml::
   :align: center
   :caption: Data flow during user access

   skinparam backgroundColor transparent
   skinparam DefaultTextAlignment center
   skinparam componentStyle uml2

   database "Manuscript files\n(HTML)" as html
   note left of html: AFS:publ/cache/mss

   cloud "RRZK WebProjekt" {
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

   The Footnotes Post-Processor is still written in PHP.  We plan to rewrite it
   in Python along with the XSL stylesheets and move it to the VM. (Nov. 2019)