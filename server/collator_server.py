"""This module implements the collator API for the Capitularia Application Server.

Endpoints
---------

.. http:post:: /collator/collate

   Collate sections of witnesses.

   **Example request**:

   .. sourcecode:: http

      POST /collator/collate HTTP/1.1
      Host: api.capitularia.uni-koeln.de
      Content-Type: application/json;charset=utf-8

      {
          "collate": [
              "BK.20a_3/bk-textzeuge",
              "BK.20b_3/bk-textzeuge",
              "BK.20b_3/vatikan-bav-reg-lat-263[V10]"
              "BK.20b_3/vatikan-bav-reg-lat-263[V10]?hands=XYZ"
              "BK.20b_3/vatikan-bav-reg-lat-263[V10]?hands=XYZ#2"
          ]
      }

   :reqjsonobj string[] collate: List of chapters to collate.  The items are of the form:
                                 corresp/ms_id[siglum]?hands=XYZ#ms_cap_n

   **Example response**:

   .. sourcecode:: http

      HTTP/1.1 200 OK
      Content-Type: application/json;charset=utf-8

      {
        "witnesses": [
          "BK.20a_3/bk-textzeuge",
          "BK.20b_3/bk-textzeuge",
          "BK.20b_3/vatikan-bav-reg-lat-263[V10]"
        ],
        "table":[
          [ [ {"t": "A",     "n": "a" } ],     [ {"t": "A",      "n": "a" } ] ],
          [ [ {"t": "black", "n": "black" } ], [ {"t": "white",  "n": "white" } ] ],
          [ [ {"t": "cat",   "n": "cat" } ],   [ {"t": "kitten", "n": "kitten" } ] ]
        ]
      }

   :resheader Content-Type: application/json;charset=utf-8
   :statuscode 200: No errors.
   :resjsonobj string[] witnesses: List of manuscript ids.
   :resjsonobj array table: The collated tokens.

"""

import functools
import json
import re
from typing import Optional, Tuple, List, Sequence, Dict
import urllib.parse

import flask
from flask import current_app, request, Blueprint
import werkzeug

from super_collator.aligner import Aligner
from super_collator.ngrams import NGrams

import common
from db_tools import execute


class Config(object):
    pass


class CollatorError(werkzeug.exceptions.HTTPException):
    def __init__(self, msg):
        super().__init__(self)
        self.code = 500
        self.description = msg.decode("utf-8")


def handle_collator_error(e):
    return flask.Response(e.description, e.code, mimetype="text/plain")


class CollatorBlueprint(Blueprint):
    def init_app(self, app):
        app.config.from_object(Config)
        app.register_error_handler(CollatorError, handle_collator_error)


app = CollatorBlueprint("collator", __name__)

WHOLE_TEXT_PATTERNS = [
    n.split("=")
    for n in """
ae=e
ę=e
j=i
""".split()
    if n
]

RE_WHITESPACE_EQUIV_CHARS = re.compile("[-.,:;!?_*/]")


def normalize_with_patterns(patterns, text, whole_words=False):
    """Normalize text using a list of patterns"""

    normalized = text
    if whole_words:
        for p in patterns:
            search, replace = p
            normalized = re.sub(r"\b" + search + r"\b", replace, normalized)
    else:
        for p in patterns:
            search, replace = p
            normalized = normalized.replace(search, replace)
    return normalized


def preprocess(text: str, normalizations: Optional[List[str]] = None) -> List[List[NGrams]]:
    """Preprocess the input to the collator

    Builds the representation for one witness.  Returns an object that must be
    combined into the witnesses array.

    :param string[] normalizations: List of string in the form: oldstring=newstring
                                    Normalizations applied to each word.

    :return: The representation of one witness.

    """

    text = text or ""
    text = text.strip().lower()
    text = common.RE_BRACKETS.sub("", text)
    text = RE_WHITESPACE_EQUIV_CHARS.sub("", text)

    norm = normalize_with_patterns(WHOLE_TEXT_PATTERNS, text)

    normalizations = normalizations or []
    patterns = [n.split("=") for n in normalizations if n]
    if patterns:
        norm = normalize_with_patterns(patterns, norm, True)

    tsplit = text.split()
    nsplit = norm.split()
    assert len(tsplit) == len(nsplit)

    res = []
    for t, n in zip(tsplit, nsplit):
        res.append([memoized_ngrams(t, n)])
    return res

