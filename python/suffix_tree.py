#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#

"""A suffix-tree.

This implementation:

- works with any python iterable if the items are hashable,
- is a generalized suffix tree ([Gusfield1997]_ §6.4),
- can convert the tree to .dot if the items convert to strings,
- values simplicity over speed.

This implementation mostly follows [Gusfield1997]_, with following differences:

- indices are 0-based (python convention)
- end indices point one element beyond (python convention)


.. [Gusfield1997] Gusfield, Dan.  Algorithms on strings, trees, and sequences.
                  1997.  Cambridge University Press.

"""

import collections
import sys

class UniqueEndChar (object):
    """ A singleton object to signal end of sequence. """
    def __str__ (self):
        return '$'

_END = UniqueEndChar ()

DEBUG = 0

def debug (*a, **kw):
    if DEBUG:
        print (*a, file=sys.stderr, **kw)


class Pos (object):
    """ Represents a position in a string. """

    def __init__ (self, S, start = 0):
        assert 0 <= start <= len (S), "Pos: 0 <= %d <= %d" % (start, len (S))

        self.S     = S
        self.start = start

    def __str__ (self):
        return str (self.S[self.start])


class Path (object):
    """ A path in a suffix tree. """

    def __init__ (self, S, start = 0, end = None):
        if end is None:
            end = len (S)
        assert 0 <= start <= end <= len (S), "Path: 0 <= %d <= %d <= %d" % (start, end, len (S))

        self.S     = S
        self.start = start
        self.end   = end

    def __str__ (self):
        return ' '.join ([str (o) for o in self.S[self.start:self.end]])

    def __len__ (self):
        return self.end - self.start

    def compare (self, path, offset = 0):
        length = min (len (self), len (path)) - offset
        offset1 = self.start + offset
        offset2 = path.start + offset
        i = 0

        while i < length:
            if self.S[offset1 + i] != path.S[offset2 + i]:
                break
            i += 1
        debug ("Comparing %s == %s at offset %d => %d" % (str (self), str (path), offset, i))
        return i


class Node (object):
    """ A node. """

    def __init__ (self, parent, path):
        self.parent = parent

        self.path = path
        """One arbitrarily selected path that traverses this node. (Usually the first
        one in tree construction order.)
        """

        self.cv = -1
        """For any internal node :math:`v` of :math:`T`, define :math:`C(v)` to be the
        number of *distinct* string identifiers that appear at the leaves in the
        subtree of :math:`v`.  [Gusfield1997]_ §7.6, 127ff
        """

        self.is_left_diverse = None
        """A node :math:`v` of :math:`T` is called *left diverse* if at least two
        leaves in :math:`v`'s subtree have different left characters.  By
        definition a leaf cannot be left diverse.  [Gusfield1997]_ §7.12.1,
        144ff

        For each position :math:`i` in string :math:`S`, character
        :math:`S(i-1)` is called the *left character* of :math:`i`. The *left
        character of a leaf* of :math:`T` is the left character of the suffix
        position represented by that leaf.  [Gusfield1997]_ §7.12.1, 144ff

        N.B. This suffix tree operates on any python hashable object, not just
        characters, so left_characters usually are objects.

        N.B. This being a generalized suffix tree, leafs *can be* left diverse,
        if the left characters in two strings are different or the leafs are at
        the beginning of the string.

        """

    def string_depth (self):
        """For any node :math:`v` in a suffix-tree, the *string-depth* of :math:`v` is
        the number of characters in :math:`v`'s label.  [Gusfield1997]_ §5.2, 90f
        """
        return len (self.path)

    def __str__ (self):
        raise NotImplementedError ()

    def is_leaf (self):
        raise NotImplementedError ()

    def calc_cv (self):
        """ Calculate :math:`C(v)` numbers for all nodes. """
        raise NotImplementedError ()

    def calc_left_diverse (self):
        """ Calculate the left_diversity of this node. """
        raise NotImplementedError ()

    def pre_order (self, f):
        raise NotImplementedError ()

    def post_order (self, f):
        raise NotImplementedError ()

    def get_positions (self):
        """Get all strings and positions that traverse this node."""

        starts = {}
        def f (node):
            if node.is_leaf ():
                starts.update (node.indices)
        self.pre_order (f)
        return starts

    def maximal_repeats (self, a):
        """Get a list of maximal repeats.

        See [Gusfield1997]_ §7.12.1, 144ff.

        """
        raise NotImplementedError ()

    def to_dot (self, a):
        raise NotImplementedError ()


