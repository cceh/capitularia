.. _database:

Database Structure
==================


Schema *capitularia:*
---------------------

.. Palette https://github.com/d3/d3-scale-chromatic/blob/master/src/categorical/Paired.js

.. pic:: sauml -i manuscripts -i msparts -i capitularies -i chapters -i mn_mss_capitularies
               -i mss_chapters -i mss_chapters_text
   :caption: Schema *capitularia*
   :align: center

.. { rank=same; manuscripts, capitularies }


Schema *gis:*
-------------

.. pic:: sauml -s gis
   :caption: Schema *gis*
   :align: center


db.py
-----

.. automodule:: db
   :members:
