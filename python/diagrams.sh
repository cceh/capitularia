XML="$HOME/uni/prj/capitularia/Documents/Italische Sammlungen 3.xml"

rm /tmp/*.png

./sequential.py    -o /tmp/sequence-date.png  "$XML"
./sequential.py -s -o /tmp/sequence-alpha.png "$XML"

# ./sequential.py    -o /tmp/sequence-st-gallen-sb-733-date.png  --sample st-gallen-sb-733 "$XML"
# ./sequential.py -s -o /tmp/sequence-st-gallen-sb-733-alpha.png --sample st-gallen-sb-733 "$XML"

L1=BK.20a,BK.22,BK.23,BK.89,BK.94,BK.97
L2=$L1,BK.39,BK.40,BK.95,BK.98
L3=$L2,BK.41,BK.43,BK.44,BK.112,BK.129
L4=$L3,BK.139,BK.140,BK.141

for i in 1 2 3 4
do
    eval BKS=\"\$L$i\"
    echo "$BKS"
    ./sequential.py    -o /tmp/sequence-$i-date.png  --include="$BKS" "$XML"
    # ./sequential.py -s -o /tmp/sequence-$i-alpha.png --include="$BKS" "$XML"
done

./italic_cluster.py    -o /tmp/%s-date.png  "$XML"
./italic_cluster.py -s -o /tmp/%s-alpha.png "$XML"

rm /tmp/cap_sim-alpha.png
