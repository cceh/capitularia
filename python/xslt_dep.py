#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#

"""Draw graphs for Capitularia docs.

Draws a graph of XML to HTML data-flow by reading specially-encoded metadata in
the first comment of XSL-Stylesheets.

Draws a dependency graph of XSL-Stylesheets by reading the xsl:include and
xsl:import statements.

Outputs a graphviz .dot file or a HTML table or Makefile dependencies.

Internally uses a triple store for the relations between files.

Implements a 'little language' that reads a list of commands from stdin.
Commands are separated by newlines.

- read filename scans an XSL-Stylesheet.
- recurse follows-up xsl:import and xsl:include statements
- load filename load a triple store
- save filename saves a triple store in turtle format
- io filename adds data-flow predicates to the output graph
- dep filename adds dependency predicates to the output graph
- dot filename outputs a graphviz dot file
- make filename outputs a Makefile dependencies
- html filename outputs a HTML table

.. code::

   read my-style.xsl
   read more-styles-*.xsl
   recurse
   dep *.xsl
   dot my-style-dependencies.dot

.. code::

   read *.xsl
   save styles.ttl

.. code::

   load styles.ttl
   io first.xsl
   io second.xsl
   io third.xsl
   dot styles-dataflow.dot

"""

import argparse
import glob
import html
import os.path
import re
import urllib.parse
import sys

from lxml import etree

import rdflib
from rdflib import Literal, URIRef, Namespace, RDF

ARGS = argparse.Namespace()
PARSER = etree.XMLParser(recover=True)

ROOT = "http://capitularia.uni-koeln.de/"

# The (completely made up on the spot) Capitularia Ontology
#
CAP = Namespace("http://capitularia.uni-koeln.de/rdf/")

# CAP.version  the xslt version of a stylesheet
# CAP.depends  an output file depends on an input file or
#              a stylesheet depends on an included stylesheet
# CAP.inputs   a stylesheet reads this file
# CAP.outputs  a stylesheet outputs this file
# CAP.params   a parameter to add to the transform to yields the file
# CAP.urls     a file has this url
# CAP.scrapes  a command scrapes this file into the postgres database
# CAP.target   the makefile target that builds this file
# CAP.nomake   don't output this dependency in Makefile mode
# CAP.constraint in dot layout produces constraint=object
# CAP.xsl      the file is a stylesheet
# CAP.xml      the file is an XML file
# CAP.html     you got the idea


# Some XML Namespaces
NAMESPACES = {
    "cap": "http://cceh.uni-koeln.de/capitularia",
    "fn": "http://www.w3.org/2005/xpath-functions",
    "tei": "http://www.tei-c.org/ns/1.0",
    "xml": "http://www.w3.org/XML/1998/namespace",
    "xs": "http://www.w3.org/2001/XMLSchema",
    "xsl": "http://www.w3.org/1999/XSL/Transform",
}


g = rdflib.Graph()
g.bind("cap", CAP)
g.bind("rdf", RDF)

# rdf:	http://www.w3.org/1999/02/22-rdf-syntax-ns#
# rdfs:	http://www.w3.org/2000/01/rdf-schema#
# xsd:	http://www.w3.org/2001/XMLSchema#
# fn:	http://www.w3.org/2005/xpath-functions#
# sfn:	http://www.w3.org/ns/sparql#

mode = None


def uri(filename):
    return URIRef(urllib.parse.urljoin(ROOT, filename))


def deuri(uri):
    return uri[len(ROOT) :]


def shape(uri):
    return "box3d" if ("*" in uri) or ("%" in uri) or ("@" in uri) else "box"


def stdin(filename):
    return "/dev/stdin" if filename in (None, "", "-") else filename


def stdout(filename):
    return "/dev/stdout" if filename in (None, "", "-") else filename


def add_type(s, typ=None):
    if typ is None:
        directory, filename = os.path.split(s)
        filename, ext = os.path.splitext(filename)
        typ = CAP[ext[1:]]

    g.add((uri(s), RDF.type, typ))


