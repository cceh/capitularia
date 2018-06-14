#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#

import argparse
import collections
import os.path
import re
import sys

import lxml
from lxml import etree
import matplotlib
import matplotlib.pyplot as plt
import numpy as np

import cluster

def err (*args, **kwargs):
    print (*args, file=sys.stderr, **kwargs)

def pick (n, l):
    ticks = np.linspace (0.0, 1.0, n)
    index = np.rint (np.linspace (0.0, len (l) - 1, n)) # round to int
    labels = np.array (l)
    return (ticks, labels[index.astype (int)])


def main (args):
    ms_seq = cluster.scan_xml_file (
        args.input,
        cluster.group_ms,
        cluster.group_capitular
    )

    mss = cluster.MSS
    if args.sort:
        mss = sorted (mss)

    capits = set ()
    for ms in mss:
        capits.update (ms_seq[ms])
    capits = sorted (capits, key = cluster.natural_sort_key)

    # every capit gets a different color
    capit_index = { capit : n + 1 for n, capit in enumerate (capits) }

    err ('mss: %d' % len (mss))
    err ('capits: %d' % len (capits))

    # get the length of the longest ms
    max_ms_len = max ([len (seq) for seq in ms_seq.values ()])

    # a matrix of ms x autoinc
    matrix = np.empty ((len (mss), max_ms_len), dtype=float)
    matrix[:] = -np.inf # hide empty cells
    labels = np.empty (matrix.shape, object)

    sample_set = None
    if args.sample:
        sample_set = set (ms_seq[args.sample])
    if args.include:
        sample_set = set (args.include.split (','))
    if sample_set is not None:
        for k, v in capit_index.items ():
            if k not in sample_set:
                capit_index[k] = 0 # gray out

    for i, ms_id in enumerate (mss):
        for j, capit_id in enumerate (ms_seq[ms_id]):
            matrix[i, j] = capit_index[capit_id]
            labels[i, j] = re.sub ('^BK\.', '', capit_id)

    nlabels = 100

    f1, axes = plt.subplots (1, 1, figsize = cluster.PAPER)

    vmax = len (capits)
    im = cluster.heat_matrix (
        f1, axes, matrix,
        "Sequence of Capitulars in Manuscripts (%s)" % args.sorted_by,
        mss, nlabels, [], nlabels,
        cmap=cluster.colormap_sequence (),
        vmin = 1,
        vmax = vmax
    )

    colors = np.empty (matrix.shape, object)
    colors[:] = "black"
    colors[matrix < 0.25 * vmax] = "white"
    colors[matrix > 0.85 * vmax] = "white"
    cluster.label_matrix (im, labels, colors, rotation="90")

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
    parser.add_argument ('--include',
                         help="Only these Capitulars (eg. BK.1,BK.2,BK.5)")
    parser.add_argument ('--sample',
                         help="Only Capitulars from this Ms. (eg. st-gallen-sb-733)")
    parser.add_argument ('input',
                         help="Input file")

    args = parser.parse_args ()
    args.sorted_by = "Alphabetical" if args.sort else "by Date"
    main (args)
