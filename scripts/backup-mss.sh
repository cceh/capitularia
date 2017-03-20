#!/bin/bash

ROOT=~/capitularia
FILES=$ROOT/http/docs/cap
TARBALL=$ROOT/backups/files/mss-`date +"%Y-%m-%d-%H-%M-%S"`.tar.bz2
EXCLUDE="--exclude=$FILES/intern/InArbeit/Boretius --exclude=$FILES/intern/InArbeit/Mordek"

tar -c -f $TARBALL -vhj $EXCLUDE $FILES/publ/mss $FILES/intern/InArbeit
