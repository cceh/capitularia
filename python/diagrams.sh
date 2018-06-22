XML="$HOME/uni/prj/capitularia/Documents/Italische Sammlungen 6.xml"

rm /tmp/*.png

./sequential.py    -o /tmp/sequence-date.png  "$XML" &
#./sequential.py -s -o /tmp/sequence-alpha.png "$XML" &

L1=BK.20a,BK.22,BK.23,BK.89,BK.94,BK.97
L2=$L1,BK.39,BK.40,BK.95,BK.98
L3=$L2,BK.41,BK.43,BK.44,BK.112,BK.129
L4=$L3,BK.139,BK.140,BK.141

for i in 1 2 3 4
do
    eval BKS=\"\$L$i\"
    ./sequential.py    -o /tmp/sequence-group$i-date.png  --include-bks="$BKS" "$XML" &
done

for n in 1 3
do
    ./italic_cluster.py --idf --min-ngrams=$n --max-ngrams=$n -o /tmp/idf-date-${n}grams.png     "$XML" &
    ./italic_cluster.py --mss --min-ngrams=$n --max-ngrams=$n -o /tmp/ms-sim-date-${n}grams.png  "$XML" &
   #./italic_cluster.py --idf --ngrams $n -s -o /tmp/idf-alpha-${n}grams.png    "$XML" &
   #./italic_cluster.py --mss --ngrams $n -s -o /tmp/ms-sim-alpha-${n}grams.png "$XML" &
done

for i in 1 2 3 4
do
    eval BKS=\"\$L$i\"
    ./italic_cluster.py --bks -o /tmp/bk-sim-group$i.png  --include-bks="$BKS" "$XML" &
done
