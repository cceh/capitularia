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


Adding a New User
-----------------

To add a new user to the VM (needs root):

.. code:: bash

   sudo ~capitularia/add_capitularia_user.sh <username>

Each user should also have a semi-personal subdirectory in: :file:`cap/intern/InArbeit/`.
They can create that themselves.


Security
--------

The users are authenticated by the RRZK Kerberos system through PAM and the pam_krb5
module.  For particulars see the voice: "Zugang zu Gast-VM (debian) mit UniKim-Account"
in the internal CCeH wiki.