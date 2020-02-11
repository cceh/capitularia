#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#

import argparse
import collections
import itertools
import operator
import os.path
import re
import subprocess
import sys

import lxml
from lxml import etree

from suffix_tree import Tree
from suffix_tree.util import Path

import cluster

def debug (*a, **kw):
    if args.debug:
        print (*a, file=sys.stderr, **kw)


def scan_ueberblick_mordek_file (filename):
    """
    Scan the ueberblick_mordek.xml file.

    Return dict of ms_id : list of capitularies.

    """
    parser = etree.XMLParser (recover = True, remove_blank_text = True)
    doc = etree.parse (filename, parser = parser)

    ms_seq = {}

    for e in doc.xpath ("//item[@xml:id]", namespaces = cluster.NAMESPACES):
        ms_id = e.get ('{%s}id' % cluster.NAMESPACES['xml'])
        ms_seq[ms_id] = []

        for c in e.xpath ("content/capit/term[@n]", namespaces = cluster.NAMESPACES):
            cap_id = c.get ('n')
            ms_seq[ms_id].append (cap_id)

    # only keep the first capitulary of runs
    for ms in ms_seq:
        ms_seq[ms] = list (map (cluster.natural_sort_bk, cluster.unique_justseen (ms_seq[ms])))

    return ms_seq


def freeze (node):
    positions = node.get_positions ()
    sd = node.string_depth () # length of string so far

    ms_ids = tuple (sorted ((i[0] for i in positions), key = cluster.natural_sort_key ))
    path   = positions[0][1]

    return Path (path.S, path.start, path.start + sd), ms_ids, sd


def main (args):
    ms_seq = scan_ueberblick_mordek_file (args.input)

    tree = Tree (ms_seq)

    tree.root.compute_C ()

    triples = []

    def f (node):
        k = node.C                # no. of distinct strings in the subtree
        sd = node.string_depth () # length of string so far
        if k >= 3 and sd >= 3:
            triples.append (freeze (node))

    tree.root.pre_order (f)

    # we need a second suffix tree so we don't output a shorter sequence of
    # capitularies with the same manuscripts after a longer one

    tree = Tree ()

    s = sorted (triples, key = lambda x: 999 - x[2]) # output longest seq first
    for path, ms_ids, sd in s:

        if not tree.find_id (ms_ids, path):
            print (path)
            for ms_id in ms_ids:
                print ("  %s" % ms_id)
            print ()
            tree.add (ms_ids, path)


if __name__ == '__main__':

    parser = argparse.ArgumentParser (
        formatter_class = argparse.RawDescriptionHelpFormatter,  # don't wrap my description
        description = """Find repetitions of capitularies."""
    )

    parser.add_argument ('input', help="Input file")

    args = parser.parse_args ()
    main (args)
