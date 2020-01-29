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

.. pic:: uml
   :caption: Overview of Capitularia

   skinparam backgroundColor transparent
   skinparam DefaultTextAlignment center
   skinparam componentStyle uml2

   cloud "RRZK WebProject" {
     database  "Database\n(mysql)"   as mysql
     rectangle "Apache" as apache {
       component "Wordpress" as wp
     }
   }

   cloud "Capitularia VM" {
     component "App Server\n(Python+Flask)" as api
     database  "Database\n(Postgres)"       as db
   }

   cloud "AFS Filesystem" {
     database "Cache" as cache
     database "Files" as files
   }

   mysql <-> wp
   wp    <-> api
   api   <-> db

   wp    <-- cache
   api   <-- cache
   files ->  cache

The :ref:`RRZK Web Projekt <webprojekt>` is a package offered by RRZK and
consists of an Apache web server and a :ref:`mysql database <mysql>`.  Apache
runs a Wordpress installation.  We wrote a Wordpress :ref:`theme <theme>` and
:ref:`plugins <plugins>` to add the functionality we needed for our project.

As it got too hard to implement all functionality in plugins, we moved a part of
it onto an application server on a VM.

The :ref:`Capitularia VM <vm>` is a root VM.  It runs a :ref:`Postgres database
<db>` server and the :ref:`Python application server <app-server>`.  Next to
that it hosts a recent OpenJDK, Saxon and a :ref:`customized version of CollateX
<custom-collatex>`.

The application server :ref:`generates the HTML files <HTML-generation>` of the
TEI manuscripts.  It also does :ref:`collations <collation-tool-overview>` and
offers :ref:`metadata and fulltext search <meta-search-overview>` in the
Capitulars.  The Postgres database holds manuscript metadata and the
pre-processed text of every chapter in every manuscript.

The AFS Filesystem holds all the original manuscript files encoded in TEI and
versions thereof :ref:`converted to HTML <HTML-Generation>`.  It is accessible
from the VM and the Webprojekt.  The editors also have access to it through ssh.
