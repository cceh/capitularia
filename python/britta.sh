#!/bin/bash
#

XML="$1"
OUT="$2"

MSS="
st-gallen-sb-733
st-paul-abs-4-1
ivrea-bc-xxxiv
ivrea-bc-xxxiii
vatikan-bav-vat-lat-5359
vercelli-bce-clxxiv
vercelli-bce-clxxv
wolfenbuettel-hab-blankenb-130
muenchen-bsb-lat-19416
muenchen-bsb-lat-29555-1
paris-bn-lat-4613
vatikan-bav-reg-lat-263
modena-bc-o-i-2
gotha-flb-memb-i-84
vatikan-bav-chigi-f-iv-75
cava-dei-tirreni-bdb-4
"

L2="20a 22 23 89 94 97 39 40 95 98"
L3="$L2 41 43 44 112 129"

L5="40 44 139 201-203 208-219"
L8="39 40 41 43 44 112 129"


# sequence-date
# sequence-group-2-20a_22_23_89_94_97_39_40_95_98-date
# sequence-group-3-20a_22_23_89_94_97_39_40_95_98_41_43_44_112_129-date
# sequence-group-8-39-41_43_44_112_129-date
# sequence-group-5-40_44_139_201-203_208-219-date (und in dieser, wenn möglich, nur die Hss. sichtbar machen,
#     in denen BK 201 vorkommt und die anderen komplett ausgrauen; s. meine Mail von gestern)

# SEQUENCES

./sequential.py --include-mss="$MSS" \
                --title="Capitulars in Manuscripts" \
                -o $OUT/sequence-date.png  "$XML" &

# collections by Britta
for i in 2 3 5 8
do
    eval BKS=\"\$L$i\"
    ./sequential.py --include-mss="$MSS" --include-bks="$BKS" \
                    --title="Capitulars {include-bks} in Manuscripts" \
                    -o $OUT/sequence-group-$i-{include-bks}-date.png "$XML" &
done

for i in 5
do
    eval BKS=\"\$L$i\"
    ./sequential.py -d --include-mss="$MSS" --include-bks="$BKS" --mss-must-contain="201" \
                    --title="Capitulars {include-bks} in Manuscripts Containing 201" \
                    -o $OUT/sequence-group-$i-{include-bks}-with-201-date.png "$XML" &
done
# CLUSTERS

#./italic_cluster.py --idf -o $OUT/idf-date.png     "$XML" &
#./italic_cluster.py --mss -o $OUT/ms-sim-date.png  "$XML" &

# for n in 3
# do
#     ./italic_cluster.py --idf --min-ngrams=$n --max-ngrams=$n \
#                         --title="Manuscripts × Capitulars using $n-grams" \
#                         -o $OUT/idf-date-${n}grams.png     "$XML" &

#     ./italic_cluster.py --mss --min-ngrams=$n --max-ngrams=$n \
#                         --title="Similarity of Manuscripts using $n-grams" \
#                         -o $OUT/ms-sim-date-${n}grams.png  "$XML" &
# done

# for i in 1 2 3 4 5
# do
#     eval BKS=\"\$L$i\"
#     ./italic_cluster.py --bks --include-bks="$BKS" \
#                         --title="Similarity of Capitulars with {include-bks}" \
#                         -o $OUT/bk-sim-group-$i-{include-bks}.png "$XML" &
# done

# ./italic_cluster.py --idf --include-bks="$L5" \
#                     --title="Manuscripts × Capitulars {include-bks}" \
#                     -o $OUT/idf-date-5-{include-bks}.png    "$XML" &

# ./italic_cluster.py --mss --include-bks="$L5" \
#                     --title="Similarity of Manuscripts using {include-bks}" \
#                     -o $OUT/ms-sim-date-5-{include-bks}.png "$XML" &
