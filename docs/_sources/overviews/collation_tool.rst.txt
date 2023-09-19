.. _collation-tool-overview:

.. default-role:: math

Overview of the Collation Tool
==============================

This overview describes the `collation tool <https://capitularia.uni-koeln.de/tools/collation/>`_
and the pre-processing of the TEI files.


Pre-Processing of the TEI files
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We extract every chapter of every capitular from all manuscripts and store them in the
Postgres database.  The text stored in the database is already normalized.

If a manuscript contains more than one copy of a chapter, all copies are extracted.  If
one or more correcting hands were active in the chapter, the original and each corrected
version are extracted.

The online collation tool knows about all versions and offers them to the user.

.. pic:: uml
   :caption: Data flow during pre-processing

   skinparam backgroundColor transparent
   skinparam DefaultTextAlignment center
   skinparam componentStyle uml2

   database  "Manuscript files\n(XML+TEI)"       as tei
   note left of tei: publ/mss/*.xml
   component "Cron"                              as cron
   component "Makefile"                          as make
   component "mss-extract-chapters-txt.xsl"      as saxon
   database  "Preprocessed files\n(XML)"         as chapters
   note left of chapters: publ/cache/collation/*.xml
   component "import.py"                         as import
   database  "Database\n(Postgres)"              as db

   tei      --> saxon
   saxon    --> chapters
   chapters --> import
   import   --> db

   cron .> make
   make .> saxon
   make .> import

The Makefile knows all the dependencies between the files and runs the
appropriate tools to keep the database up-to-date with the manuscript files.

The Makefile is run by cron at regular intervals.

All preprocessed files can be found in the :file:`publ/cache/collation` directory.  The
preprocessed files are normalized, eg. have the letter *V* replaced by *U*.

The :program:`import.py` script imports the preprocessed text files into the database.


Collation Tool
~~~~~~~~~~~~~~

The collation tool consists of two parts: one frontend written in JavaScript and using
the Vue.js library, and one backend application server written in Python and using the
`super-collator <https://pypi.org/project/super-collator/>`_ library.

The application server retrieves the chapters from the database and collates them. The
results of the collation are sent in json to the frontend that does the formatting for
display.

.. pic:: uml
   :caption: Data flow during collation

   skinparam backgroundColor transparent
   skinparam DefaultTextAlignment center
   skinparam componentStyle uml2

   cloud "Backend" {
     database  "Database\n(Postgres)"             as db
     component "API Server\n(Python)"             as api
     component "Super-Collator\n(Python library)" as lib
   }
   component "Frontend\n(Javascript)" as client

   db     -->  api
   api    -->  client
   lib    <-> api


The collation unit is the chapter, so that only short texts need to be collated,
saving much processing time.

The Wordpress collation plugin delivers the Javascript client to the user.
After that, all communication happens directly between the client and the
application server.


Collation Algorithm
~~~~~~~~~~~~~~~~~~~

The application server uses an enhancement of the Needleman-Wunsch algorithm by Gotoh
[Gotoh1982]_.  This section provides a very high level overview of the algorithm.


Phase 1 - Build Table
---------------------

In phase 1 the algorithm builds a table.  For example this is the table built for the
two strings: *the quick brown fox jumps over the lazy dog* and *sick fox is crazy.*

.. raw:: html
   :file: ../_static/super-collator-phase1.html

Every cell in the table contains three values: `D`, `P`, and `Q`, and an arrow, like this:

.. raw:: html
    :align: center

   <table class='super-collator super-collator-debug-matrix' style="margin-left: auto; margin-right: auto">
   <tr><td class='outer'>
   <table>
     <tr><td class='d inner'>D</td><td class='p inner'>P</td></tr>
     <tr><td class='q inner'>Q</td><td class='inner arrow'>↖</td></tr>
   </table>
   </td>
   </tr>
   </table>

We define the score `S` for each cell as:

.. math::

    S = \max(D, P, Q)

The grayed cells in the first row and first column are initialized using the *gap start*
and *gap extension* penalties.  The numbers for each remaining cell are calculated using
only values from the three cells, to the top-left, the top, and the left, of the current
cell:

.. math::

   D = S_↖ + \mbox{similarity}(word_←, word_↑)

.. math::

   P = \max(S_↑ + openingpenalty, P_↑ + extensionpenalty)

.. math::

   Q = \max(S_← + openingpenalty, Q_← + extensionpenalty)

Finally the arrow in the current cell is set to point to that cell which yielded the
highest of the current cell's `D`, `P`, and `Q` values.


Phase 2 - Backtrack
-------------------

When the table is thus completed, two empty sequences are created.  Then the algorithm
starts backtracking from the last (bottom-right) cell following the arrows until it
reaches the first (top-left) cell.  If the arrow points:

↑
   the word in the row header is added to the first sequence, a hyphen is added to the
   second sequence,
↖
   the word in the row header is added to the first sequence, the word in the column
   header is added to the second sequence,
←
   a hyphen is added to the first sequence, the word in the column header is added to the
   second sequence.

.. raw:: html
   :file: ../_static/super-collator-phase2.html

Finally the two sequences are reversed and printed.

.. raw:: html
   :file: ../_static/super-collator-result.html


Parameters
----------

The algorithm can be customized by setting:

- a word comparison (similarity) function,
- the starting gap penalty,
- the gap opening penalty,
- and the gap extension penalty.


Word Comparison Function
~~~~~~~~~~~~~~~~~~~~~~~~

The word comparison function returns a similarity value between 0 and 1, 0 being totally
different and 1 being completely equal.  The chosen function is not critical to the
functioning of the aligner.  The similarity should increase with the desirability of the
alignment, but otherwise there are no fixed rules.

In the current implementation the similarity is calculated as follows:

All words in the input texts are split into sets of trigrams (sometimes called
3-shingles).  The trigrams are obtained by first prefixing and suffixing the word with
two spaces respectively, then cutting the resulting string into all possible strings of
length 3.  This means that all trigrams partially overlap each other.

To calculate the similarity between two words three sets are built: the set of
trigrams in word a, the set of trigrams in word b, and the set of trigrams
common to both words.  The similarity is then given by the formula:

.. math::

   \mbox{similarity}(a,b)= \frac{2|set_{a} \cap set_{b}|}{|set_a| + |set_b|}

The factor of 2 was added to bring the similarity of identical words to 1.

This is sometimes called the
`Sørensen–Dice coefficient <https://en.wikipedia.org/wiki/S%C3%B8rensen%E2%80%93Dice_coefficient>`_.

An example calculation follows:

.. pic:: trigram hlodouuico ludouico
   :caption: Calculating similarity using trigrams

The similarity based on trigrams was chosen because its calculation can be done in
`\mathcal{O}(n)` time whereas a similarity based on Levenshtein distance needs
`\mathcal{O}(n^2)` time.  The sets of trigrams for each input word are calculated
only once and if you presort the trigrams in these sets (to be implemented), the common
set can be found in `\mathcal{O}(n)` time.

Optimizations yet to be implemented: in a first step gather all trigrams in all
input texts, give each one an integer id, and later operate on the ids only.
Maybe hash each trigram onto a value 0..63 and build a bitmask for each word,
later operate on the masks only.


References
~~~~~~~~~~

.. [Gotoh1982] Gotoh, O. 1982,  *An Improved Algorithm for Matching Biological
               Sequences,* J. Mol. Biol. 162, 705-708
               http://jaligner.sourceforge.net/references/gotoh1982.pdf
