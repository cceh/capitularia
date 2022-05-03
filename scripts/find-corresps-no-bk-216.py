#!/usr/bin/env python3

import collections
import fileinput
import re

def natural_sort (key):
    def f (mo):
        s = mo.group (0)
        return str (len (s)) + s
    return re.sub ('([0-9]+)', f, key)

d = collections.defaultdict(set)
indent = 0

for line in fileinput.input():
    id_, file_ = str.split(line)
    d[file_].add(id_)
    indent = max(len(file_), indent)

indent += 1
indent_str = "\n" + " " * indent

for file_ in sorted(d.keys(), key = natural_sort):
    print(file_ + " " * (indent - len(file_)), end="")
    print(indent_str.join(sorted(d[file_], key = natural_sort)))