def read(path, deps=False):
    uri_path = uri(path)

    if (uri_path, None, None) in g:
        return  # already scanned

    add_type(path, CAP.xsl)

    directory, filename = os.path.split(path)
    filename, ext = os.path.splitext(filename)
    tree = etree.parse(path, PARSER)

    for e in tree.xpath("/xsl:stylesheet", namespaces=NAMESPACES):
        g.add((uri_path, CAP.version, Literal(e.get("version"))))

    for e in tree.xpath("//xsl:include|//xsl:import", namespaces=NAMESPACES):
        dep = os.path.join(directory, e.get("href"))
        g.add((uri_path, CAP.depends, uri(dep)))
        if deps:
            read(dep)  # recurse

    for e in tree.xpath("//comment ()[1]"):
        for m in re.finditer(
            r"^\s*Transforms?:\s+(.*?)\s+->\s+(.*?)(?:\s+:\s+(.*))?$",
            e.text,
            re.IGNORECASE | re.MULTILINE,
        ):
            for fn_in in m.group(1).split():
                add_type(fn_in)
                uri_in = uri(os.path.join(directory, fn_in))
                g.add((uri_path, CAP.inputs, uri_in))
                for fn_out in m.group(2).split():
                    add_type(fn_out)
                    uri_out = uri(os.path.join(directory, fn_out))
                    g.add((uri_path, CAP.outputs, uri_out))
                    g.add((uri_out, CAP.depends, uri_in))
                    if m.group(3):
                        for p in m.group(3).split():
                            if p == "make=false":
                                g.add((uri_out, CAP.nomake, Literal("true")))
                            else:
                                g.add((uri_out, CAP.params, Literal(p)))

        for m in re.finditer(
            r"^\s*URL:\s+(.*?)\s+(.*)$", e.text, re.IGNORECASE | re.MULTILINE
        ):
            dep = os.path.join(directory, m.group(1))
            url = m.group(2)
            g.add((uri(dep), CAP.urls, uri(url)))
            add_type(url, CAP.urls)

        for m in re.finditer(
            r"^\s*Scrape:\s+(.*?)\s+(.*)$", e.text, re.IGNORECASE | re.MULTILINE
        ):
            target = m.group(1)
            dep = os.path.join(directory, m.group(2))
            g.add((uri(target), CAP.scrapes, uri(dep)))
            add_type(target, CAP.scrapes)

        for m in re.finditer(
            r"^\s*Target:\s+(.*?)\s+(.*)$", e.text, re.IGNORECASE | re.MULTILINE
        ):
            target = m.group(1)
            dep = os.path.join(directory, m.group(2))
            g.add((uri(target), CAP.target, uri(dep)))
            add_type(target, CAP.target)


def load(filename):
    g.parse(stdin(filename), format="turtle")


def save(filename):
    g.serialize(stdout(filename), format="turtle")


def recurse():
    """Pull in dependencies."""

    for row in g.query(
        """
            SELECT ?xsl ?dep
            WHERE {
               ?xsl a cap:xsl .
               ?xsl cap:depends ?dep .
            }
            ORDER BY ?xsl ?dep
            """
    ):

        read(deuri(row.dep), deps=True)


def update(arg):
    """Update graph."""

    g.update(arg)


def dep(subject):
    """Only do dependencies."""

    global mode
    mode = "dep"


def io(subject):
    """Only do input / output."""

    global mode
    mode = "io"


def gfilter(filt):
    """Apply user-supplied filter."""

    qres = g.query(
        """CONSTRUCT {?s ?p ?o}
        WHERE {
           ?s ?p ?o .
           FILTER (%s)
        }
        """
        % filt
    )

    for t in qres:
        g.add(t)


def render_dot_type(fp, s):
    ds = deuri(s)
    for typ in g.objects(s, RDF.type):
        if typ == CAP.xml:
            fp.write('  "%s" [shape=%s,color=green]\n' % (ds, shape(ds)))
        if typ == CAP.html:
            fp.write('  "%s" [shape=%s,color=red]\n' % (ds, shape(ds)))
        if typ == CAP.txt:
            fp.write('  "%s" [shape=%s,color=pink]\n' % (ds, shape(ds)))
        if typ == CAP.urls:
            fp.write('  "%s" [shape=%s,color=blue]\n' % (ds, shape(ds)))
        if typ == CAP.scrapes:
            fp.write(
                '  "%s" [label="import_data.py --%s",shape=cylinder,color=blue]\n'
                % (ds, ds)
            )


