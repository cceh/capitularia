.. _app-server:

Application Server
==================

The application server is built with Python and Flask.

The application server resides at :file:`~capitularia/prj/capitularia/capitularia/server/`.
It is started as a systemd service by :file:`/etc/systemd/system/capitularia.service`.

It is composed of these modules:


server
------

The main server module.

.. automodule:: server
   :members:


data_server
-----------

.. automodule:: data_server
   :members:


collatex_server
---------------

.. automodule:: collatex_server
   :members:


geo_server
----------

.. automodule:: geo_server
   :members:


tile_server
-----------

.. automodule:: tile_server
   :members:
