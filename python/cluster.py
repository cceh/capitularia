# -*- encoding: utf-8 -*-

import collections
import itertools
import math
import operator
import re

import pandas as pd
import numpy as np
import matplotlib
import matplotlib.pyplot as plt

from sklearn.feature_extraction.text import TfidfTransformer

import lxml
from lxml import etree
import sklearn.cluster
from sklearn.metrics import pairwise_distances
import networkx as nx


NAMESPACES = {
    'tei' : 'http://www.tei-c.org/ns/1.0',
    'xml' : 'http://www.w3.org/XML/1998/namespace',
}

A4  = (8.267, 11.692) # inches
A4R = (11.692, 8.267) # inches
PAPER = A4R

MSS = """
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
modena-bc-o-i-2
gotha-flb-memb-i-84
vatikan-bav-chigi-f-iv-75
cava-dei-tirreni-bdb-4
""".split ()

ALL_MSS = """
    berlin-sb-lat-qu-931
    cava-dei-tirreni-bdb-4
    gotha-flb-memb-i-84
    heiligenkreuz-sb-217
    ivrea-bc-xxxiii
    ivrea-bc-xxxiv
    modena-bc-o-i-2
    muenchen-bsb-lat-19416
++    muenchen-bsb-lat-29555-1
    muenchen-bsb-lat-3853
    muenchen-bsb-lat-6360
    paris-bn-lat-3878
    paris-bn-lat-4613
    salzburg-bea-st-peter-a-ix-32
    st-gallen-sb-733
    st-paul-abs-4-1
    vatikan-bav-chigi-f-iv-75
++    vatikan-bav-reg-lat-1000b
    vatikan-bav-reg-lat-263
    vatikan-bav-reg-lat-5359
    vercelli-bce-clxxiv
    vercelli-bce-clxxv
    wien-oenb-ser-n-3761
    wolfenbuettel-hab-blankenb-130
""".split ()


def natural_sort_key (key):
    def f (mo):
        s = mo.group (0)
        return str (len (s)) + s
    return re.sub ('([0-9]+)', f, key)


def natural_sort_bk (key):
    m = re.match ('^BK.([0-9]+)(.*)$', key)
    if m:
        return m.group (1).zfill (3) + m.group (2)
    m = re.match ('^Mordek.([0-9]+)(.*)$', key)
    if m:
        return 'M' + m.group (1).zfill (2) + m.group (2)
    return key


def classify (bk):
    m = re.match (r'^(BK|Mordek)\.(\d+)(.*)$', bk)
    if m:
        is_bk = m.group (1) == 'BK'
        label = ('' if is_bk else 'M') + m.group (2) + m.group (3)
        no = int (m.group (2))
        # BK   1-131  Mordek  1-14  < 814
        # BK 132-202  Mordek 15-24  LdF
        # BK 203-307  Mordek 25-26  > 840
        if is_bk:
            class_ = '-814'
            if no >= 132:
                class_ = 'LdF'
            if no >= 203:
                class_ = '840-'
        else:
            class_ = '-814'
            if no >= 15:
                class_ = 'LdF'
            if no >= 25:
                class_ = '840-'
        return { 'label' : label, 'class' : class_ }
    return { 'label' : bk, 'class' : 'Unclassified' }


def tf_idf (args, df):
    transformer = TfidfTransformer (norm=None) # we normalize in to_similarity_matrix ()
    return pd.DataFrame (transformer.fit_transform (df.values).toarray (),
                         index = df.index, columns = df.columns)


METRICS = ('cosine', 'jaccard')

def to_similarity_matrix (df, metric):
    D = sklearn.metrics.pairwise_distances (df.values, metric=metric)
    if metric == 'jaccard':
        D[np.isnan (D)] = 1.0
    D = 1.0 - D
    return pd.DataFrame (D, index = df.index, columns = df.index)


def hierarchical_cluster (D, labels):
    """ https://en.wikipedia.org/wiki/Community_structure """

    model = sklearn.cluster.DBSCAN ()
    # print (D)
    model.fit (D)

    # print clustering results
    for label in set (model.labels_):
        if label == -1:
            continue
        print (label)
        for name, l in zip (labels, model.labels_):
            if l == label:
                print (name)


def colormap_affinity ():
    return plt.cm.YlOrRd


def colormap_idf ():
    return plt.cm.jet # cool


def colormap_sequence ():
    return plt.cm.jet


def unique_justseen (iterable, key=None):
    "List unique elements, preserving order. Remember only the element just seen."
    # unique_justseen('AAAABBBCCDAABBB') --> A B C D A B
    # unique_justseen('ABBCcAD', str.lower) --> A B C A D
    return map (next, map (operator.itemgetter (1), itertools.groupby (iterable, key)))


