==============
 Introduction
==============

Introduction to the Capitularia Digital Edition.

The project runs on three hardware platforms:


RRZK Web Projekt
================

An :ref:`RRZK Web Projekt <webprojekt>` (https://capitularia.uni-koeln.de) is a
standard web hosting package offered by RRZK.

The :ref:`RRZK Web Projekt <webprojekt>` is a package offered by RRZK and
consists of an Apache web server and a :ref:`mysql database <mysql>`.  Apache
runs a Wordpress installation.  We wrote a Wordpress :ref:`theme <theme>` and
:ref:`plugins <plugins>` to add the functionality we needed for our project.

.. pic:: pic
   :caption: RRZK Webprojekt Components

   down
   RRZK: [
      "RRZK Webprojekt"
      move 0.3
      WP: [
         "Wordpress"
         move 0.1
         PF: box component wid 1.7 "Capitularia Theme"
         move 0.1
         PF: box component wid 1.7 "File Include Plugin"
         PC: box component same "Collation Plugin"
         PS: box component same "Meta Search Plugin"
         PG: box component same "Page Generator Plugin"
         PD: box component same "Dynamic Menu Plugin"
      ]
      WPe: box wid WP.wid + 0.2 ht WP.ht + 0.2 with .c at WP.c
      Mysql: db() with .n at WP.s - (0, 0.3)
      "mysql" "Database" at Mysql.Caption
   ]
   box dashed wid RRZK.wid + 0.4 ht RRZK.ht + 0.4 with .c at RRZK.c



Capitularia VM
==============

The :ref:`Capitularia VM <vm>` (https://api.capitularia.uni-koeln.de) is a root
VM also offered by the RRZK.  We use the VM for all functionality that is too
inconvienent to implement in Wordpress plugins and for all software lacking in
the Webprojekt package.

The VM runs a :ref:`Postgres database <db>` server and the :ref:`Python
application server <app-server>`.  Next to that it hosts a recent OpenJDK, Saxon
and a :ref:`customized version of CollateX <custom-collatex>`.

.. pic:: pic
   :caption: Capitularia VM Components

   down
   VM: [
      "Capitularia VM"
      move 0.3
      Make:     box component "Makefile"
      move 0.5
      A: [
         "Saxon"
         move 0.1
         XSLT1: box component "XSLT"
         move 0.05
         XSLT2: box component "XSLT"
         move 0.05
         XSLT3: box component "..."
      ]
      XSLT: box wid A.wid + 0.2 ht A.ht + 0.2 with .c at A.c

      CollateX: box component wid 1.7 "Custom CollateX" with .w at Make.e + (0.5, 0)

      B: [
         "Python App Server"
         move 0.1
         APP1: box component wid 1.7 "Collation Server"
         move 0.05
         APP2: box component same "Data Server"
         move 0.05
         APP3: box component same "..."
      ] with .w at A.e + (0.5, 0)
      APP: box wid B.wid + 0.2 ht B.ht + 0.2 with .c at B.c

      PG: db() with .n at 1/2 <A.se, B.sw> - (0, 0.3)
      "Postgres" "Database" at PG.Caption

      # arrow from XSLT.s to PG.E.c
      # arrow to APP.s
   ]
   box dashed wid VM.wid + 0.4 ht VM.ht + 0.4 with .c at VM.c


The XSLT transformations :ref:`generate the HTML files <HTML-generation>` of the
TEI manuscripts.

The Postgres database holds manuscript metadata and the pre-processed text of
every chapter in every manuscript.

The app server does :ref:`collations <collation-tool-overview>` and offers
:ref:`metadata and fulltext search <meta-search-overview>` in the Capitulars.


AFS
===

The AFS Filesystem (/afs/rrz.uni-koeln.de/vol/www/projekt/capitularia/) is a
network filesystem.

.. pic:: pic
   :caption: AFS Components

   down
   AFS: [
   "AFS"
   move 0.3
   TEI:  db()
   HTML: db() with .w at TEI.e + (0.5, 0)
   "TEI Files" at TEI.Caption
   "HTML Files" at HTML.Caption
   ]
   box dashed wid AFS.wid + 0.4 ht AFS.ht + 0.4 with .c at AFS.c

The AFS Filesystem holds all the original manuscript files encoded in TEI and
versions thereof :ref:`converted to HTML <HTML-Generation>`.  It is accessible
from the VM and the Webprojekt.  The editors also have access to it through ssh.
