.. _collation-tool-overview:


Overview of the Collation Tool
==============================

Description of the collation tool and the pre-processing of the TEI files.


Pre-Processing of the TEI files
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We extract every chapter of every capitular from all manuscripts and store them
in separate records in the Postgres database on the application Server.  The
text stored in the database is normalized.

If a manuscript contains more than one copy of a chapter, all copies are
extracted.  If a corrector hand was active in the chapter, both an original and
a corrected version are extracted.

The online collation tool knows about all versions and offers them to the user.

.. pic:: uml
   :caption: Data flow during pre-processing

   skinparam backgroundColor transparent
   skinparam DefaultTextAlignment center
   skinparam componentStyle uml2

   database  "Manuscript files\n(XML+TEI)"      as tei
   note left of tei: publ/mss/*.xml

   cloud "VM" {
     component "Cron"                          as cron
     component "Makefile"                      as make
     component "mss-extract-chapters.xsl"      as saxon
     database  "Chapter files\n(plain text)"   as chapters
     note left of chapters: publ/cache/extracted/*/*.txt
     component "import.py"                     as import
     database  "Database\n(Postgres)"          as db
   }

   tei      --> saxon
   saxon    --> chapters
   chapters --> import
   import   --> db

   cron .> make
   make .> saxon
   make .> import

The Makefile is run by cron on the Capitularia VM at regular intervals.

The Makefile knows all the dependencies between the files and runs the
appropriate tools to keep the database up-to-date with the manuscript files.

All intermediate files can be found in the cache/extracted directory.  One
directory per manuscript, and one file per chapter, copy, and hand.  The
intermediate files are normalized, eg. have V replaced by U.

The import.py script imports the intermediate text files into the database.


Collation
~~~~~~~~~

The collation tool is divided in two parts, one frontend written in JavaScript and the
Vue.js library, and one backend application server written in Python.  The application
server retrieves the chapters to collate from the database and collates them. The
results are sent to the frontend that does the formatting for display.

.. pic:: uml
   :caption: Data flow during collation

   skinparam backgroundColor transparent
   skinparam DefaultTextAlignment center
   skinparam componentStyle uml2

   cloud "VM" {
     database  "Database\n(Postgres)"   as db
     component "API Server\n(Python)"   as api
   }
   component "Frontend\n(Javascript)" as client

   db     --> api
   api    --> client


The collation unit is the chapter, so that only short texts need to be collated,
saving much processing time.

The Wordpress collation plugin delivers the Javascript client to the user.
After that, all communication happens directly between the client and the
application server.

The application server uses an enhacement of the Needleman-Wunsch algorithm by Gotoh.
[Gotoh1982]_


Word Comparison Function
------------------------

The word comparison function returns a similarity value between 0 and 1.  The
similarity is calculated as follows:

All words in the input texts are split into sets of trigrams.  The trigrams are
obtained by first prefixing and suffixing the word with two spaces respectively,
then cutting the resulting string into all possible strings of length 3.  This
means that all trigrams partially overlap each other.

To calculate the similarity between two words three sets are built: the set of
trigrams in word a, the set of trigrams in word b, and the set of trigrams
common to both words.  The similarity is then given by the formula:

.. math::

   \mbox{similarity}(a,b)= \frac{2\times |set_{ab}|}{|set_a| + |set_b|}

The factor 2 was added to bring the similarity of identical words to 1.

An example calculation follows:

.. pic:: trigram hlodouuico ludouico
   :caption: Calculating similarity using trigrams

The similarity based on trigrams was chosen because its calculation can be done in
:math:`\mathcal{O}(n)` time whereas a similarity based on Levenshtein distance needs
:math:`\mathcal{O}(n^2)` time.  The sets of trigrams for each input word are calculated
only once and if you presort the trigrams in these sets (to be implemented), the common
set can be found in :math:`\mathcal{O}(n)` time.

Optimizations yet to be implemented: in a first step gather all trigrams in all
input texts, give each one an integer id, and later operate on the ids only.
Maybe hash each trigram onto a value 0..63 and build a bitmask for each word,
later operate on the masks only.


.. [Gotoh1982] Gotoh, O. 1982,  *An Improved Algorithm for Matching Biological
               Sequences,* J. Mol. Biol. 162, 705-708
               http://jaligner.sourceforge.net/references/gotoh1982.pdf
