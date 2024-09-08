# -*- encoding: utf-8 -*-

import collections
import itertools
import operator
import re

import networkx as nx
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

from sklearn.feature_extraction.text import TfidfTransformer

from lxml import etree
import sklearn.cluster

NAMESPACES = {
    "tei": "http://www.tei-c.org/ns/1.0",
    "xml": "http://www.w3.org/XML/1998/namespace",
}

A4 = (8.267, 11.692)  # inches
A4R = (11.692, 8.267)  # inches
PAPER = A4R

MSS = """
    berlin-sb-lat-qu-931
    cava-dei-tirreni-bdb-4
    gotha-flb-memb-i-84
    heiligenkreuz-sb-217
    ivrea-bc-xxxiii
    ivrea-bc-xxxiv
    modena-bc-o-i-2
    muenchen-bsb-lat-19416
    muenchen-bsb-lat-29555-1
    muenchen-bsb-lat-3853
    muenchen-bsb-lat-6360
    paris-bn-lat-3878
    paris-bn-lat-4613
    salzburg-bea-st-peter-a-ix-32
    st-gallen-sb-733
    st-paul-abs-4-1
    vatikan-bav-chigi-f-iv-75
    vatikan-bav-reg-lat-1000b
    vatikan-bav-reg-lat-263
    vatikan-bav-vat-lat-5359
    vercelli-bce-clxxiv
    vercelli-bce-clxxv
    wien-oenb-ser-n-3761
    wolfenbuettel-hab-blankenb-130
""".split()


def natural_sort_key(key):
    def f(mo):
        s = mo.group(0)
        return str(len(s)) + s

    return re.sub("([0-9]+)", f, key)


def natural_sort_bk(key):
    m = re.match("^BK.([0-9]+)(.*)$", key)
    if m:
        return m.group(1).zfill(3) + m.group(2)
    m = re.match("^Mordek.([0-9]+)(.*)$", key)
    if m:
        return "M" + m.group(1).zfill(2) + m.group(2)
    return key


RE_BK = re.compile(r"^(BK|Mordek|Ansegis)?(?:[.\s]*)([0-9]*)(.*)$")

BK_SERIES = [
    ("1", "BK", ""),
    ("2", "Mordek", "M"),
    ("3", "Ansegis", "A"),
]

BK_TO_KEY = dict([(v[1], v[0]) for v in BK_SERIES])
KEY_TO_SERIES = dict([(v[0], v[1]) for v in BK_SERIES])
KEY_TO_SHORT = dict([(v[0], v[2]) for v in BK_SERIES])


def bk_to_key(bk):
    """Return a natural sorting key for BKs"""
    m = RE_BK.match(bk)
    if m:
        series, n, suffix = m.group(1, 2, 3)
        series = series or "BK"
        res = BK_TO_KEY[series]
        res += str(n or 0).zfill(3)
        res += str(ord(suffix) - 96) if suffix else "0"
        # if chapter:
        #    res += str (chapter).zfill (2)
        return res
    raise ValueError(bk)


def key_to_bk(key):
    """Inverse of bk_to_key"""

    series = KEY_TO_SERIES[key[0]]
    bk = key[1:4]
    suffix = int(key[4])
    suffix = chr(suffix + 96) if suffix > 0 else ""

    return series + str(int(bk)) + suffix.strip()


def key_to_short(key):
    """Return a short for of BK number"""
    series = KEY_TO_SHORT[key[0]]
    bk = str(int(key[1:4]))
    suffix = int(key[4])
    suffix = chr(suffix + 96) if suffix > 0 else ""

    return series + bk + suffix


def key_to_df(key):
    """Return a BK in a form suited for dataframes"""
    series = KEY_TO_SHORT[key[0]]
    bk = key[1:4]
    suffix = int(key[4])
    suffix = chr(suffix + 96) if suffix > 0 else ""

    return series + bk + suffix


