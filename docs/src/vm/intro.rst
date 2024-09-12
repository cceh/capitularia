============
Introduction
============

The Capitularia VM is a root virtual machine offered by the RRZK.
It runs debian stable.

The VM hosts an :ref:`Apache Web Server<apache>` at https://capitularia.uni-koeln.de
which runs :ref:`Wordpress <wordpress>`.

The VM also hosts an :ref:`application server <app-server>` written in Python.  Next to
that it hosts Saxon and :ref:`Solr <solr>` with the Java OpenJDK 17.

The VM also hosts a :ref:`Postgres database <postgres-database>` server for the
application server and a :ref:`mysql database <wordpress-database>` server for
Wordpress.

We wrote a :ref:`Wordpress theme <wordpress-theme>` and many :ref:`Wordpress plugins
<wordpress-plugins>` to add the functionality we needed for our project.  We use the
application server (and its API at https://api.capitularia.uni-koeln.de) for all
functionality that is too inconvenient to implement in Wordpress plugins.

.. minilang:: pic
   :caption: Main Components of the Capitularia VM

   down
   VM: [
      "Capitularia VM"
      move 0.3

      A: [
         Apache: "Apache"
         move 0.3
         WP: [
            "Wordpress / PHP"
            move 0.1
            TH: box component wid 1.7 "Capitularia Theme"
            move 0.15
            PL: box component wid 1.7 "Library Plugin"
            move 0.05
            PF: box component same "File Include Plugin"
            move 0.05
            PC: box component same "Collation Plugin"
            move 0.05
            PS: box component same "Meta Search Plugin"
            move 0.05
            PG: box component same "Page Generator Plugin"
            move 0.05
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
         XSLT3: box component "XSLT"
         move 0.05
         XSLT4: box component "..."
      ] with .nw at A.ne + (0.5, 0)
      Se: box wid S.wid + 0.2 ht S.ht + 0.2 with .c at S.c

      P: [
         "App Server / Python"
         move 0.1
         APP1: box component wid 1.7 "Collation Server"
         move 0.05
         APP2: box component same "Data Server"
         move 0.05
         APP2: box component same "Solr Server"
         move 0.05
         APP4: box component same "..."
      ] with .nw at S.ne + (0.5, 0)
      Pe: box wid P.wid + 0.2 ht P.ht + 0.2 with .c at P.c

      box component "Makefile"        with .c at (S.c, A.WP.PS.c)
      box component "TSM backup"      with .c at (S.c, A.WP.PD.c)

      Mysql: db() with .n at A.s - (0, 0.3)
      "mysql" "Database" at Mysql.Caption

      PG: db() with .c at (S.c, Mysql.c)
      "Postgres" "Database" at PG.Caption

      Files: db() with .c at (P.c, A.WP.PG.c)
      "Files" at Files.Caption

      Solr: db() with .c at (P.c, Mysql.c)
      "Solr" "Database" at Solr.Caption
   ]
   box dashed wid VM.wid + 0.4 ht VM.ht + 0.4 with .c at VM.c


Many different :ref:`XSLT transformations <transformations>` are used to
:ref:`generate the HTML files <html-generation-overview>` of the TEI manuscripts and also
many auxiliary files like lists of capitularies and manuscripts.
The transformations are driven by :program:`make` and the :file:`Makefile`.

The :ref:`Postgres database <postgres-database>` holds manuscript metadata and the
pre-processed text of every chapter in every manuscript.

The app server does :ref:`collations <collation-tool-overview>` and offers
:ref:`metadata and fulltext search <fulltext-search-overview>` in the Capitulars.

There is a nightly :ref:`TSM backup <backup>` of the whole VM.
The TEI files and the databases are dumped and kept in multiple versions.

The editors store the original manuscript files encoded in TEI in the VM filesystem.
The TEI files are then :ref:`converted to HTML <html-generation-overview>`.
