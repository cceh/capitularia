#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#

"""Constant-Time Lowest Common Ancestor Retrieval

"With the ability to solve lowest common ancestor queries in constant time,
suffix trees can be used to solve many additional string problems."
[Gusfield1997]_ §9, 196

"**Definition** In a rooted tree :math:`\mathcal{T}`, a node :math:`u` is an
*ancestor* of a node :math:`v` if :math:`u` is on the unique path from the root
to :math:`v`.  With this definition a node is an ancestor of itself.  A *proper
ancestor* of :math:`v` refers to an ancestor that is not :math:`v`.

**Definition** In a rooted tree :math:`\mathcal{T}`, the *lowest common ancestor
(lca)* of two nodes :math:`x` and :math:`y` is the deepest node in
:math:`\mathcal{T}` that is an ancestor to both :math:`x` and :math:`y`."
[Gusfield1997]_ Chapter 8, 181ff

"""

import ctypes
import sys

import suffix_tree # for doctest

DEBUG = 0

def debug (*a, **kw):
    if DEBUG:
        print (*a, file=sys.stderr, **kw)

def uint (x):
    return ctypes.c_uint32 (x).value

def nlz (x):
    """ Get the number of leadings zeros in a 32 bit word.

    >>> nlz (0)
    32
    >>> nlz (0x1)
    31
    >>> nlz (0xFF)
    24
    >>> nlz (0xFFFFFFFF)
    0

    See: http://www.hackersdelight.org/hdcodetxt/nlz.c.txt
    """
    n = 32
    for shift in (16, 8, 4, 2, 1):
        y = x >> shift
        if y != 0:
            n = n - shift
            x = y
    return n - x

def msb (x):
    """Get the position of the most significant set bit counting from the right and
    starting from 0.

    >>> msb (0xF)
    3
    >>> msb (0xFF)
    7
    >>> msb (0)
    -1

    """
    return 31 - nlz (x)

def h (k):
    """"**Definition** For any number :math:`k`, :math:`h(k)` denotes the position
    (counting from the right) of the least-significant 1-bit in the binary
    representation of :math:`k`." [Gusfield1997]_ §8.5, 184ff

    "**Lemma 8.5.1.** For any node :math:`k` (node with path number k) in
    :math:`\mathcal{B}`, :math:`h(k)` equals the height of node :math:`k` in
    :math:`\mathcal{B}`.

    For example, node 8 (binary 1000) is at height 4, and the path from it to a
    leaf has four nodes (three edges)." [Gusfield1997]_ §8.5, 184ff

    N.B. in this implementation we start counting with 0, so you get:

    >>> h (5)
    0
    >>> h (8)
    3

    """
    return 32 - nlz (~k & (k - 1))


class Node (object):

    def __init__ (self):
        self.id = 0
        """Number of the node given in a depth-first traversal of the tree, starting
        with 1.  See [Gusfield1997]_ Figure 8.1, 182
        """

        self.I = 0
        """For a node :math:`v` of :math:`\mathcal{T}`, let :math:`I(v)` be a node
        :math:`w` in :math:`\mathcal{T}` such that :math:`h(w)` is maximum over
        all nodes in the subtree of :math:`v` (including :math:`v` itself).
        [Gusfield1997]_ §8.5, 184ff

        For any node :math:`v`, node :math:`I(v)` is the deepest node in the run
        containing node :math:`v`.  [Gusfield1997]_ Lemma 8.6.1., 187

        N.B. This is the id of the node :math:`I(v)`.

        """

        self.A = 0
        """Bit :math:`A_v(i)` is set to 1 if and only if node :math:`v` has some
        ancestor in :math:`\mathcal{T}` that maps to height :math:`i` in
        :math:`\mathcal{B}`, i.e. if and only if :math:`v` has an ancestor
        :math:`u` such that :math:`h(I(u))=i`. [Gusfield1997]_ §8.7, 188f

        N.B. A node is an ancestor of itself. [Gusfield1997]_ §8.1, 181
        """

    def compute_I_and_L (self, L):
        raise NotImplementedError ()

    def compute_A (self, A):
        raise NotImplementedError ()


