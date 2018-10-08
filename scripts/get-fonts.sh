#!/bin/bash

# Downloads the open-sans ttf bundle and generates the webfonts.
#
# prerequisites:
#   sudo apt-get install fontforge ttfautohint lcdf-typetools woff2
#

FONTDIR=../themes/Capitularia/webfonts
BASEURL=
DATE=`date`
ZIP=open-sans.zip
WOFF2_COMPRESS=woff2_compress

# download the ttf bundle

curl 'http://www.fontsquirrel.com/fonts/download/open-sans' > $ZIP

mkdir -p "$FONTDIR"
rm "$FONTDIR/"*

unzip $ZIP "*.ttf" -d $FONTDIR

for TTF in $FONTDIR/*.ttf
do
    ./convert.pe "$TTF"                  # fontforge shell file
    ttfautohint "$TTF" "$TTF.autohint"
    mv "$TTF.autohint" "$TTF"
    $WOFF2_COMPRESS "$TTF"
done
