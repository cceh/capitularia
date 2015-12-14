#!/bin/bash

/afs/rrz.uni-koeln.de/vol/www/projekt/capitularia/local/bin/xsltproc "$@" | php /afs/rrz.uni-koeln.de/vol/www/projekt/capitularia/http/docs/wp-content/plugins/cap-xsl-processor/footnotes-post-processor.php