class Leaf (Node):
    """A leaf node.

    A suffix tree contains exactly len(S) leaf nodes.  A generalized suffix tree
    contains less than len (concat (S_1..S_N)) leaf nodes.

    """

    def __init__ (self, parent, id_, path):
        super ().__init__ (parent, path)
        self.indices = {}
        self.add (id_, path)

    def __str__ (self):
        # + 1 makes it Gusfield-compatible for easier comparing with examples in the book
        return (("^%s$\nCV=%d%s\n" % (str (self.path), self.cv, ' LD' if self.is_left_diverse else '')) +
                '\n'.join (['%s:%d' % (id_, path.start + 1) for id_, path in self.indices.items ()]))

    def add (self, id_, path):
        assert isinstance (path, Path)
        self.indices[id_] = path

    def is_leaf (self):
        return True

    def pre_order (self, f):
        f (self)
        return

    def post_order (self, f):
        f (self)
        return

    def calc_cv (self):
        id_set = set (self.indices.keys ())
        self.cv = len (id_set)
        return id_set

    def calc_left_diverse (self):
        """ See description in Node """
        left_characters = set ()
        for path in self.indices.values ():
            if path.start > 0:
                left_characters.add (path.S[path.start - 1])
            else:
                self.is_left_diverse = True
                return None
        self.is_left_diverse = len (left_characters) > 1
        return None if self.is_left_diverse else left_characters

    def maximal_repeats (self, a):
        if self.is_left_diverse:
            a.append ((self.cv, self.path))

    def to_dot (self, a):
        a.append ('"%s" [color=green];\n' % str (self))


class Internal (Node):
    """ An internal node.

    Internal nodes have at least 2 children.
    """

    def __init__ (self, parent, label, path):
        super ().__init__ (parent, path)
        self.label = label
        self.edges = {}
        """ A dictionary of item => node """

    def __str__ (self):
        return "^%s$\nCV=%d%s" % (str (self.path), self.cv, ' LD' if self.is_left_diverse else '')

    def is_leaf (self):
        return False

    def pre_order (self, f):
        f (self)
        for node in self.edges.values ():
            node.pre_order (f)
        return

    def post_order (self, f):
        for node in self.edges.values ():
            node.post_order (f)
        f (self)
        return

    def calc_cv (self):
        id_set = set ()
        for node in self.edges.values ():
            id_set.update (node.calc_cv ())
        self.cv = len (id_set)
        return id_set

    def calc_left_diverse (self):
        """ See description in Node """
        left_characters = set ()
        self.is_left_diverse = False
        for node in self.edges.values ():
            lc = node.calc_left_diverse ()
            if lc is None:
                self.is_left_diverse = True
            else:
                left_characters.update (lc)
        if len (left_characters) > 1:
            self.is_left_diverse = True
        return None if self.is_left_diverse else left_characters

    def maximal_repeats (self, a):
        if self.is_left_diverse:
            a.append ((self.cv, self.path))
        for dest in self.edges.values ():
            dest.maximal_repeats (a)

    def to_dot (self, a):
        a.append ('"%s" [color=red];\n' % str (self))
        for node in self.edges.values ():
            node.to_dot (a)
            p = node.path
            p = Path (p.S, p.start + self.string_depth (), p.start + node.string_depth ())
            a.append ('"%s" -> "%s" [label="%s"];\n' % (str (self), str (node), str (p)))


