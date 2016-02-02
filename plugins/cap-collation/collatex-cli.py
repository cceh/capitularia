#! /afs/rrz.uni-koeln.de/vol/www/projekt/capitularia/local/bin/python3
#

import collections
import itertools
import json
import re
import sys

import collatex
import collatex.core_functions

from networkx.algorithms.dag import topological_sort


def segment (graph):
    """
    Joins vertices to form segments

    Joins a string of vertices with no ramifications into one vertex.
    """

    def join_tokens (graph, v1, v2):
        """ Join v2 to v1 """

        node1 = graph.node[v1]
        node2 = graph.node[v2]
        for sigil, tokens in node2['tokens'].items ():
            node1['tokens'].setdefault (sigil, []).extend (tokens)
        node1['label'] += node2['label']

    sorted_vertices = topological_sort (graph)[1:-1] # remove start, end

    for vertex in sorted_vertices:
        if graph.in_degree (vertex) == 1:
            prev_vertex = graph.predecessors (vertex)[0]
            if prev_vertex != 0 and graph.out_degree (prev_vertex) == 1:
                join_tokens (graph, prev_vertex, vertex)

                for (_, neighbor, data) in graph.out_edges (vertex, data=True):
                    graph.remove_edge (vertex, neighbor)
                    # must be a new edge because out_degree of prev_vertex was 1
                    graph.add_edge (prev_vertex, neighbor, label=data['label'])

                graph.remove_edge (prev_vertex, vertex)
                graph.remove_node (vertex)


def graph_to_json (graph, witnesses, empty_cell_content = []):
    """
    Converts the graph into JSON representation.
    """

    # Give every vertex a rank. (More than one vertex can have the same rank.)
    sorted_vertices = topological_sort (graph)[1:-1] # remove start, end

    vertex_to_rank = collections.defaultdict (lambda: 0)
    for vertex in sorted_vertices:
        for successor in graph.successors (vertex):
            vertex_to_rank[successor] = max (vertex_to_rank[successor],
                                             vertex_to_rank[vertex] + 1);

    # The nodes in each rank
    ranks = collections.defaultdict (list)
    for vertex in sorted_vertices:
        ranks[vertex_to_rank[vertex]].append (vertex)

    # Sort and group the vertices according to their rank.
    def keyfunc (vertex):
        return vertex_to_rank[vertex]

    # Construct table columns. Each rank becomes a table column.
    columns = []
    for rank, vertices in itertools.groupby (sorted_vertices, keyfunc):
        column = {}
        columns.append (column)

        for vertex in vertices:
            node = graph.node[vertex]

            # the incoming edges are the witnesses that contain this token
            edges = graph.in_edges (vertex, data=True)
            for edge in edges:
                sigli = edge[2]['label'].split(', ')
                for sigil in sigli:
                    column[sigil] = [token.token_data for token in node['tokens'][sigil]]

    # Build JSON
    json_output = {}
    json_output['witnesses'] = [witness.sigil for witness in witnesses]

    # Write the columns to JSON
    table = []
    variant_columns = []
    for column in columns:
        json_column = []
        variants = set ()
        for witness in witnesses:
            tokens = column.get (witness.sigil, empty_cell_content)
            json_column.append (tokens)
            variants.add (''.join ([token['t'] for token in tokens]))
        table.append (json_column)
        variant_columns.append (len (variants) > 1)
    json_output['table'] = table
    json_output['status'] = variant_columns

    # Most of the time it is more practical to have rows. Each witness becomes a row.
    # So let's write rows to JSON too.
    table = []
    for witness in witnesses:
        json_row = []
        for column in columns:
            json_row.append (column.get (witness.sigil, empty_cell_content))
        table.append (json_row)
    json_output['inverted_table'] = table

    return json.dumps (json_output, sort_keys = True, indent = True)


if __name__ == '__main__':

    data = json.load (sys.stdin)

    collation = collatex.core_functions.Collation ()
    for witness in data['witnesses']:
        collation.add_witness (witness)

    graph = collatex.core_functions.collate (
        collation, output = 'graph', segmentation = False)

    segment (graph.graph)

    print (graph_to_json (graph.graph, collation.witnesses))