def do_include_args(args, ms_seq):
    """Handle the --include-bks and --include-mss commandline arguments."""

    bks = []

    if args.include_bks:
        last_bk = get_max_bk(ms_seq)
        try:
            for value in re.split(r"[\s,]+", args.include_bks):
                r = value.split("-")
                if len(r) == 1:
                    bks.append(bk_to_key(value))
                elif len(r) == 2:
                    r[0] = r[0] or "BK.1"
                    r[1] = r[1] or last_bk

                    m1 = RE_BK.match(r[0])
                    m2 = RE_BK.match(r[1])
                    series1, n1, suffix1 = m1.group(1, 2, 3)
                    series2, n2, suffix2 = m2.group(1, 2, 3)
                    series1 = series1 or "BK."
                    series2 = series2 or series1
                    n1 = int(n1)
                    n2 = int(n2)

                    if series1 != series2:
                        raise ValueError("only one series allowed in range")
                    if 0 >= n1 >= n2:
                        raise ValueError("start >= stop in range")
                    if suffix1 or suffix2:
                        raise ValueError("no suffixes allowed in range")

                    bks.extend([bk_to_key(series1 + str(n)) for n in range(n1, n2 + 1)])
                else:
                    raise ValueError

        except ValueError:
            raise ValueError("error in range parameter")

    ms_seq_old = dict(ms_seq.items())
    ms_seq = collections.OrderedDict()
    mss = re.split(r"[\s,]+", args.include_mss) if args.include_mss else MSS

    if args.sort:
        mss = sorted(mss, key=natural_sort_key)

    for ms in mss:
        if ms in ms_seq_old:
            ms_seq[ms] = ms_seq_old[ms]

    if args.mss_must_contain:
        bk_set = set(map(bk_to_key, re.split(r"[\s,]+", args.mss_must_contain)))
        for ms in list(ms_seq):
            if len(bk_set.intersection(ms_seq[ms])) == 0:
                del ms_seq[ms]

    if args.output:
        include_bks = pretty_print(bks)
        args.output = args.output.format(
            **{"include-bks": include_bks.replace(" ", "_")}
        )

    args.include_bks = bks
    return ms_seq


def add_range_args(parser):
    parser.add_argument(
        "--include-bks", help="BK range to convert: eg. BK.20a BK.39-41 BK.201-"
    )
    parser.add_argument(
        "--include-mss", help="Only Mss. in this list (eg. st-gallen-sb-733 ...)"
    )
    parser.add_argument(
        "--mss-must-contain", help="Exclude all Mss. that don't contain any of these BK"
    )


def pretty_print(bks):
    """Return list of BKs as pretty string."""

    result = []
    for dummy_k, group in itertools.groupby(
        enumerate(bks), lambda x: 10 * int(x[0]) - int(x[1])
    ):
        subrange = [g[1] for g in group]
        if len(subrange) == 1:
            result.append(key_to_short(subrange[0]))
        elif len(subrange) == 2:
            result.append(key_to_short(subrange[0]))
            result.append(key_to_short(subrange[1]))
        else:
            result.append(
                "%s-%s" % (key_to_short(subrange[0]), key_to_short(subrange[-1]))
            )
    return " ".join(result)


def classify(bk):
    m = re.match(r"^(BK|Mordek)\.(\d+)(.*)$", bk)
    if m:
        is_bk = m.group(1) == "BK"
        label = ("" if is_bk else "M") + m.group(2) + m.group(3)
        no = int(m.group(2))
        # BK   1-131  Mordek  1-14  < 814
        # BK 132-202  Mordek 15-24  LdF
        # BK 203-307  Mordek 25-26  > 840
        if is_bk:
            class_ = "-814"
            if no >= 132:
                class_ = "LdF"
            if no >= 203:
                class_ = "840-"
        else:
            class_ = "-814"
            if no >= 15:
                class_ = "LdF"
            if no >= 25:
                class_ = "840-"
        return {"label": label, "class": class_}
    return {"label": bk, "class": "Unclassified"}


def tf_idf(args, df):
    transformer = TfidfTransformer(norm=None)  # we normalize in to_similarity_matrix ()
    return pd.DataFrame(
        transformer.fit_transform(df.values).toarray(),
        index=df.index,
        columns=df.columns,
    )


