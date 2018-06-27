import unittest

from suffix_tree import Tree

class TestLCA (unittest.TestCase):

    def test_lca (self):
        tree = Tree ({ 'A' : list ('xabxac'), 'B' : list ('awyawxawxz') })
        tree.prepare_lca ()
        self.assertEqual (tree.lca (tree.nodemap['A'][1], tree.nodemap['B'][3]).id,  8)
        self.assertEqual (tree.lca (tree.nodemap['A'][0], tree.nodemap['B'][8]).id,  2)
        self.assertEqual (tree.lca (tree.nodemap['B'][1], tree.nodemap['B'][7]).id, 19)
        self.assertEqual (tree.lca (tree.nodemap['A'][0], tree.nodemap['B'][7]).id,  1)


if __name__ == '__main__':
    unittest.main ()