class Leaf (Node):

    def __str__ (self):
        return "%dh%d I=%dh%d A=0x%x\n" % (self.id, h (self.id), self.I, h (self.I), self.A)

    def prepare_lca (self, counter, parent):
        self.id = counter
        self.parent = parent
        return counter + 1

    def compute_I_and_L (self, L):
        self.I = self.id
        L[self.I] = self    # will be overwritten by the highest node in run
        return self.I

    def compute_A (self, A):
        A |= 1 << h (self.I)
        self.A = A


class Internal (Node):

    def __str__ (self):
        return "%dh%d I=%dh%d A=0x%x\n" % (self.id, h (self.id), self.I, h (self.I), self.A)

    def prepare_lca (self, counter, parent):
        self.id = counter
        self.parent = parent
        counter += 1
        for dest in self.children.values ():
            counter = dest.prepare_lca (counter, self)
        return counter

    def compute_I_and_L (self, L):
        # Find the node with the maximum I value in the subtree.
        imax = self.id
        for child in self.children.values ():
            ival = child.compute_I_and_L (L)
            if h (ival) > h (imax):
                imax = ival
        self.I = imax
        L[imax] = self  # will be overwritten by the highest node in run
        return imax;

    def compute_A (self, A):
        A |= 1 << h (self.I)
        self.A = A
        for child in self.children.values ():
            child.compute_A (A)


class Tree (object):

    def __init__ (self):
        self.L = None

    def prepare_lca (self):
        """ Preprocess the tree for Lowest Common Ancestor retrieval.

        [Gusfield1997]_ §8.7
        """
        self.L = dict ()
        self.root.prepare_lca (1, self.root)
        self.root.compute_I_and_L (self.L)
        self.root.compute_A (0)

    def lca (self, x, y):
        """ Returns the lowest common ancestor node of nodes x and y.

        >>> tree = suffix_tree.Tree ({ 'A' : list ('xabxac'), 'B' : list ('awyawxawxz') })
        >>> tree.prepare_lca ()
        >>> tree.lca (tree.nodemap['A'][1], tree.nodemap['B'][3]).id
        8
        """
        if x == y:
            return x

        """ Returns z, the lca of x and y. """
        # step 1 - §8.4, §8.8
        k = msb (x.I ^ y.I)
        debug ("k = msb (%d ^ %d = %d) = %d" % (x.I, y.I, x.I ^ y.I, k))
        # leave the msb 1-bit and zero all lower bits
        mask = ~0 << (k + 1)   # reset the k + 1 lowest bits in mask
        debug ("x.I = %d, mask 0x%x" % (x.I, uint (mask)))
        b = (x.I & mask) | (1 << k)  # b = lca (x, y) in B
        debug ("b = %d, h(b) = %d" % (b, h (b)))

        # step 2 - §8.8
        mask = ~0 << h (b)     # reset the h(b) lowest bits in mask
        debug ("x.A = 0x%x, y.A = 0x%x, mask = 0x%x" % (x.A, y.A, uint (mask)))
        j = h (x.A & y.A & mask) # j = h(I(z))
        debug ("j = %d" % j)

        # step 3 and 4
        def get_xy_bar (n):
            l = h (n.A)
            if l == j:
                return n
            else:
                mask = ~(~0 << j)    # set the j lowest bits in mask
                k = msb (n.A & mask)
                mask = ~0 << (k + 1)  # reset k + 1 lowest bits in mask
                Iw = (n.I & mask) | (1 << k)
                debug ("Iw = %d" % Iw)
                debug ("L[Iw] = %d" % self.L[Iw].id)
                w = self.L[Iw]
                return w.parent

        xbar = get_xy_bar (x)
        ybar = get_xy_bar (y)
        debug ("xbar = %d, ybar = %d" % (xbar.id, ybar.id))

        # step 5
        if xbar.id < ybar.id:
            return xbar
        return ybar


if __name__ == '__main__':
    import doctest
    doctest.testmod ()