class Tree (object):
    """A suffix tree.

    The key feature of the suffix tree is that for any leaf :math:`i`, the
    concatenation of the edgle-labels on the path from the root to leaf
    :math:`i` exactly spells out the suffix of :math:`S` that starts at point
    :math:`i`.  That is, it spells out :math:`S[i..m]`.

    """

    def get_unique_label (self):
        """ Return a unique label for a node. """
        self.next_label += 1
        return 'N%d' % self.next_label

    def to_dot (self):
        """ Output the tree in GraphViz .dot format. """
        dot = []
        dot.append ('strict digraph G {\n')
        self.root.to_dot (dot)
        dot.append ('}\n')
        return ''.join (dot)

    def split_edge (self, node1, node2, new_len, label):
        """Split edge

        Split 1 --> 2 into 1 --> New --> 2 and return the new node.
        new_len is the distance 1 --> New

        """
        p1 = node1.path
        p2 = node2.path
        old_len = len (p2) - len (p1)
        assert 0 < new_len < old_len, "split new/old length %d %d" % (new_len, old_len)
        p2cut = p2.start + len (p1)

        new = Internal (node1, label, Path (p2.S, p2.start, p2cut + new_len)) # it is always safe to shorten a path
        node2.parent = new
        node1.edges[p2.S[p2cut          ]] = new     # substitute new node
        new.edges  [p2.S[p2cut + new_len]] = node2

        debug ('Splitting %s:%s' % (str (node1), str (node2)))
        debug ('Split Adding %s to node %s as [%s]' % (str (new), str (node1), p2.S[p2cut]))

        return new

    def find_path (self, path):
        """Find a path in the tree.

        Returns the next deeper node after matching the path and the matched path
        length up to that node.

        """
        node = self.root
        matched_len = 0
        while matched_len < len (path):
            # find the edge to follow
            dest = node.edges.get (path.S[path.start + matched_len])
            if dest:
                # follow the edge, there must be at least one match
                length = path.compare (dest.path, matched_len)
                assert length > 0, "find_path length=%d matched_len=%d" % (length, matched_len)
                node = dest
                matched_len += length
                if matched_len < dest.string_depth ():
                    # the path ends before dest
                    return dest, matched_len, True
            else:
                # no edge to follow
                return node, matched_len, False
        # path exhausted
        return node, matched_len, False

    def add_string_naive (self, id_, path):
        """Add a string to the tree.

        A naive implementation using :math:`\mathcal{O}(n^2)` time with no
        optimizations.  See: [Gusfield1997]_ §5.4, 93

        """

        # find longest path from root
        node, matched_len, partial = self.find_path (path)

        # are we in the middle of an edge?
        if partial:
            length = matched_len - node.parent.string_depth ()
            node = self.split_edge (node.parent, node, length, self.get_unique_label ())

        assert matched_len == node.string_depth ()

        if node.is_leaf ():
            assert matched_len == len (path)
            # In a generalized tree we may find a leaf is already there.  This
            # is not possible in a non-generalized tree because of the unique
            # ending character.
            node.add (id_, Path (path.S, path.start, path.end))
        else:
            assert matched_len < len (path)
            new_leaf = Leaf (node, id_, Path (path.S, path.start, path.end))
            assert path.S[path.start + matched_len] not in node.edges # do not overwrite
            node.edges[path.S[path.start + matched_len]] = new_leaf
            debug ('Adding %s to node %s as [%s]' % (str (new_leaf), str (node), path.S[path.start + matched_len]))

    def find_all (self, path):
        """ Return all indices of path in tree. """
        n, matched_len = self.find_path (path)
        if matched_len < len (path):
            return []

        paths = []
        def f (node):
            if node.is_leaf ():
                paths.extend (node.indices)

        n.pre_order (f)
        return paths

    def common_substrings (self):
        """Get a list of common substrings.

        Slightly modifed from [Gusfield1997]_ §7.6.  We report :math:`V(k)`
        instead of :math:`l(k)`.

        """

        self.root.calc_cv ()

        V = collections.defaultdict (lambda: (0, 'no_id', None)) # cv => (string_depth, id, path)
        def f (node):
            k = node.cv
            sd = node.string_depth ()
            if sd > V[k][0]:
                for id_, path in node.get_positions ().items ():
                    # select an arbitrary one (the first)
                    # change the path to stop at this node
                    V[k] = (sd, id_, Path (path.S, path.start, path.start + sd))
                    break

        self.root.pre_order (f)
        return V

    def maximal_repeats (self):
        a = []
        self.root.maximal_repeats (a)
        return a

    def __init__ (self, d):
        """ Initialize and build the tree from dict of iterables. """

        self.root = Internal (None, 'root', Path (tuple (), 0, 0))
        self.next_label = 0

        for id_, S in d.items ():
            # input is any iterable, make an immutable copy and add a unique
            # character at the end
            S = tuple (S + [_END])

            # build tree
            end = len (S)
            for i in range (0, end):
                self.add_string_naive (id_, Path (S, i, end))


if __name__ == '__main__':

    #tree = Tree ({ 'A' : list ('xabxac') })        # Gusfield1997 Figure 5.1 Page  91
    #tree = Tree ({ 'A' : list ('awyawxawxz') })    # Gusfield1997 Figure 5.2 Page  92
    #tree = Tree ({ 'A' : list ('xyxaxaxa') })      # Gusfield1997 Figure 7.1 Page 129
    tree = Tree ({
        'A' : '232 020b 092 093 039 061 102 135 098 099 039 040 039 040 044 141 140 098'.split (),
        'B' : '097 098 039 040 041 129 043'.split (),
        'C' : '097 098 039 040 020a 022 023 097 095 094 098 043 044 112 039 020b 039 098'.split (),
    })

    # tree = Tree ({ 'A' : list ('xabxac'), 'B' : list ('awyawxawxz') })
    tree.root.calc_cv ()
    tree.root.calc_left_diverse ()

    # print (tree.find_all (Path ('020a'.split ())))

    #V = tree.common_substrings ()
    # print (V)

    R = tree.maximal_repeats ()
    #for cv, path in R:
    #    print (cv, str (path))

    print (tree.to_dot ())
