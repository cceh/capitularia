#!/bin/bash

ROOT_PATH=/afs/rrz.uni-koeln.de/vol/www/projekt/capitularia

PROCESSOR_PATH=$ROOT_PATH/http/docs/wp-content/plugins/cap-xsl-processor

XSLTPROC=$ROOT_PATH/local/bin/xsltproc

PROCESSOR=footnotes-post-processor.php

$XSLTPROC "$@" | php $PROCESSOR_PATH/$PROCESSOR
