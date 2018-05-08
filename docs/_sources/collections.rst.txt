=============
 Collections
=============

We want to find *collections* of capitularies, currently very vaguely defined as
capitularies that are often copied together.

The python script :code:`cluster.py` reads the Wordpress database and writes a
Gephi graph file.  The graph is then imported into Gephi and laid out using a
force field algorithm.  The resulting plot is used to visually identify
potential collections of capitularies.


Algorithm
=========

Description of the algorithm used by the :code:`cluster.py` script.

We define :math:`K` as the number of capitularies and :math:`D` as the number of
documents.

The number of occurrences of capitulary :math:`k` in document :math:`d` is
referred to as :term:`term frequency` and is denoted:

.. math::

   \mbox{tf}_{k,d}

The term frequency of capitularies is either 0 (if not contained in the
document) or 1 (if contained in the document).  Technically, a document may
contain more than one copy of the same capitulary, but we ignore that for our
calculations.

The number of documents that include the capitulary :math:`k` is referred to as
its :term:`document frequency` and is denoted:

.. math::

   \mbox{df}_k

The :term:`inverse document frequency` of capitulary :math:`k` is defined as:

.. math::

   \mbox{idf}_k = \log { D \over \mbox{df}_k }.


We assign a weight to each pair of capitulary and document
:math:`k \times d`, given by:

.. math::

   \mbox{tf-idf}_{k,d} = \mbox{tf}_{k,d} \times \mbox{idf}_k


We define the :term:`document vector` :math:`\vec{V}(d)` as:

.. math::

   \begin{pmatrix} \mbox{tf-idf}_{1,d} & \mbox{tf-idf}_{2,d} & \dots & \mbox{tf-idf}_{K,d} \end{pmatrix}

the vector of the weights of all capitularies relative to the document :math:`d`.


The :term:`Euclidean length` :math:`\vert\vec{V}(d)\vert` of a document vector
:math:`\vec{V}(d)` is defined as:

.. math::

   \sqrt{\sum_{i=1}^K\vec{V}_i^2(d)}

Because the term frequency can only be 0 or 1, this is simply the square root of
the number of capitularies in the document.

The :term:`cosine similarity` of two documents :math:`d_1` and :math:`d_2`,
which are here represented by their document vectors :math:`\vec{V}(d_1)` and
:math:`\vec{V}(d_2)`, is now calculated as:

.. math::

   \mbox{sim}(d_1,d_2)= \frac{\vec{V}(d_1)\cdot \vec{V}(d_2)}{\vert\vec{V}(d_1)\vert \vert\vec{V}(d_2)\vert}

where :math:`\cdot` represents the :term:`dot product`.

The cosine similarities of all pairs of documents are entered into a similarity
(affinity) matrix.  This matrix is used as the input to the graph layout software.

.. raw:: html

   <object data="_images/ms-graph.svg" type="image/svg+xml" align="center" style="width: 100%"></object>

   <p align="center">The document affinity graph (Gephi Force Atlas).</p>

This algorithm is also used to get the similarity between capitularies, instead
of documents, by switching capitularies with documents.

.. raw:: html

   <object data="_images/bk-graph.svg" type="image/svg+xml" align="center" style="width: 100%"></object>

   <p align="center">The capitulary affinity graph (Gephi Force Atlas).</p>