def render_dot(filename):
    """Render as dot file."""

    with open(stdout(filename), "w") as fp:
        fp.write("strict digraph G {\n")
        fp.write(
            '  graph [fontsize="10.0",fontname="sans",rankdir="LR",newrank=true];\n'
        )
        fp.write('  node  [rankdir="LR",fontsize="10.0",fontname="sans"];\n')
        fp.write('  edge  [fontsize="10.0",fontname="sans"];\n')

        # render xsl dependency graph
        if mode == "dep":
            for row in g.query(
                """
                SELECT DISTINCT ?version
                WHERE {
                   ?xsl a cap:xsl .
                   ?xsl cap:version ?version .
                }
                ORDER BY ?version
                """
            ):

                fp.write(
                    '  subgraph "cluster_%s" {\n    label="XSLT %s"\nlabeljust=l\n\n'
                    % (str(row.version), str(row.version))
                )

                for row2 in g.query(
                    """
                    SELECT DISTINCT ?xsl ?dep
                    WHERE {
                       ?xsl a cap:xsl .
                       ?xsl cap:version ?version .
                       OPTIONAL { ?xsl cap:depends ?dep . }
                    }
                    ORDER BY ?xsl
                    """,
                    initBindings={"version": row.version},
                ):

                    fp.write('    "%s"\n' % deuri(row2.xsl))
                    if row2.dep:
                        fp.write(
                            '    "%s" -> "%s"\n' % (deuri(row2.xsl), deuri(row2.dep))
                        )

                fp.write("  }\n")

        # render input/output graph

        if mode == "io":
            for row in g.query(
                """
                SELECT DISTINCT ?target (GROUP_CONCAT (?out) AS ?out)
                WHERE {
                   ?xsl cap:outputs ?out .
                   OPTIONAL { ?target cap:target ?out . }
                }
                GROUP BY ?target
                ORDER BY ?target
                """
            ):

                if row.target:
                    fp.write(
                        '  subgraph "cluster_%s" {\n    label="make %s"\nlabeljust=l\n\n'
                        % (deuri(row.target), deuri(row.target))
                    )
                for out in str(row.out).split():
                    render_dot_type(fp, URIRef(out))
                if row.target:
                    fp.write("  }\n")

            for row2 in g.query(
                """
                SELECT DISTINCT ?inp ?xsl ?out ?version
                WHERE {
                   ?out cap:depends ?inp .
                   ?xsl cap:outputs ?out .
                   ?xsl cap:inputs  ?inp .
                   ?xsl cap:version ?version .
                }
                ORDER BY ?out
                """
            ):

                render_dot_type(fp, row2.out)
                render_dot_type(fp, row2.inp)

                out = deuri(row2.out)

                fp.write('  "%s":e -> "%s"\n' % (deuri(row2.inp), deuri(row2.xsl)))

                labels = []
                props = []
                port = "w"
                if (row2.out, CAP.constraint, Literal("false")) in g:
                    props.append("constraint=false")
                    port = "_"
                for p in g.objects(row2.out, CAP.params):
                    labels.append(p)
                if labels:
                    props.append('label="%s"' % " ".join(labels))
                fp.write(
                    '  "%s" -> "%s":%s%s\n'
                    % (
                        deuri(row2.xsl),
                        deuri(row2.out),
                        port,
                        " [%s]" % ",".join(props) if props else "",
                    )
                )

            for out, p, url in g.triples((None, CAP.urls, None)):
                render_dot_type(fp, url)
                fp.write('  "%s":e -> "%s":w\n' % (deuri(out), deuri(url)))

            for scrapes, p, out in g.triples((None, CAP.scrapes, None)):
                render_dot_type(fp, scrapes)
                fp.write('  "%s":e -> "%s":w\n' % (deuri(out), deuri(scrapes)))

        fp.write("}\n")


def render_html(filename):
    """Render as HTML table."""

    with open(stdout(filename), "w") as fp:

        table = []
        for s, p, o in g.triples((None, CAP.depends, None)):
            table.append("<tr><td>%s</td><td>%s</td></tr>" % (s, o))

        if table:
            fp.write("<table><tbody>\n")
            fp.write("<tr><th>xsl</th><th>depends on</th></tr>\n")
            fp.write("\n".join(table))
            fp.write("\n</tbody></table>\n")

        table = []
        qres = g.query(
            """SELECT DISTINCT ?xsl ?ver
            WHERE {
               ?xsl ?p ?o .
               ?xsl cap:version ?ver .
               FILTER (?p IN (cap:inputs, cap:outputs))
            }
            ORDER BY ?xsl
            """
        )

        for row in qres:
            xsl = html.escape(deuri(row.xsl))
            ver = html.escape(row.ver)

            table.append("<tr>")
            table.append("<td>")
            for s, p, o in g.triples((row.xsl, CAP.inputs, None)):
                table.append("%s<br/>" % html.escape(deuri(o)))
            table.append("</td>")
            table.append("<td>%s (%s)</td>" % (xsl, ver))
            table.append("<td>")
            for s, p, o in g.triples((row.xsl, CAP.outputs, None)):
                table.append("%s<br/>" % html.escape(deuri(o)))
            table.append("</td>")
            table.append("</tr>")

        if table:
            fp.write("<table><tbody>\n")
            fp.write("<tr><th>input</th><th>xsl</th><th>output</th></tr>\n")
            fp.write("\n".join(table))
            fp.write("\n</tbody></table>\n")


