#!/bin/bash

# -0777 == slurp files whole
# scripts/find-note-msDetail-53.sh | uniq | xargs perl -0777 -p -e 's!<note\s+type="msDetail"\s*/>!!sgu' '{}'
scripts/find-note-msDetail-53.sh | uniq | xargs perl -0777 -p -i.backup -e 's!<note\s+type="msDetail"\s*/>!!sgu' '{}'
