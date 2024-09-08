.. _wordpress-maintenance:


Wordpress Maintenance
=====================

Wordpress Upgrades
------------------

We use the `Wordpress cli tool <https://wp-cli.org/>`_ to upgrade Wordpress.

N.B.: There already is a nightly :ref:`database backup <backup>` running.

Login:

.. code:: shell

   ssh capitularia@capitularia.uni-koeln.de
   cd /var/www/capitularia.uni-koeln.de
   ./wp help

Upgrade the cli tool:

.. code:: shell

   ./wp cli update

Upgrade Wordpress:

.. code:: shell

   ./wp core update
   ./wp theme update --all
   ./wp plugin update --all


qtranslate-xt
~~~~~~~~~~~~~

The plugin `qtranslate-xt <https://github.com/qtranslate/qtranslate-xt>`_ needs manual
update:

.. code:: shell

   cd /var/www/capitularia.uni-koeln.de/wp-content/plugins/
   wget https://github.com/qtranslate/qtranslate-xt/archive/3.6.2.zip
   unzip 3.6.2.zip
   rm 3.6.2.zip

Replace "3.6.2" with the latest version.

Then go to the `Wordpress admin page <https://capitularia.uni-koeln.de/wp-admin/>`_ and
then to :menuselection:`Plugins --> Installed Plugins`, deactivate the old version and
activate the new version of the plugin.


.. seealso::

   - https://github.com/cceh/capitularia/issues/62


wordfence
~~~~~~~~~

The plugin Wordfence needs write access to the location
:file:`/var/www/capitularia.uni-koeln.de/wp-content/wflogs`. The `wp` commandline update
tool also needs access to that location during plugin update.  So both users `www-data`
and `capitularia` have write access to that location.

.. code:: shell

   getfacl wflogs
   # file: wflogs
   # owner: capitularia
   # group: capitularia
   user::rwx
   user:www-data:rwx
   user:capitularia:rwx
   group::r-x
   mask::rwx
   other::r-x
   default:user::rwx
   default:user:www-data:rwx
   default:user:capitularia:rwx
   default:group::r-x
   default:mask::rwx
   default:other::r-x


Restore Database
~~~~~~~~~~~~~~~~

Restore the Wordpress database from the backup.

.. code:: bash

    mysql < /var/backups/mysqldump.backup

Note: The database contains all Wordpress settings.  After restoring the production
database on a developer machine, the Wordpress settings must be adjusted.