METRICS = ("cosine", "jaccard")


def to_similarity_matrix(df, metric):
    D = sklearn.metrics.pairwise_distances(df.values, metric=metric)
    if metric == "jaccard":
        D[np.isnan(D)] = 1.0
    D = 1.0 - D
    return pd.DataFrame(D, index=df.index, columns=df.index)


def hierarchical_cluster(D, labels):
    """https://en.wikipedia.org/wiki/Community_structure"""

    model = sklearn.cluster.DBSCAN()
    # print (D)
    model.fit(D)

    # print clustering results
    for label in set(model.labels_):
        if label == -1:
            continue
        print(label)
        for name, lab in zip(labels, model.labels_):
            if lab == label:
                print(name)


def colormap_affinity():
    return plt.cm.YlOrRd


def colormap_idf():
    return plt.cm.jet  # cool


def colormap_sequence():
    return plt.cm.jet


def unique_justseen(iterable, key=None):
    "List unique elements, preserving order. Remember only the element just seen."
    # unique_justseen('AAAABBBCCDAABBB') --> A B C D A B
    # unique_justseen('ABBCcAD', str.lower) --> A B C A D
    return map(next, map(operator.itemgetter(1), itertools.groupby(iterable, key)))


def scan_xml_file(filename, unit="ms", type_="capitulare"):
    """
    Scan the TEI file.  Return dict of doc contents.

    """
    parser = etree.XMLParser(recover=True, remove_blank_text=True)
    doc = etree.parse(filename, parser=parser)

    ms_seq = collections.defaultdict(list)

    ms_id = None

    for e in doc.xpath(
        "//tei:milestone[@unit='{unit}']|//tei:item[@type='{type_}']".format(
            unit=unit, type_=type_
        ),
        namespaces=NAMESPACES,
    ):
        if e.tag == ("{%s}milestone" % NAMESPACES["tei"]):
            ms_id = e.get("n")
        else:
            ms_seq[ms_id] += (e.get("corresp") or e.text).split()

    for ms in ms_seq:
        ms_seq[ms] = list(map(bk_to_key, unique_justseen(ms_seq[ms])))

    return ms_seq


def get_max_bk(ms_seq):
    return max(itertools.chain.from_iterable(ms_seq.values()))