def scan_xml_file (filename, unit = 'ms', type_ = 'capitulare'):
    """
    Scan the TEI file.  Return dict of doc contents.

    """
    parser = etree.XMLParser (recover = True, remove_blank_text = True)
    doc = etree.parse (filename, parser = parser)

    ms_seq = collections.defaultdict (list)

    ms_id = None

    for e in doc.xpath (
            "//tei:milestone[@unit='{unit}']|//tei:item[@type='{type_}']"
            .format (unit = unit, type_ = type_),
            namespaces = NAMESPACES):
        if e.tag == ('{%s}milestone' % NAMESPACES['tei']):
            ms_id = e.get ('n')
        else:
            ms_seq[ms_id] += (e.get ('corresp') or e.text).split ()

    for ms in ms_seq:
        ms_seq[ms] = list (unique_justseen (ms_seq[ms]))

    return ms_seq


def heat_matrix (f, ax, m, caption,
                 ylabels, yticks, xlabels, xticks,
                 cmap = colormap_affinity (),
                 vmin = None, vmax = None):

    """ Plot a heat map of the matrix. """

    if vmin is None:
        vmin = m.min ()
    if vmax is None:
        vmax = m.max ()

    cmap.set_under ('0.5')

    im = ax.imshow (m, aspect = 'auto', cmap = cmap, vmin = vmin, vmax = vmax)

    xticks = range (0, len (xlabels), 1 + len (xlabels) // xticks)
    yticks = range (0, len (ylabels), 1 + len (ylabels) // yticks)
    xlabels = [xlabels[i] for i in xticks]
    ylabels = [ylabels[i] for i in yticks]

    ax.tick_params (top = True, bottom = False, labeltop = True, labelbottom = False,
                    direction = 'out', pad = 2)
    ax.set_xticks (xticks)
    ax.set_yticks (yticks)
    ax.set_xticklabels (xlabels, size=5, rotation=90)
    ax.set_yticklabels (ylabels, size=5)

    ax.set_title (caption, y = -0.08, size=10, fontweight="bold")

    return im


def heat_matrix_df (f, ax, df, caption, yticks, xticks, **kw):
    return heat_matrix (f, ax, df.values, caption, df.index, yticks, df.columns, xticks, **kw)


def colorbar (im, cmap, cbarlabel=None, cbarticks = None):
    cbar = im.axes.figure.colorbar (im, cmap=cmap, fraction=0.1, pad=0.05)
    if cbarticks:
        cbar.set_ticks (cbarticks[0])
        cbar.set_ticklabels (cbarticks[1])
    if cbarlabel:
        cbar.ax.set_ylabel (cbarlabel, rotation=-90, va="bottom", size=8, fontweight="bold")
    return cbar


def annotate (im, labels, colors, **text_kw):
    kw = dict (
        horizontalalignment="center",
        verticalalignment="center",
        size = 5,
    )
    kw.update (text_kw)

    for i in range (labels.shape[0]):
        for j in range (labels.shape[1]):
            im.axes.text (j, i, labels[i,j], color=colors[i,j], **kw)


def process (args, df):
    np.set_printoptions (threshold=np.nan)
    mslabels = df.index
    bklabels = df.columns
    tf_kd    = df.values

    # the number of capitulars
    K = df.shape[0]
    print ('No. of Capitulars: %d (rows)' % K)

    # the number of documents
    D = df.shape[1]
    print ('No. of Documents: %d (columns)' % D)

    # the number of documents that include capitular k
    df_k = np.sum (tf_kd, axis = 1).reshape (1, K).T
    # print ('df_k: %s' % df_k)

    # the inverse document frequency of capitular k
    # (the overall weight of k in discerning document similarity)
    idf_k = np.log (D / df_k)
    idf_k[np.isinf (idf_k)] = 0.0 # no document contains k
    # print ('idf_k: %s' % idf_k)

    # the tf-idf weight of capitular k in document d
    tf_idf_kd = tf_kd * idf_k
    # print ('tf_idf_kd: %s' % tf_idf_kd)

    # the number of capitulars in document d
    tf_d = np.sum (tf_kd, axis = 0).reshape (1, D)
    # print ('tf_d: %s' % tf_d)

    # the inverse capitular frequency of document d
    # (the overall weight of d in discerning capitular similarity)
    itf_d = np.log (K / tf_d)
    itf_d[np.isinf (itf_d)] = 0.0 # document has no capitulars
    # print ('itf_d: %s' % itf_d)

    # the df-itf weight of document d regarding capitular k
    df_itf_kd = tf_kd * itf_d
    # print ('df_itf_kd: %s' % df_itf_kd)

    Dms = dict () # the distance matrix(es) of documents
    Dbk = dict () # the distance matrix(es) of capitulars

    metric = 'cosine'
    Dms[metric] = to_similarity_matrix (tf_idf_kd.T, metric)
    Dbk[metric] = to_similarity_matrix (df_itf_kd,   metric)

    metric = 'jaccard'
    Dms[metric] = to_similarity_matrix (tf_kd.T, metric)
    Dbk[metric] = to_similarity_matrix (tf_kd,   metric)

    return Dms, Dbk, tf_idf_kd, df_itf_kd
