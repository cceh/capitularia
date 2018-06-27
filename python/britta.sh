#!/bin/bash
#

XML="$1"
OUT="$2"

L1="20a 22 23 89 94 97"
L2="$L1 39 40 95 98"
L3="$L2 41 43 44 112 129"
L4="$L3 139 140 141"

L5="40 44 139 201-203 208-219"
L6="39 40"
L7="41 43 44 112 129"
L8="$L6 $L7"

# SEQUENCES

./sequential.py -o $OUT/sequence-date.png  "$XML" &

# collections by Britta
for i in 1 2 3 4 5 6 7 8
do
    eval BKS=\"\$L$i\"
    ./sequential.py --include-bks="$BKS" \
                    --title="Capitulars {include-bks} in Manuscripts" \
                    -o $OUT/sequence-group-$i-{include-bks}-date.png "$XML" &
done

# CLUSTERS

./italic_cluster.py --idf -o $OUT/idf-date.png     "$XML" &
./italic_cluster.py --mss -o $OUT/ms-sim-date.png  "$XML" &

# for n in 3
# do
#     ./italic_cluster.py --idf --min-ngrams=$n --max-ngrams=$n \
#                         --title="Manuscripts × Capitulars using $n-grams" \
#                         -o $OUT/idf-date-${n}grams.png     "$XML" &

#     ./italic_cluster.py --mss --min-ngrams=$n --max-ngrams=$n \
#                         --title="Similarity of Manuscripts using $n-grams" \
#                         -o $OUT/ms-sim-date-${n}grams.png  "$XML" &
# done

for i in 1 2 3 4 5
do
    eval BKS=\"\$L$i\"
    ./italic_cluster.py --bks --include-bks="$BKS" \
                        --title="Similarity of Capitulars with {include-bks}" \
                        -o $OUT/bk-sim-group-$i-{include-bks}.png "$XML" &
done

./italic_cluster.py --idf --include-bks="$L5" \
                    --title="Manuscripts × Capitulars {include-bks}" \
                    -o $OUT/idf-date-5-{include-bks}.png    "$XML" &

./italic_cluster.py --mss --include-bks="$L5" \
                    --title="Similarity of Manuscripts using {include-bks}" \
                    -o $OUT/ms-sim-date-5-{include-bks}.png "$XML" &
