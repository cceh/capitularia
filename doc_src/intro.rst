==============
 Introduction
==============

Introduction to the Capitularia Digital Edition.

The project runs on two hardware platforms:

.. pic:: pic
   :caption: Capitularia platforms

   VM:  circle component wid 1 "Capitularia" "VM"  at (0, 0)
   AFS: circle component same  "AFS"               at (2, 0)
   line <-> from VM to AFS chop 0.5


Capitularia VM
==============

The :ref:`Capitularia VM <vm>` is a root VM offered by the RRZK.

The VM hosts an Apache Web Server at https://capitularia.uni-koeln.de which
runs a Wordpress installation.  We wrote a Wordpress :ref:`theme <theme>`
and many :ref:`plugins <plugins>` to add the functionality we needed for our
project.

The VM runs a :ref:`Postgres database <db>` server and the :ref:`Python
application server <app-server>`.  Next to that it hosts a recent OpenJDK, Saxon
and a :ref:`customized version of CollateX <custom-collatex>`.

We use the application server and its API (at
https://api.capitularia.uni-koeln.de) for all functionality that is too
inconvienent to implement in Wordpress plugins.

.. pic:: pic
   :caption: Capitularia VM Components

   down
   VM: [
      "Capitularia VM"
      move 0.3

      A: [
         Apache: "Apache / PHP"
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
      ]
      Ae: box wid A.wid + 0.2 ht A.ht + 0.2 with .c at A.c

      S: [
         "Saxon"
         move 0.1
         XSLT1: box component "XSLT"
         move 0.05
         XSLT2: box component "XSLT"
         move 0.05
         XSLT3: box component "..."
      ] with .nw at A.ne + (0.5, 0)
      Se: box wid S.wid + 0.2 ht S.ht + 0.2 with .c at S.c

      P: [
         "Python App Server"
         move 0.1
         APP1: box component wid 1.7 "Collation Server"
         move 0.05
         APP2: box component same "Data Server"
         move 0.05
         APP3: box component same "..."
      ] with .nw at S.ne + (0.5, 0)
      Pe: box wid P.wid + 0.2 ht P.ht + 0.2 with .c at P.c

      Make:     box component         "Makefile"        with .c at S.XSLT3.c - (0, 1)
      CollateX: box component wid 1.7 "Custom CollateX" with .c at P.APP3.c  - (0, 1)

      Mysql: db() with .n at A.s - (0, 0.3)
      "mysql" "Database" at Mysql.Caption

      PG: db() with .c at (1/2 <S.se, P.sw>, Mysql.c)
      "Postgres" "Database" at PG.Caption
   ]
   box dashed wid VM.wid + 0.4 ht VM.ht + 0.4 with .c at VM.c


Many different :ref:`XSLT transformations <transformations>` are used to
:ref:`generate the HTML files <HTML-generation>` of the TEI manuscripts and also
many auxiliary files like lists of capitularies ans manuscripts.

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
from the VM.  The editors also have access to it through ssh.
