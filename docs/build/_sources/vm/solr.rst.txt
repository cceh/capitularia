.. _solr:

SOLR
====

SOLR is a full-text search engine built on top of Apache Lucene.
We use it to search the manuscripts and the Wordpress content.

A nightly cron of :program:`server/import_solr.py` harvests following sources and indexes
them into SOLR:

- the TEI XML files <front> (as category:front)
- the TEI XML files <body> (as category:chapter)
- the Wordpress pages (as category:post)

The wordpress `cap-meta-search`-plugin queries the SOLR database through the python
application server and presents the results to the user.

.. seealso::

    - :ref:`fulltext-search-overview`


Installation
------------

.. code-block:: bash

    mkdir -p ~/solr
    cd ~/solr
    wget https://dlcdn.apache.org/solr/solr/9.6.1/solr-9.6.1.tgz
    tar -xzf *.tgz
    ln -s solr-9.6.1 solr

    sudo systemctl enable solr
    sudo systemctl start solr

    cd ~/prj/capitularia/capitularia
    make solr-init
    make solr-import


Service
-------

SOLR runs as systemd service :file:`/etc/systemd/system/solr.service`

Start with :program:`systemctl start solr`

Stop with :program:`systemctl stop solr`


Icinga
------

SOLR can be monitored through :program:`/usr/local/lib/nagios/plugins/check_solr.py -P -H localhost`
