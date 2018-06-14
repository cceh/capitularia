#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#

import argparse
import os.path

import numpy as np

import cluster

def load_feature_matrix (args):
    ms_seq = cluster.scan_xml_file (
        args.input,
        cluster.group_ms,
        cluster.group_capitular
    )

    mss = cluster.MSS
    if args.sort:
        mss = sorted (mss)
    inv_mss = { ms : n for n, ms in enumerate (mss) }

    capits = set ()
    for ms in mss:
        capits.update (ms_seq[ms])
    capits = sorted (capits, key = cluster.natural_sort_key)
    inv_capits = { capit : n for n, capit in enumerate (capits) }

    print ('mss: %d' % len (mss))
    print ('capits: %d' % len (capits))

    feature_matrix = np.zeros ((len (capits), len (mss)), dtype=bool)
    for ms in mss:
        for capitulum in ms_seq[ms]:
            feature_matrix[inv_capits[capitulum], inv_mss[ms]] = True

    return feature_matrix, capits, mss


if __name__ == '__main__':

    parser = argparse.ArgumentParser (
        formatter_class = argparse.RawDescriptionHelpFormatter,  # don't wrap my description
        description = """Build diagrams of Capitulars."""
    )

    parser.add_argument ('-s', '--sort', action='store_true',
                         help="Sort manuscripts alphabetically (default: by age)")
    parser.add_argument ('-p', '--plot', action='store_true',
                         help="Show plot on screen")
    parser.add_argument ('--gephi', action='store_true',
                         help="Output Gephi files")
    parser.add_argument ('--hierarchical_cluster', action='store_true',
                         help="Do scikit-learn hierarchical clustering")
    parser.add_argument ('-o', '--output',
                         help="Output file (eg. /tmp/file%s.png) (default: no output)")
    parser.add_argument ('input',
                         help="Input file")

    args = parser.parse_args ()
    args.sorted_by = "Alphabetical" if args.sort else "by Date"

    tf_kd, capitlabels, mslabels = load_feature_matrix (args)
    cluster.process (args, tf_kd, capitlabels, mslabels)
