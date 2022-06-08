#!/usr/bin/env python3

import os.path
import re
import sys

from lxml import etree

XML = "http://www.w3.org/XML/1998/namespace"
TEI = "http://www.tei-c.org/ns/1.0"

fn = sys.argv[1]
base = os.path.basename(fn)
# base = fn

milestones = dict ()
seen_corresps = dict () # corresp, @xml:id
unresolved_span_tos = dict ()
ab_spans = list ()
current_capitulars = set ()
in_capitulatio = None

def error(elem, msg):
    print ("%s:%d: [ERROR] %s" % (base, elem.sourceline, msg))

def info(elem, msg):
    print ("%s:%d: [INFO] %s" % (base, elem.sourceline, msg))

RE_CAP = r"^((?:BK|Mordek)\.\d+[a-z]?)"

def matches_capitulars(corresp, capitulars):
    m = re.match(RE_CAP, corresp)
    if not m:
        return True # not interested
    corresp = m.group(1)
    for cap in capitulars:
        m = re.match(RE_CAP, cap)
        if m and corresp == m.group(1):
            return True
    return False

def span (elem, corresps):
    prev = elem.get ("prev")
    next_ = elem.get ("next")
    xml_id = elem.get ("{%s}id" % XML)

    for c in corresps:
        if not in_capitulatio and not matches_capitulars(c, current_capitulars):
            error (elem, "corresp %s in milestone @unit=capitulare @n=%s" % (c, " ".join(current_capitulars)))

        if c in seen_corresps:
            prev_elem = seen_corresps[c]
            prev_elem_id = prev_elem.get("{%s}id" % XML)
            prev_elem_next = prev_elem.get("next")

            if not prev_elem_next:
                error (prev_elem, "duplicate corresp %s without @next" % c)
            elif xml_id != prev_elem_next.lstrip("#"):
                error (prev_elem, "duplicate corresp %s with bogus @next=%s" % (c, prev_elem_next))

            if not prev:
                error (elem, "duplicate corresp %s without @prev" % c)
            elif prev.lstrip("#") != prev_elem_id:
                error (elem, "duplicate corresp %s with bogus @prev=%s" % (c, prev))

        seen_corresps[c] = elem

for event, elem in etree.iterparse(fn):
    xml_id = elem.get ("{%s}id" % XML)
    corresp = elem.get ("corresp", "")
    corresps = set(corresp.split())

    if elem.tag == "{%s}milestone" % TEI:
        unit = elem.get("unit")
        if unit == "capitulare":
            current_capitulars.clear()
            n = elem.get ("n")
            if not n:
                error (elem, "milestone @unit=capitulare without @n")
            else:
                if n in milestones:
                    error (elem, "duplicate milestone @unit=capitulare @n=%s" % n)
                    info (milestones[n], "... previous milestone was here")
                milestones[n] = elem
                current_capitulars = set(n.split())
            seen_corresps.clear ()
        elif unit == "capitulatio":
            span_to = elem.get("spanTo")
            span_to = span_to.lstrip("#")
            unresolved_span_tos[span_to] = elem
            in_capitulatio = span_to
        elif unit == "span":
            ab_spans.append(elem)
            span_to = elem.get ("spanTo")
            if not span_to:
                error (elem, "span with @corresp=%s without @spanTo" % corresp)
            else:
                span_to = span_to.lstrip("#")
                if span_to in unresolved_span_tos:
                    error (elem, "duplicate @spanTo=%s" % span_to)
                    info (unresolved_span_tos[span_to], "... previous @spanTo was here")
                else:
                    unresolved_span_tos[span_to] = elem

            if not corresps:
                error (elem, "span without corresp")
            else:
                span (elem, corresps)
        continue

    if elem.tag == "{%s}ab" % TEI:
        # check spans
        if ab_spans: # if the <ab> contains spans
            # check if the corresp on the <ab> and the spans match
            # the spans themselves where already checked
            span_corresps = set()
            for e in ab_spans:
                span_corresps |= set(e.get("corresp", "").split())
            missing = corresps - span_corresps
            if missing:
                error (elem, "corresps %s on <ab> not found on spans" % ", ".join(missing))
            surplus = span_corresps - corresps
            if surplus:
                error (elem, "corresps %s on spans not found on <ab>" % ", ".join(surplus))
            if elem.get("prev"):
                error (elem, "<ab> with spans and @prev")
            if elem.get("next"):
                error (elem, "<ab> with spans and @next")
        else:
            # the <ab> does not contain spans, check the <ab> itself
            if corresps:
                span (elem, corresps)

        ab_spans.clear()
        continue

    if elem.tag == "{%s}anchor" % TEI:
        if xml_id == in_capitulatio:
            in_capitulatio = None
        if xml_id in unresolved_span_tos:
            del unresolved_span_tos[xml_id]

for xml_id, elem in unresolved_span_tos.items():
    error (elem, "@spanTo=%s without anchor" % xml_id)
