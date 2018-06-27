#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#

import argparse
import collections
import itertools
import os.path
import re
import subprocess
import sys

import pandas as pd
import numpy as np
import matplotlib
import matplotlib.pyplot as plt

import lxml
from lxml import etree

import networkx as nx

import cluster

def debug (*a, **kw):
    if args.debug:
        print (*a, file=sys.stderr, **kw)


def pick (n, l):
    ticks = np.linspace (0.0, 1.0, n)
    index = np.rint (np.linspace (0.0, len (l) - 1, n)) # round to int
    labels = np.array (l)
    return (ticks, labels[index.astype (int)])


def main (args):
    ms_seq = cluster.scan_xml_file (
        args.input,
        unit = 'ms',
        type_ = 'capitulare'
    )

    cluster.fix_include_bks (args, ms_seq)

    mss = cluster.MSS
    if args.sort:
        mss = sorted (mss, key = cluster.natural_sort_key)

    bks = sorted (set (itertools.chain.from_iterable (ms_seq.values ())))

    debug ('mss: %d' % len (mss))
    debug ('bks: %d' % len (bks))

    # get the length of the longest ms
    max_ms_len = max ([len (seq) for seq in ms_seq.values ()])

    # a matrix of ms x autoinc
    df = pd.DataFrame (np.zeros ((len (mss), max_ms_len), dtype=int), index = mss)
    df[:] = -np.inf # hide empty cells
    labels = np.empty (df.shape, object)

    # every capit gets a different color
    palette = { capit : n + 1 for n, capit in enumerate (bks) }

    # user wants only a subset of bks?
    # remove unwanted bks from palette (make them gray)
    if len (args.include_bks) > 0:
        for k in set (palette) - set (args.include_bks):
            del palette[k]

    for i, ms in enumerate (mss):
        for j, bk in enumerate (ms_seq[ms]):
            df.loc[ms, j] = palette.get (bk, 0)
            labels[i, j] = cluster.key_to_short (bk)

    if args.repeats:
        # look for maximal repeats
        ms_tree = {}
        for ms in mss:
            ms_tree[ms] = []
            for bk in ms_seq[ms]:
                ms_tree[ms].append (cluster.key_to_df (bk))

        import suffix_tree
        tree = suffix_tree.Tree (ms_tree)
        for cv, path in tree.maximal_repeats ():
            if cv > 1 and len (path) > 1:
                print ("%d %s" % (cv, path))
        return

    f1, axes = plt.subplots (1, 1, figsize = cluster.PAPER)

    vmax = len (bks)
    im = cluster.heat_matrix_df (f1, axes, df, 100, 100,
        cmap=cluster.colormap_sequence (),
        vmin = 1, vmax = vmax
    )
    cluster.title (axes, args, "Capitulars in Manuscripts")

    colors = np.empty (df.shape, object)
    colors[:] = "black"
    colors[df.values < 0.25 * vmax] = "white"
    colors[df.values > 0.85 * vmax] = "white"
    cluster.annotate (im, labels, colors, rotation="90")

    f1.savefig (args.output or sys.stdout.buffer, dpi=300, transparent=False)

    if args.plot:
        plt.show ()


if __name__ == '__main__':

    parser = argparse.ArgumentParser (
        formatter_class = argparse.RawDescriptionHelpFormatter,  # don't wrap my description
        description = """Build a sequential diagram of Capitulars."""
    )

    parser.add_argument ('-s', '--sort', action='store_true',
                         help="Sort manuscripts alphabetically (default: by age)")
    parser.add_argument ('-p', '--plot', action='store_true',
                         help="Show plot on screen")
    parser.add_argument ('-r', '--repeats', action='store_true',
                         help="Output maximal repeats")
    parser.add_argument ('-o', '--output',
                         help="Output file (default: stdout)")
    parser.add_argument ('-t', '--title',
                         help="The plot title (caption)")
    cluster.add_range_args (parser)
    parser.add_argument ('-d', '--debug', action='store_true',
                         help="Turn on debugging output")
    parser.add_argument ('input',
                         help="Input file")

    args = parser.parse_args ()
    args.sorted_by = "Alphabetical" if args.sort else "by Date"
    main (args)
