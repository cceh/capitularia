.. _backup:

TSM Backup
==========

The Capitularia VM is backed up to the TSM service offered by the RRZK.
The node name is: :code:`MPERATHO.CAPITULARIA` on the server :code:`TSM6`.

The full configuration data is in the directory :file:`/opt/tivoli/tsm/client/ba/bin/`
in the files :file:`dsm.opt` and :file:`dsm.sys`.

An incremental backup is started by cron.daily which calls
:program:`/root/backup.sh`.  This script makes a dump of the databases and of the
published manuscripts before backing up the whole filesystem.  Past dumps are
kept on a daily, weekly, montly and yearly basis in subdirectories of :file:`/var/backup/`.

Logfiles: :file:`/var/log/dsmerror.log` and :file:`/var/log/dsminstr.log`.

To manually start a backup:

.. code:: bash

   sudo /root/backup.sh

To backup files or directories:

.. code:: bash

   sudo dsmc selective /var/backup/mysqldump.sql
   sudo dsmc selective /var/backup/
   sudo dsmc selective /var/backup/ -subdir=yes

To get a list of backed up files:

.. code:: bash

   sudo dsmc query backup /var/backup/

To restore a file to the same location:

.. code:: bash

   sudo dsmc restore /var/backup/mysqldump.sql
   sudo dsmc restore /home/joe/deleted_file.txt -latest

To restore a file to a different location:

.. code:: bash

   sudo dsmc restore /var/backup/mysqldump.sql /var/backup/mysqldump_copy.sql


Update
------

To manually update the TSM client (replace 8.1.15.1 with the new version):

.. code:: bash

   wget http://ftp.software.ibm.com/storage/tivoli-storage-management/patches/client/v8r1/Linux/LinuxX86_DEB/v8115/8.1.15.1-TIV-TSMBAC-LinuxX86_DEB.tar
   tar -xvf 8.1.15.1-TIV-TSMBAC-LinuxX86_DEB.tar

   sudo dpkg -i tivsm-api64.amd64.deb
   sudo dpkg -i tivsm-ba.amd64.deb
   sudo dpkg -i tivsm-apicit.amd64.deb
   sudo dpkg -i tivsm-bacit.amd64.deb
   sudo systemctl restart dsmcad.service
   sudo systemctl status dsmcad.service


.. seealso::

   - https://www.ibm.com/docs/en/spectrum-protect/8.1.14?topic=data-backing-up-using-command-line
   - https://www.ibm.com/docs/en/spectrum-protect/8.1.14?topic=data-command-line-restore-examples
   - https://rrzk.uni-koeln.de/sites/rrzk/Daten_speichern_teilen_verwalten/TSM/20180813_ISP-Ubuntu-installationsanleitung.pdf