def heat_matrix(
    f,
    ax,
    m,
    ylabels,
    yticks,
    xlabels,
    xticks,
    cmap=colormap_affinity(),
    vmin=None,
    vmax=None,
):
    """Plot a heat map of the matrix."""

    if vmin is None:
        vmin = m.min()
    if vmax is None:
        vmax = m.max()

    cmap.set_under("0.5")

    im = ax.imshow(m, aspect="auto", cmap=cmap, vmin=vmin, vmax=vmax)

    xticks = range(0, len(xlabels), 1 + len(xlabels) // xticks)
    yticks = range(0, len(ylabels), 1 + len(ylabels) // yticks)
    xlabels = [xlabels[i] for i in xticks]
    ylabels = [ylabels[i] for i in yticks]

    ax.tick_params(
        top=True, bottom=False, labeltop=True, labelbottom=False, direction="out", pad=2
    )
    ax.set_xticks(xticks)
    ax.set_yticks(yticks)
    ax.set_xticklabels(xlabels, size=5, rotation=90)
    ax.set_yticklabels(ylabels, size=5)

    return im


def heat_matrix_df(f, ax, df, yticks, xticks, **kw):
    return heat_matrix(f, ax, df.values, df.index, yticks, df.columns, xticks, **kw)


def colorbar(im, cmap, cbarlabel=None, cbarticks=None):
    cbar = im.axes.figure.colorbar(im, cmap=cmap, fraction=0.1, pad=0.05)
    if cbarticks:
        cbar.set_ticks(cbarticks[0])
        cbar.set_ticklabels(cbarticks[1])
    if cbarlabel:
        cbar.ax.set_ylabel(
            cbarlabel, rotation=-90, va="bottom", size=8, fontweight="bold"
        )
    return cbar


def title(axes, args, default_title, **kw):
    kw_args = {"y": -0.08, "size": 10, "fontweight": "bold"}
    kw_args.update(kw)
    format_data = {
        "include-bks": pretty_print(args.include_bks),
        "sorted-by": args.sorted_by,
    }
    title = (args.title or default_title).format(**format_data)
    axes.set_title(title, **kw_args)


def annotate(im, labels, colors, **text_kw):
    kw = dict(
        horizontalalignment="center",
        verticalalignment="center",
        size=5,
    )
    kw.update(text_kw)

    for i in range(labels.shape[0]):
        for j in range(labels.shape[1]):
            im.axes.text(j, i, labels[i, j], color=colors[i, j], **kw)


def process(args, df):
    np.set_printoptions(threshold=np.nan)
    tf_kd = df.values

    # the number of capitulars
    K = df.shape[0]
    print("No. of Capitulars: %d (rows)" % K)

    # the number of documents
    D = df.shape[1]
    print("No. of Documents: %d (columns)" % D)

    # the number of documents that include capitular k
    df_k = np.sum(tf_kd, axis=1).reshape(1, K).T
    # print ('df_k: %s' % df_k)

    # the inverse document frequency of capitular k
    # (the overall weight of k in discerning document similarity)
    idf_k = np.log(D / df_k)
    idf_k[np.isinf(idf_k)] = 0.0  # no document contains k
    # print ('idf_k: %s' % idf_k)

    # the tf-idf weight of capitular k in document d
    tf_idf_kd = tf_kd * idf_k
    # print ('tf_idf_kd: %s' % tf_idf_kd)

    # the number of capitulars in document d
    tf_d = np.sum(tf_kd, axis=0).reshape(1, D)
    # print ('tf_d: %s' % tf_d)

    # the inverse capitular frequency of document d
    # (the overall weight of d in discerning capitular similarity)
    itf_d = np.log(K / tf_d)
    itf_d[np.isinf(itf_d)] = 0.0  # document has no capitulars
    # print ('itf_d: %s' % itf_d)

    # the df-itf weight of document d regarding capitular k
    df_itf_kd = tf_kd * itf_d
    # print ('df_itf_kd: %s' % df_itf_kd)

    Dms = dict()  # the distance matrix(es) of documents
    Dbk = dict()  # the distance matrix(es) of capitulars

    metric = "cosine"
    Dms[metric] = to_similarity_matrix(tf_idf_kd.T, metric)
    Dbk[metric] = to_similarity_matrix(df_itf_kd, metric)

    metric = "jaccard"
    Dms[metric] = to_similarity_matrix(tf_kd.T, metric)
    Dbk[metric] = to_similarity_matrix(tf_kd, metric)

    return Dms, Dbk, tf_idf_kd, df_itf_kd


def rest(args):
    if args.hierarchical_cluster:
        for i, metric in enumerate(METRICS):
            hierarchical_cluster(Dms[metric], mslabels)

        for i, metric in enumerate(METRICS):
            hierarchical_cluster(Dbk[metric], bklabels)

    if args.gephi:
        # Gephi graph of capitulars
        G = nx.Graph(Dbk["cosine"])
        for n, label in enumerate(bklabels):
            data = G.nodes[n]
            data.update(classify(label))
            data["size"] = 15 + math.sqrt(df_k[n, 0] * 100)

        G.remove_edges_from(nx.selfloop_edges(G))
        G.remove_nodes_from(list(nx.isolates(G)))

        nx.write_gexf(G, "/tmp/bk.gexf")

        # Gephi graph of documents
        G = nx.Graph(Dms["cosine"])
        for n, label in enumerate(mslabels):
            data = G.nodes[n]
            data["label"] = label
            data["size"] = 15 + math.sqrt(tf_d[0, n] * 100)

        G.remove_edges_from(nx.selfloop_edges(G))
        G.remove_nodes_from(list(nx.isolates(G)))

        nx.write_gexf(G, "/tmp/ms.gexf")
