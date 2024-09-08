.. _fulltext-search-overview:

Full-text Search Overview
=========================

Full-text search is provided by the :ref:`Meta Search<meta-search>` Wordpress plugin.
It is implemented with Apache Solr.  Apache Solr is a fulltext search engine based on
Apache Lucene.

.. seealso::

    - :ref:`solr`
    - :ref:`makefile`


Full-text Extraction
~~~~~~~~~~~~~~~~~~~~

There are 3 main categories of text that we index in Solr.

- The Latin text of the capitularies is extracted using
  :file:`mss-extract-chapters-txt.xsl`, stored in the directory
  :file:`publ/cache/collation/` and imported into Solr using the command
  :command:`import_data.py --solr`.  This are the same texts used for the collation
  tool.  The German notes in the capitularies are extracted along with the Latin text.
- The material in the teiHeader and the "editorial preface to the transcription"
  are indexed into Solr using the command :command:`import_solr.py --mss`.
- The Wordpress pages are extracted directly from the Wordpress database
  and indexed into Solr using the command :command:`import_solr.py --wordpress`.

The command for updating the Solr database is: :command:`make solr-import`.

That same command is run nightly by cron.

.. pic:: uml
   :caption: Data flow during text extraction

   database  "Manuscript files\n(TEI)"   as tei
   database  "Extracted chapters\n(TEI)" as chapters
   database  "Wordpress"                 as wp
   database  "Solr"                      as solr

   note top of tei      : publ/mss/*.xml
   note top of chapters : publ/cache/collation/*.xml
   note top of wp       : on mariadb server

   chapters --> solr : import_data.py --solr
   tei      --> solr : import_solr.py --mss
   wp       --> solr : import_solr.py --wordpress


Metadata Extraction
~~~~~~~~~~~~~~~~~~~

We extract the metadata from the manuscript files and store them in the Postgres
database on the Capitularia VM.  The process is similar to the pre-processing
done for the Collation Tool.

.. pic:: uml
   :caption: Data flow during metadata extraction

   database  "Manuscript files\n(TEI)" as tei
   component "Corpus file\n(TEI)"      as corpus
   database  "Database\n(Postgres)"    as db

   note left of tei    : publ/mss/*.xml
   note left of corpus : publ/cache/lists/corpus.xml

   tei    --> corpus : saxon corpus.xml
   corpus --> db     : import_data.py --mss


The :file:`Makefile` is run by cron on the Capitularia VM at regular intervals.

The :file:`Makefile` knows all the `dependencies <makefile>`_ between the files and runs
the appropriate tools to keep the database up-to-date with the manuscript files.

The intermediate file :file:`publ/cache/lists/corpus.xml` contains all (useful) metadata
from all manuscript file but no text.

The :program:`import_data.py` script scans the :file:`corpus.xml` file and imports the
all metadata it finds into the database.


Geodata Extraction
~~~~~~~~~~~~~~~~~~

Geodata is stored in the file :file:`publ/mss/lists/capitularia_geo.xml`.  This file is
periodically processed with :program:`import_data.py --geoplaces` and its content is
stored into the database.  Also the "places" tree in the meta search dialog is built
using this data.


Search
~~~~~~

The flow of a user's search request is as follows:

#. The :ref:`Meta Search<meta-search>` applet on the browser sends the request to the
   Meta Search plugin on the web server.

#. The Wordpress plugin adds the user's permissions (ie. whether she is logged in into
   Wordpress or not) and then sends the search query to the application server.

#. The application server queries the SOLR server.

#. The SOLR server does the actual search and returns the result as JSON.

#. The applet on the browser formats the JSON and displays them to the user.

Searches in the Latin texts of the manuscript bodies are done by stemming and trigram
similarity. Exact results get a boost, so they show up before trigram results. To stem
Latin we wrote `a custom Latin stemmer for
Lucene <https://github.com/cceh/capitularia-lucene-tools>`_.

Searches in Mordek and Wordpress posts use more traditional search methods like
stemming.

.. pic:: uml
    :caption: Components used in searching

    component "Frontend\n(Javascript)" as client

    cloud "VM" {
        component "Wordpress Plugin\n(PHP)" as plugin
        component "API Server\n(Python)"    as api
        database  "SOLR Server\n(Java)"     as solr

        note left of plugin : adds user permissions
        note left of solr   : localhost only
    }

    client --> plugin
    plugin --> api
    api    --> solr


.. pic:: uml
    :caption: Data flow while searching

    participant "Frontend"         as client
    participant "Wordpress Plugin" as plugin
    participant "API Server"       as api
    database    "SOLR Server"      as solr

    client -> plugin : ajax post
    plugin -> api    : with user permissions
    api    -> solr

    solr   -> api    : json
    api    -> plugin : json
    plugin -> client : json
