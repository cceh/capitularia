Wordpress Installation
======================

The Wordpress installation in the Capitularia VM.

The installation resides in the directory:
:file:`/var/www/capitularia.uni-koeln.de/`.

The web server has no write permission to the file system, so you cannot update
Wordpress from the dashboard.  To update Wordpress, change into the installation
directory and use the command :program:`wp` like this:

.. code:: shell

   cd /var/www/capitularia.uni-koeln.de
   ./wp cli update
   ./wp core update
   ./wp theme update --all
   ./wp plugin update --all
