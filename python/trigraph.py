import sys

LEN   = 3
SPACE = "⎵"
FONTSIZE = "ht 16*(scale/72)"

def tri (s):
    a = []
    s = '__' + s + '__'
    for i in range (0, len (s) - LEN + 1):
        a.append (s[i:i + LEN])
    return a

def spaces (s):
    return s.replace ('_', SPACE)

def print_nodes (a, prefix, cmp):
    print ("%s: [" % prefix)
    for t in a:
        style = "borderstyle shadedstyle" if t in cmp else ""
        print ('%s%s: box %s "%s"' % (prefix, t, style, spaces (t)))

a = tri (sys.argv[1])
b = tri (sys.argv[2])

sa = set (a)
sb = set (b)
sab = sa & sb

similarity = 2.0 * len (sab) / (len (sa) + len (sb))

print ('.PS')
print ('copy "config.pic";')
print ('boxwid = 0.6;')

print_nodes (a, 'A', sb)
print ("]")

print_nodes (b, 'B', sa)
print ('] with .c at A.c - (0, 1)')

print ('"%s" %s at A.c + (0, 0.6)' % (sys.argv[1], FONTSIZE))
print ('"%s" %s at B.c - (0, 0.6)' % (sys.argv[2], FONTSIZE))
print ('"Similarity: 2 * %d / (%d + %d) = %f" %s at B.c - (0, 1.2)' % (
    len (sab), len (sa), len (sb), similarity, FONTSIZE))

for t in a:
    if t in sb:
        print ('line borderstyle from A.A%s.s to B.B%s.n' % (t, t))

print ('.PE')
