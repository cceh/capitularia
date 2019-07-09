================
 Collation Tool
================

The collation tool runs as a javascript frontend with a backend that does the
actual collation.  The backend uses a custom version of Collate-X that
implements the Needleman-Wunsch-Gotoh alignment algorithm and a custom word
comparison function.

The stock Collate-X only uses word comparison functions that return binary
values, signalling either a match or a mismatch.  Our custom word comparison
function returns a similarity value between 0 and 1.  This works much better
when aligning variant orthographies of the same word.


Needleman-Wunsch Algorithm
==========================

The Needleman-Wunsch-Gotoh algorithm was implemented according to [Gotoh1982]_.


Word Comparison Function
========================

The word comparison function returns a similarity value between 0 and 1.

All words in the texts are split into trigrams.  Only the resulting set of
trigrams is used in the similarity calculation.  The trigrams are obtained by
first prefixing and suffixing the string with two spaces respectively, then
cutting it into all possible strings of length 3.  Trigrams partially overlap
each other.

To calculate the similarity between two words, a set is built containing only
the trigrams common to both words.  The magnitude of this set is then compared
against the number of trigrams in both words:

  similarity = 2.0 * triAB.size() / (triA.size() + triB.size());

This value can be calculated much faster than eg. the Levenshtein distance.  The
sets of trigrams for each input word are calculated only once.  If you presort
these sets, the common set can be found in O(n) time.


.. [Gotoh1982] Gotoh, O. 1982,  *An Improved Algorithm for Matching Biological
               Sequences,* J. Mol. Biol. 162, 705-708
               http://jaligner.sourceforge.net/references/gotoh1982.pdf
