SRC="https://raw.githubusercontent.com/cceh/capitularia-tei-qm/master/schema"
DEST="~/capitularia/http/docs/cap/publ/schemata"

for i in capitularia-msDesc-Transcription.rnc capitularia.sch
do
    # -n : read ~/.netrc for credentials
    curl -n "$SRC/$i" > "$DEST/$i"
done
