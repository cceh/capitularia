#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#

import argparse
import collections
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

import suffix_tree

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

    mss = cluster.MSS
    if args.sort:
        mss = sorted (mss, key = cluster.natural_sort_key)

    bks = set ()
    for ms in mss:
        bks.update (ms_seq[ms])
    bks = sorted (bks, key = cluster.natural_sort_key)

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

    bk_set = set ()
    if args.include_bks:
        bk_set = set (args.include_bks.split (','))
    if args.include_mss:
        for ms in args.include_bks.split (','):
            bk_set.update (ms_seq[ms])
    if len (bk_set) > 0:
        for k in set (palette) - bk_set:
            del palette[k]

    for i, ms in enumerate (mss):
        for j, bk in enumerate (ms_seq[ms]):
            df.loc[ms, j] = palette.get (bk, 0)
            labels[i, j] = re.sub ('^BK\.', '', bk)

    # suffix tree
    ms_tree = {}
    for ms in """
st-gallen-sb-733
st-paul-abs-4-1
ivrea-bc-xxxiv
ivrea-bc-xxxiii
vatikan-bav-reg-lat-5359
vercelli-bce-clxxiv
wolfenbuettel-hab-blankenb-130
muenchen-bsb-lat-19416
paris-bn-lat-4613
vatikan-bav-reg-lat-263
muenchen-bsb-lat-3853
heiligenkreuz-sb-217
vatikan-bav-chigi-f-iv-75
modena-bc-o-i-2
gotha-flb-memb-i-84
cava-dei-tirreni-bdb-4""".split ():
        #for ms in mss:
        ms_tree[ms] = []
        for bk in ms_seq[ms]:
            ms_tree[ms].append (cluster.natural_sort_bk (bk))

    tree = suffix_tree.Tree (ms_tree)
    tree.root.calc_cv ()
    tree.root.calc_left_diverse ()
    print (tree.to_dot ())
    R = tree.maximal_repeats ()
    #for cv, path in R:
    #    if cv > 1 and len (path) > 2:
    #        print ("%2d %s" % (cv, path))

    f1, axes = plt.subplots (1, 1, figsize = cluster.PAPER)

    vmax = len (bks)
    im = cluster.heat_matrix_df (
        f1, axes, df,
        "Sequence of Capitulars in Manuscripts (%s)" % args.sorted_by,
        100, 100,
        cmap=cluster.colormap_sequence (),
        vmin = 1,
        vmax = vmax
    )

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
    parser.add_argument ('-o', '--output',
                         help="Output file (default: stdout)")
    parser.add_argument ('--include-bks',
                         help="Only Capitulars from this list (eg. BK.1,BK.2,BK.5)")
    parser.add_argument ('--include-mss',
                         help="Only Capitulars from Mss. in this list (eg. st-gallen-sb-733,...)")
    parser.add_argument ('-d', '--debug', action='store_true',
                         help="Turn on debugging output")
    parser.add_argument ('input',
                         help="Input file")

    args = parser.parse_args ()
    args.sorted_by = "Alphabetical" if args.sort else "by Date"
    main (args)
