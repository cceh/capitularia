.. _user:

Users of the VM
===============

Each editor is a user on the VM.
The username is the same as the username of the UniKim account.

Users must access the VM by SSH, WinSCP, etc. using their UniKim account's username and
password.

Example:

.. code:: bash

   ssh meckhart@capitularia.uni-koeln.de


Users and Groups
----------------

User ``capitularia``
   The admin user for this project.  This user must have read/write access to all files.

   The application server is installed under this user's home directory. The XSLT
   transformations are also there. This user

   - owns the Apache DocumentRoot directory for the Capitularia web site,
   - runs the cron jobs to transform TEI files into HTML,
   - runs scripts on demand to bulk-edit TEI files (also in editors' private directories)

Group ``capitularia``
   The group of the project admin user.

User ``<editor>``
   Personal user account for each editor.

Group ``capitularia-editors``
   All editors are members of this group.

User ``www-data``
   The web server. Must have read access to :file:`cap/publ/`.

Directory :file:`cap/publ/`
   All editors have read/write access through group ``capitularia-editors``.

Directory :file:`cap/intern/`
   All editors have read/write access through group ``capitularia-editors``.

Directory :file:`cap/intern/InArbeit/<editor>`
   Semi-private directories owned by the the editor.
   All editors have read/write access to all these directories
   through group ``capitularia-editors``.

Groups for user:

=========== ================================
User        Groups
=========== ================================
capitularia capitularia, capitularia-editors
<editor>    <editor>, capitularia-editors
=========== ================================

ACL permissions for users:

==================== ======== ========== ============================
User                 cap/publ cap/intern cap/intern/InArbeit/<editor>
==================== ======== ========== ============================
capitularia          rwx      rwx        rwx
www-data             r-x
==================== ======== ========== ============================

ACL permissions for groups:

==================== ======== ========== ============================
Group                cap/publ cap/intern cap/intern/InArbeit/<editor>
==================== ======== ========== ============================
capitularia          rwx      rwx        rwx
capitularia-editors  rwx      rwx        rwx
==================== ======== ========== ============================

To see ACLs for the current directory, say:

.. code:: bash

   getfacl .

An example of how to set ACLs:

.. code:: bash

   setfacl -R -m u:www-data:rX,g:capitularia-editors:rwX,o::- <dir>


Adding a New User
-----------------

To add a new user to the VM (needs root):

.. code:: bash

   sudo ~root/add_capitularia_user.sh <username>

Each user should also have a semi-personal subdirectory in: :file:`cap/intern/InArbeit/`.
They can create that themselves.


Security
--------

The users are authenticated by the RRZK Kerberos system through PAM and the pam_krb5
module.  For particulars see the voice: "Zugang zu Gast-VM (debian) mit UniKim-Account"
in the internal CCeH wiki.
