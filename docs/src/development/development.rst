Assorted Development Tips
=========================

This variable tells the :file:`Makefile` where your dev directory is:

.. code-block:: bash

  CAPITULARIA_PRJ=~/dev/capitularia


Configure your development environment in :file:`xslt/xslt.config.mak`.  This will
direct make to build files in the local cache and not on the server.

.. code-block:: bash

    bin/mount-sshfs-ntg


Download TEI manuscripts and capitulary files to the develpment machine:

.. code-block:: bash

    make import_xml
