==============
 Introduction
==============

Introduction to the Capitularia Website  Project.


Platforms
=========

The project uses three main platforms:

- the RRZK WebProject (https://capitularia.uni-koeln.de),
- the Capitularia VM  (https://api.capitularia.uni-koeln.de),
- the AFS Filesystem  (/afs/rrz.uni-koeln.de/vol/www/projekt/capitularia/)

.. uml::
   :align: center
   :caption: Main components of the project

   skinparam backgroundColor transparent
   skinparam DefaultTextAlignment center
   skinparam componentStyle uml2

   cloud "RRZK WebProject" {
     rectangle "Apache" as apache {
       component "Wordpress" as wp
     }
     database  "Database\n(mysql)"   as mysql
   }

   cloud "Capitularia VM" {
     component "App Server\n(Python+Flask)"   as api
     database  "Database\n(Postgres)"   as db
   }

   cloud "AFS Filesystem" {
     database "Files" as afs
   }

   wp    <->  api
   wp    <--> afs
   api   <--> afs

   api   <-> db

   mysql <-> wp


The Apache web server runs the Wordpress app and serves static files.  We wrote
a Wordpress theme and many :ref:`Wordpress plugins <plugins>` to add the
functionality we needed for our project.  As it got harder to implement all that
as plugins we moved part of that functionality onto an application server on
a VM.

The Capitularia VM is a root VM on which we installed recent software.  It runs
the Postgres database and the :ref:`Python application server <app-server>`.
Next to that it hosts a recent OpenJDK, Saxon and a
:ref:`customized version of CollateX <custom-collatex>`.

The application server does :ref:`collations <collation-tool>` and
:ref:`metadata and fulltext search <meta-search>` in the capitulars.  The
database holds manuscript metadata and the pre-processed text of every chapter
in every manuscript.

The AFS Filesytem holds the manuscript files (and other project files.)  It is
accessible from the VM and the Apache web server.  Also the editors have direct
access to it through ssh.


Components
==========

- Website
- Meta Search
- Collation Tool
- Page Generator
