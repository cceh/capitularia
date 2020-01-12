Wordpress Installation
======================

The Wordpress installation in the RRZK Webprojekt.

The installation resides in the directory:
:file:`/afs/rrz.uni-koeln.de/vol/www/projekt/capitularia/http/docs/`.

The web server has no write permission to the file system, so you cannot update
Wordpress from the dashboard.  To update Wordpress, change into the installation
directory and use the command :program:`wp` like this:

.. code:: shell

   cd /afs/rrz.uni-koeln.de/vol/www/projekt/capitularia/http/docs/
   ./wp core update