NGRAMS_CACHE : Dict[str,NGrams] = {}

def memoized_ngrams(t, n):
    if ngrams := NGRAMS_CACHE.get(t):
        return ngrams
    ngrams = NGrams([{"t" : t, "n" : n}])
    ngrams.load(n, 3)
    ngrams.hash = hash(ngrams)
    NGRAMS_CACHE[t] = ngrams
    return ngrams

@functools.lru_cache(maxsize=10000)
def memoized_similarity(a, b):
    return -1.0 + 2.0 * NGrams.similarity(a, b) # like we did in collatex

def similarity(aa: List[NGrams], bb: List[NGrams]) -> float:
    sim = -1.0
    for a in aa:
        for b in bb:
            if (a.hash < b.hash):
                score = memoized_similarity(a, b)
            else:
                score = memoized_similarity(b, a)

            if score > sim:
                sim = score
    return sim

@app.route("/collate", methods=["POST"])
def collate():
    """Implements the /collator/collate endpoint."""

    json_in = {
        "normalizations": [],
        "collate": [],
    }
    json_in.update(request.get_json())

    current_app.logger.info(json.dumps(json_in, indent=4))

    normalizations: List[str] = json_in["normalizations"]
    sequences: List[List[NGram]] = []

    # build the sequences to collate
    with current_app.config.dba.engine.begin() as conn:
        for w in json_in["collate"]:
            u = urllib.parse.urlparse(w)
            corresp, ms_id = u.path.split("/", 2)
            hands = urllib.parse.parse_qs(u.query).get("hands") == ["XYZ"]

            catalog, no, chapter = common.normalize_corresp(corresp)

            params = {
                "ms_id": ms_id,
                "cap_id": "%s.%s" % (catalog, no),
                "mscap_n": int(u.fragment or "1"),
                "chapter": chapter or "",
                "type": "later_hands" if hands else "original",
            }

            # current_app.logger.info (params)

            res = execute(
                conn,
                """
            SELECT text
            FROM mss_chapters_text
            WHERE (ms_id, cap_id, mscap_n, chapter, type) = (:ms_id, :cap_id, :mscap_n, :chapter, :type)
            """,
                params,
            )

            doc = res.fetchone()[0]
            # current_app.logger.info (doc)
            sequences.append(preprocess(doc, normalizations))

    # Produce a multi-alignment by naively aligning the sequences in the order they
    # arrived.  A better (but much more computationally expensive) method would be to
    # first ascertain the similarity of each manuscript pair (time-complexity of O(n²)
    # in the number of manuscripts) and then align them starting with the two most
    # similar ones.
    aligner = Aligner()
    aligner.open_score = -1.0
    aligner.extend_score = -0.5
    aligner.start_score = aligner.open_score

    aa = sequences[0]
    for n, bb in enumerate(sequences[1:], start=1):
        aa, bb, score = aligner.align(aa, bb, similarity,
            lambda: [memoized_ngrams("-", "")] * n,
            lambda: [memoized_ngrams("-", "")]
        )
        aa = [a + b for a, b in zip(aa, bb)]

    json_data = {
        "witnesses": json_in["collate"],
        "table": [[n.user_data for n in a] for a in aa],
    }

    current_app.logger.info(json.dumps(json_data, indent=4))

    return flask.make_response(
        flask.json.jsonify(json_data),
        200,
        {
            "Content-Type": "application/json;charset=utf-8",
        },
    )
