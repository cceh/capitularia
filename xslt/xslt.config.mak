# Configures the XSLT process on the server and on the development machines
# DO NOT UPLOAD this to the server, but edit the copy on the server instead

# remote fs
ROOT_DIR   := $(CAPITULARIA_REMOTE_FS)/cap

# local cache
CACHE_DIR  := $(CAPITULARIA_PRJ)/cache

# the Python executable
PYTHON     := $(CAPITULARIA_PRJ)/.venv/bin/python

# the SOLR executable
SOLR       := $(HOME)/solr/solr/bin/solr

# the mysql conf of the wordpress database
MYSQL_CONF := $(HOME)/.my.cnf.capitularia-local
