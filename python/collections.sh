XML="$HOME/uni/prj/capitularia/Documents/Italische Sammlungen 7.xml"

rm /tmp/sequence-collection-*.png
python3 -m compileall ./

# collections found by maximal repeats
while read line
do
    ./sequential.py    -o /tmp/sequence-collection-{include-bks}-date.png  \
                       --title="Capitulars {include-bks} in Manuscripts" \
                       --include-bks="$line" "$XML" &
done < <(cut -d ' ' -f 2- ../Documents/max.txt)
