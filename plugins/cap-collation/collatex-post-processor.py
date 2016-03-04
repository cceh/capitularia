#! python3
#

import collections
import json
import re
import sys

import collatex
import collatex.core_functions

from networkx.algorithms.dag import topological_sort
import networkx as nx

def segment (graph):
    """
    Joins vertices to form segments

    Joins a string of vertices with no ramifications into one vertex.
    """

    def join_tokens (graph, vertex1, vertex2):
        """ Join vertex2 to vertex1 """

        node1 = graph.node[vertex1]
        node2 = graph.node[vertex2]
        if 'tokens' in node1 and 'tokens' in node2:
            node1['tokens'] += node2['tokens']

    sorted_vertices = topological_sort (graph)[1:-1] # remove start, end

    for vertex in sorted_vertices:
        if graph.in_degree (vertex) == 1:
            prev_vertex = graph.predecessors (vertex)[0]
            if prev_vertex != 0 and graph.out_degree (prev_vertex) == 1:
                join_tokens (graph, prev_vertex, vertex)

                for (_, neighbor, data) in graph.out_edges (vertex, data=True):
                    graph.remove_edge (vertex, neighbor)
                    # must be a new edge because out_degree of prev_vertex was 1
                    graph.add_edge (prev_vertex, neighbor, label=data['witnesses'])

                graph.remove_edge (prev_vertex, vertex)
                graph.remove_node (vertex)


def graph_to_json (graph, empty_cell_content = []):
    """
    Converts the graph into JSON representation.
    """

    witnesses = set ()

    # Sort vertices into ranks.  (More than one vertex can have the same rank.)
    sorted_vertices = topological_sort (graph)[1:-1] # remove start, end

    vertex_to_rank = collections.defaultdict (lambda: 0)
    for vertex in sorted_vertices:
        my_rank = vertex_to_rank[vertex]
        for successor in graph.successors (vertex):
            vertex_to_rank[successor] = max (vertex_to_rank[successor],
                                             my_rank + 1);

    # The nodes in each rank
    ranks = collections.defaultdict (list)
    for vertex in sorted_vertices:
        ranks[vertex_to_rank[vertex]].append (vertex)

    # Sort and group the vertices according to their rank.
    def keyfunc (vertex):
        return vertex_to_rank[vertex]

    # Construct table columns. Each rank becomes a table column.
    columns = []
    variant_columns = []
    for rank, vertices in ranks.items ():
        column = {}
        for vertex in vertices:
            # the incoming edges are the witnesses that contain this token
            edges = graph.in_edges (vertex, data=True)
            for edge in edges:
                if 'witnesses' in edge[2]:
                    sigli = edge[2]['witnesses'].split(', ')
                    witnesses.update (sigli)
                    for sigil in sigli:
                        column[sigil] = vertex

        columns.append (column)
        variant_columns.append (len (vertices) > 1)

    # Build JSON
    witnesses = sorted (witnesses)
    json_output = {}
    json_output['witnesses'] = witnesses

    # Write the columns to JSON
    table = []
    for column in columns:
        json_column = []
        for witness in witnesses:
            if witness in column:
                vertex = column[witness]
                node = graph.node[vertex]
                if 'tokens' in node:
                    json_column.append (node['tokens'])
                    continue
            json_column.append (empty_cell_content)
        table.append (json_column)
    json_output['table'] = table
    json_output['status'] = variant_columns

    # Most of the time it is more practical to have rows. Each witness becomes a row.
    # So let's write rows to JSON too.
    table = []
    for witness in witnesses:
        json_row = []
        for column in columns:
            json_row.append (column.get (witness, empty_cell_content))
        table.append (json_row)
    json_output['inverted_table'] = table

    return json.dumps (json_output, sort_keys = True, indent = True)


if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(description='Post-Process CollateX output.')
    parser.add_argument('--inputformat', dest='inputformat', type=str, default='json',
                        help='the input format')
    args = parser.parse_args()

    if args.inputformat == 'graphml':
        graph = nx.read_graphml (sys.stdin)
    else:
        sys.exit ()

    # segment (graph)

    print (graph_to_json (graph))
