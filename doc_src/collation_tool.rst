================
 Collation Tool
================

The collation tool has a frontend and a backend component.
The collatables are stored in TEI files.


.. uml::
   :align: center
   :caption: Collation Tool

   skinparam backgroundColor transparent
   skinparam DefaultTextAlignment center

   component "Frontend\n\n(Javascript)" as client

   component "Backend\n\n(Wordpress Plugin)" as api
   component "CollateX\n\n(Java)"  as cx
   component "Transformation\n\n(XSLT)"       as xslt

   database "TEI Files"   as tei

   client <-> api
   api <-> cx
   api <-- xslt
   xslt <-- tei

The frontend is written in Javascript using the VueJS library.  It communicates
with the backend using AJAX calls.  The frontend displays the data to the user
and lets the user manipulate it, while the backend does the actual collation.

The collatables are stored in TEI files.  The backend has to be preprocessed
them to obtain streams of words with all markup stripped.  The streams of words
are then sent to CollateX to do the collation and finally to the frontend, who
formats and displays them.

The collatables are subdivided into capitularies and sections, so that only
short texts need to be collated, saving much processing time.  The backend also
extracts the wanted sections from the TEI files.

Currently and for historical reasons the backend is implemented as Wordpress
plugin in PHP.  We aim to rewrite it ASAP using a Python application framework
and at the same time we'll rewrite all the functionality we need of CollateX in
Python and drop the dependency on CollateX and Java.


Custom Version of CollateX
==========================

Our custom version of CollateX uses a custom word comparison function.

The stock version of CollateX [CollateX]_ uses word comparison functions that
only return binary values, signalling either a match or a mismatch.  Our custom
version uses a word comparison function that returns a similarity value between
0 and 1.  This works much better when aligning variant orthographies of the same
word.

In our custom CollateX we also implemented an enhancement of the
Needleman-Wunsch algorithm by Gotoh. [Gotoh1982]_


Word Comparison Function
------------------------

The word comparison function returns a similarity value between 0 and 1.

All words in the input texts are split into sets of trigrams.  This is done only
once.  The trigrams are obtained by first prefixing and suffixing the word with
two spaces respectively, then cutting the resulting string it into all possible
strings of length 3.  This means that trigrams may partially overlap each other.

The resulting sets of trigrams are then used in the similarity calculation.

To calculate the similarity between two words, a set is built containing only
the trigrams common to both words.  The magnitude of this set is then compared
against the number of trigrams in both words:

  similarity = 2.0 * triAB.size() / (triA.size() + triB.size());

The similarity based on trigrams was chosen because its calculation can be done
in O(n) time whereas a similarity based on Levenshtein distance needs O(n²)
time.  The sets of trigrams for each input word are calculated only once and if
you presort the trigrams in these sets, the common set can be found in O(n)
time.  To be implemented: in a first step gather all trigrams, give each one an
integer id, and later operate on the ids only.  (Maybe hash each trigram onto a
value 0..63 and build a bitmask for each word, later operate on the masks only.)


.. [Gotoh1982] Gotoh, O. 1982,  *An Improved Algorithm for Matching Biological
               Sequences,* J. Mol. Biol. 162, 705-708
               http://jaligner.sourceforge.net/references/gotoh1982.pdf

.. [CollateX] Dekker, R.H. et al. 2010-2019, *CollateX -- Software for Collating
              Textual Sources,* https://collatex.net/
