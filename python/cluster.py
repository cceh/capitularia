# -*- encoding: utf-8 -*-

import collections
import math
import re

import matplotlib
import matplotlib.pyplot as plt

import lxml
from lxml import etree
import numpy as np
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


def group_capitular (text):
    text = text.split (' ')[0]
    text = text.split ('_')[0]
    return text


def group_chapter (text):
    text = text.split (' ')[0]
    return text


def group_ms (text):
    text = text.split ('_')[0]
    return text


def group_mspart (text):
    return text


def natural_sort_key (key):
    def f (mo):
        s = mo.group (0)
        return str (len (s)) + s
    return re.sub ('([0-9]+)', f, key)


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


METRICS = ('cosine', 'jaccard')

def to_similarity_matrix (M, metric):
    D = sklearn.metrics.pairwise_distances (M, metric=metric)
    if metric == 'jaccard':
        D[np.isnan (D)] = 1.0
    D = 1.0 - D
    return D


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


def scan_xml_file (filename, group_ms, group_cap):
    parser = etree.XMLParser (recover = True, remove_blank_text = True)
    doc = etree.parse (filename, parser = parser)

    ms_seq = collections.defaultdict (list)

    old_ms_id = None
    old_cap_id = None
    ms_id = None

    for e in doc.xpath (
            "//tei:milestone[@unit='ms' or @unit='msPart']|//tei:item[@type='capitulare' or @type='capitulum']",
            namespaces = NAMESPACES):
        if e.tag == ('{%s}milestone' % NAMESPACES['tei']):
            ms_id = group_ms (e.get ('n'))
            if old_ms_id != ms_id:
                old_cap_id = None
                old_ms_id = ms_id
        else:
            cap_id = group_cap (e.get ('corresp') or e.text)
            if old_cap_id != cap_id:
                ms_seq[ms_id].append (cap_id)
                old_cap_id = cap_id

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


def colorbar (im, cmap, cbarlabel=None, cbarticks = None):
    cbar = im.axes.figure.colorbar (im, cmap=cmap, fraction=0.1, pad=0.05)
    if cbarticks:
        cbar.set_ticks (cbarticks[0])
        cbar.set_ticklabels (cbarticks[1])
    if cbarlabel:
        cbar.ax.set_ylabel (cbarlabel, rotation=-90, va="bottom", size=8, fontweight="bold")
    return cbar


def label_matrix (im, labels, colors, **text_kw):
    kw = dict (
        horizontalalignment="center",
        verticalalignment="center",
        size = 5,
    )
    kw.update (text_kw)

    for i in range (labels.shape[0]):
        for j in range (labels.shape[1]):
            im.axes.text (j, i, labels[i,j], color=colors[i,j], **kw)


def process (args, tf_kd, bklabels, mslabels):

    assert len (tf_kd.shape) == 2
    assert len (bklabels) == tf_kd.shape[0]
    assert len (mslabels) == tf_kd.shape[1]

    np.set_printoptions (threshold=np.nan)

    # the number of capitulars
    K = len (bklabels)
    print ('No. of Capitulars: %d (rows)' % K)

    # the number of documents
    D = len (mslabels)
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

    nlabels = 100
    metric = 'cosine'

    ###

    f1, axes = plt.subplots (1, 1, figsize = PAPER)
    m = tf_idf_kd.T.copy ()
    vmin = m[m > 0].min ()
    m[m==0] = -np.inf # make background white

    im = heat_matrix (f1, axes, m,
                      "Manuscripts (%s) × Capitulars" % args.sorted_by,
                      mslabels, nlabels, bklabels, nlabels,
                      cmap=colormap_idf (),
                      vmin = vmin)
    colorbar (im, cmap = colormap_idf (),
              cbarlabel="Inverse Document Frequency of Capitular")

    ###

    f2, axes = plt.subplots (1, 1, figsize = PAPER)
    im = heat_matrix (f2, axes, Dms[metric],
                      "Manuscript (%s) Similarity" % args.sorted_by,
                      mslabels, nlabels, mslabels, nlabels,
                      cmap=colormap_affinity ())
    colorbar (im, cmap = colormap_affinity (),
              cbarlabel = 'Manuscript Similarity (cosine metric)')

    labels = np.around (Dms[metric], decimals = 2)
    colors = np.empty (Dms[metric].shape, object)
    colors[:] = "black"
    colors[Dms[metric] > 0.6] = "white"
    label_matrix (im, labels, colors, fontweight = "bold")

    ###

    f3, axes = plt.subplots (1, 1, figsize = PAPER)
    im = heat_matrix (f3, axes, Dbk[metric],
                      "Capitularia Similarity",
                      bklabels, nlabels, bklabels, nlabels,
                      cmap=colormap_affinity ())
    colorbar (im, cmap = colormap_affinity (),
              cbarlabel = 'Capitularia Similarity (cosine metric)')


    if args.output:
        for f, fn in ((f1, 'idf'), (f2, 'ms_sim'), (f3, 'cap_sim')):
            f.savefig (args.output % fn, dpi=300, transparent=False)

    if args.plot:
        plt.show ()

    if args.hierarchical_cluster:
        for i, metric in enumerate (METRICS):
            hierarchical_cluster (Dms[metric], mslabels)

        for i, metric in enumerate (METRICS):
            hierarchical_cluster (Dbk[metric], bklabels)

    if args.gephi:
        # Gephi graph of capitulars
        G = nx.Graph (Dbk['cosine'])
        for n, label in enumerate (bklabels):
            data = G.nodes[n]
            data.update (classify (label))
            data['size'] = 15 + math.sqrt (df_k[n,0] * 100)

        G.remove_edges_from (nx.selfloop_edges (G))
        G.remove_nodes_from (list (nx.isolates (G)))

        nx.write_gexf (G, "/tmp/bk.gexf")

        # Gephi graph of documents
        G = nx.Graph (Dms['cosine'])
        for n, label in enumerate (mslabels):
            data = G.nodes[n]
            data['label'] = label
            data['size'] = 15 + math.sqrt (tf_d[0,n] * 100)

        G.remove_edges_from (nx.selfloop_edges (G))
        G.remove_nodes_from (list (nx.isolates (G)))

        nx.write_gexf (G, "/tmp/ms.gexf")