def render_makefile(filename):
    """Render as make dependencies."""

    with open(stdout(filename), "w") as fp:
        fp.write("# generated by xslt_dep.py\n#\n")

        # output depends on inputs
        for row in g.query(
            """
            SELECT DISTINCT ?xsl ?inp ?out ?version
            WHERE {
               ?out cap:depends ?inp .
               ?xsl cap:outputs ?out .
               ?xsl cap:inputs  ?inp .
               ?xsl cap:version ?version .
               FILTER NOT EXISTS { ?out cap:nomake "true" }
            }
            ORDER BY ?out
            """
        ):

            qq = g.query(
                """
                SELECT DISTINCT ?xsl WHERE {
                   ?root cap:depends* ?xsl .
                }
                ORDER BY ?xsl
                """,
                initBindings={"root": row.xsl},
            )

            data = {
                "in": deuri(row.inp),
                "xsl": deuri(row.xsl),
                "out": deuri(row.out),
                "dep": "".join([" " + deuri(rrow.xsl) for rrow in qq]),
            }

            params = sorted(g.objects(row.out, CAP.params))
            if str(row.version) == "1.0":
                data["params"] = "".join(
                    [" --stringparam {} {}".format(*(o.split("="))) for o in params]
                )
                fp.write(
                    "{out} : {in}{dep}\n\t$(XSLTPROC){params} -o $@ {xsl} $<\n\n".format(
                        **data
                    )
                )
            else:
                data["params"] = "".join([" {}".format(o) for o in params])
                fp.write(
                    "{out} : {in}{dep}\n\t$(SAXON) -s:$< -xsl:{xsl} -o:$@{params}\n\n".format(
                        **data
                    )
                )

        # user requested to handle these manually (param: make=false)

        fp.write("\n#\n# unhandled file dependencies\n#\n\n")

        for row in g.query(
            """
            SELECT DISTINCT ?inp ?xsl ?out
            WHERE {
               ?out cap:depends ?inp  .
               ?xsl cap:outputs ?out .
               ?xsl cap:inputs  ?inp .
               ?out cap:nomake  "true" .
            }
            ORDER BY ?out ?inp
            """
        ):

            qq = g.query(
                """
                SELECT DISTINCT ?xsl
                WHERE {
                   ?root cap:depends* ?xsl .
                }
                ORDER BY ?xsl
                """,
                initBindings={"root": row.xsl},
            )

            data = {
                "in": deuri(row.inp),
                "xsl": deuri(row.xsl),
                "out": deuri(row.out),
                "dep": "".join([" " + deuri(rrow.xsl) for rrow in qq]),
            }
            fp.write("# {out} : {in}{dep}\n".format(**data))

        # targets and unhandled targets

        fp.write("\n#\n# targets\n#\n\n")

        for row in g.query(
            """
            SELECT DISTINCT ?t ?out
            WHERE {
               ?t cap:target ?out  .
            }
            ORDER BY ?t ?out
            """
        ):

            data = {
                "t": deuri(row.t),
                "out": deuri(row.out),
            }
            if "%" in data["out"]:
                fp.write("# ")
            fp.write("{t} : {out}\n".format(**data))


def main():
    for command in ARGS.e:
        command = command.strip()

        cmds = command.split(maxsplit=1)
        cmd = cmds[0]
        arg = cmds[1] if len(cmds) > 1 else None

        if cmd in ("r", "read"):
            for fn in glob.glob(arg, recursive=True):
                read(fn)
        if cmd in ("l", "load"):
            load(arg)
        if cmd in ("s", "save"):
            save(arg)
        if cmd in ("rec", "recurse"):
            recurse()
        if cmd == "dep":
            dep(arg)
        if cmd == "io":
            io(arg)
        if cmd in ("f", "filter"):
            gfilter(arg)
        if cmd == "update":
            update(arg)
        if cmd == "dot":
            render_dot(arg)
        if cmd == "html":
            render_html(arg)
        if cmd in ("make", "makefile"):
            render_makefile(arg)


if __name__ == "__main__":

    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter,  # don't wrap my description
        description=__doc__,
    )

    parser.add_argument(
        "-e",
        default=None,
        help="Commands to be executed, separated by ';'.  "
        "Default: read commands from stdin, separated by newlines.",
    )

    parser.parse_args(namespace=ARGS)

    if ARGS.e is None:
        ARGS.e = sys.stdin.readlines()
    else:
        ARGS.e = ARGS.e.split(";")

    main()
