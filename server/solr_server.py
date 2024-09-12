"""Solr API server for Capitularia.

REST Interface to perform various Solr queries.


Endpoints
---------

.. http:get:: /solr/select.json/

   Perform a Solr search.

   **Example request**:

   .. sourcecode:: http

      GET /solr/select.json/?q=ludovicus&df=la_text HTTP/1.1
      Host: api.capitularia.uni-koeln.de

   **Example response**:

   .. sourcecode:: http

      HTTP/1.1 200 OK
      Content-Type: application/json

      {
          "responseHeader":{
              "status":0,
              "QTime":150,
              "params":{
                  "q":"episcopi",
                  "df":"text_la",
                  "hl":"true",
                  "indent":"true",
                  "q.op":"OR",
                  "useParams":"",
                  "_":"1719588708802"
              }
          },
          "response":{
              "numFound":2156,
              "start":0,
              "numFoundExact":true,
              "docs":[
              {
                  "ms_id":"cologny-bb-bodmer-107",
                  "cap_id":"BK.20a",
                  "mscap_n":"1",
                  "chapter":"2",
                  "type":"original",
                  "text_la":"De episcopis . ubi praesens episcopi ordinati non sunt",
                  "id":"cologny-bb-bodmer-107-bk-20a-1-2-original",
                  "category":["chapter"],
                  "post_status":"publish",
                  "_version_":1800756812436209665
              },
              ...
              ]
          },
          "highlighting":{
              "cologny-bb-bodmer-107-bk-20a-1-2-original":{
                  "text_la":["De <mark>episcopis</mark> . ubi praesens <mark>episcopi</mark> ordinati non sunt"]
              },
              ...
          }
        }

   :query string status: Optional.  'private' or 'publish'.  Default 'publish'.
                         Consider all manuscripts or just the published ones.
   :resheader Content-Type: application/json
   :statuscode 200: no error

"""

import logging
from urllib.parse import urljoin

import requests

from flask import current_app, request, Blueprint


class Config(object):
    SOLR_URL = "http://localhost:8983/solr/capitularia/"


class SolrBlueprint(Blueprint):
    def init_app(self, app):
        app.config.from_object(Config)


app = SolrBlueprint("solr", __name__)


def cache(response):
    response.headers["Cache-Control"] = "private, max-age=3600"
    return response


def get_status_param():
    status = request.args.get("status") or "publish"
    if status not in ("private", "publish"):
        raise ValueError("Unknown status.")
    return status


def stat():
    """Create a filter on page status."""

    if get_status_param() == "private":
        return "m.status IN ('private', 'publish')"
    return "m.status = 'publish'"


def fstat():
    """Create a filter on page status."""

    status = get_status_param()
    if status == "publish":
        return (
            "m.status IN ('private', 'publish') AND mc.chapter !~ '_incipit|_explicit'"
        )
    return "m.status = 'publish' AND mc.chapter !~ '_inscriptio|_incipit|_explicit'"


SOLR_PARAMS_WHITELIST = "q qf start rows sort hl.sort expand".split()


@app.route("/select.json", methods=["GET", "OPTIONS"])
def select():
    """Run a Solr query"""

    params = {
        "fq": request.args.getlist("fq"),
        "rows": 1000,
        "q.op": "AND",
        "qf": "text_la text_de text_en",
        "defType": "edismax",
        # "fl": "ms_id cap_id mscap_n chapter type ms_id_part notbefore notafter places cap_id_chapter id category post_status title_de score",
        "fl": "* score",
        "hl": "true",
        "hl.tag.pre": "<mark>",
        "hl.tag.post": "</mark>",
        "hl.snippets": 1000,
        "hl.bs.type": "WORD",
        "indent": "true",
        "expand.rows": 1000,
    }

    for name in SOLR_PARAMS_WHITELIST:
        params[name] = request.args.get(name)

    if get_status_param() == "publish":
        params["fq"].append("post_status:publish")

    url = urljoin(current_app.config["SOLR_URL"], "select")

    r = requests.get(url, params=params)
    # logging.info(r.content)
    return r.content
