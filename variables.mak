ROOT      := $(CAPITULARIA_PRJ)
HOST_ROOT := $(CAPITULARIA_SSHUSER)@capitularia.uni-koeln.de

SERVERFS := $(HOST_ROOT):/var/www/capitularia.uni-koeln.de
LOCALFS  := $(or $(CAPITULARIA_LOCALFS),/var/www/capitularia)
BROWSER  := $(or $(BROWSER),firefox)
GITUSER  := $(CAPITULARIA_GITUSER)

WPCONTENT := $(SERVERFS)/wp-content
PUBL	  := $(SERVERFS)/cap/publ
TRANSFORM := $(SERVERFS)/cap/publ/transform

WPCONTENTLOCAL := $(LOCALFS)/wp-content

CLIENT       := $(ROOT)/client
SERVER       := $(ROOT)/server
XSLT         := $(ROOT)/xslt
GIS          := $(ROOT)/gis

HOST_CLIENT  := $(WPCONTENT)/dist
HOST_PRJ_DIR := $(HOST_ROOT):~/prj/capitularia/capitularia
HOST_SERVER  := $(HOST_PRJ_DIR)/server
HOST_XSLT    := $(HOST_PRJ_DIR)/xslt

NODEJS       := node
NODE_MODULES := $(ROOT)/node_modules
NODE_BIN_DIR := $(NODE_MODULES)/.bin
PYTHON       := $(ROOT)/.venv/bin/python3

SOLR_INST    := $(HOME)/solr/solr
SOLR         := $(SOLR_INST)/bin/solr

NAT_EARTH    := https://naciscdn.org/naturalearth

WEBPACK             = $(NODE_BIN_DIR)/webpack --no-color
WEBPACK_DEV_SERVER  = $(NODE_BIN_DIR)/webpack serve --no-color
WEBPACK_DEV_CONFIG  = webpack.dev.js
WEBPACK_PROD_CONFIG = webpack.prod.js

BABEL           = $(NODE_BIN_DIR)/babel
BABELFLAGS      = --source-maps true
SASS            = $(NODE_BIN_DIR)/sass
SASSFLAGS       = -I $(CSS_SRC)
POSTCSS         = $(NODE_BIN_DIR)/postcss
POSTCSSFLAGS    =
ESLINT         := $(NODE_BIN_DIR)/eslint
ESLINTFLAGS     = -f unix
JSHINT         := $(NODE_BIN_DIR)/jshint
JSHINTFLAGS     = --reporter=unix
STYLELINT       = $(NODE_BIN_DIR)/stylelint $(STYLELINTFLAGS)
STYLELINTFLAGS  = -f unix
RSYNC          := rsync -v -crlptz --exclude='*~' --exclude='.*'
RSYNCPY        := $(RSYNC) --exclude "**/__pycache__"  --exclude "*.pyc" --exclude "*.log"
WP_CLI         := $(LOCALFS)/wp
PO2JSON        := $(ROOT)/python/po2json.py
EASYGETTEXT    := $(NODE_BIN_DIR)/gettext-extract --attribute v-translate
JSGETTEXT      := $(NODEJS) docs/cap-gettext-extractor.mjs
VUEGETTEXT     := $(JSGETTEXT)
XGETTEXT       := xgettext --default-domain=capitularia --from-code=utf-8 \
	--copyright-holder="CCeH Cologne" --package-name=Capitularia --package-version=2.0 \
	--msgid-bugs-address=marcello@perathoner.de \
	-k'__' -k'_e' -k'_n:1,2' -k'_x:1,2c' -k'_ex:1,2c'

PHPDOC         := vendor/phpdoc
JSDOC          := $(NODE_BIN_DIR)/jsdoc

MYSQL_REMOTE     := mysql --defaults-file=~/.my.cnf.capitularia
MYSQL_LOCAL      := mysql --defaults-file=~/.my.cnf.capitularia-local
MYSQLDUMP_REMOTE := mysqldump --defaults-file=~/.my.cnf.capitularia

PSQL           := /usr/bin/psql
PGDUMP         := /usr/bin/pg_dump
PGLOCAL        := $(CAPITULARIA_PGDATABASE)
PGREMOTE       := -h $(CAPITULARIA_PGHOST) -U $(CAPITULARIA_PGUSER) $(CAPITULARIA_PGDATABASE)
PGREMOTESUPER  := -h $(CAPITULARIA_PGHOST) -U $(CAPITULARIA_PGSUPERUSER) $(CAPITULARIA_PGDATABASE)

PHP_FILES         ?= $(wildcard $(PHP_SRC)/*.php)
JS_SRC_FILES      ?= $(wildcard $(JS_SRC)/*.js)
CSS_SRC_FILES     ?= $(CSS_SRC)/front.scss $(CSS_SRC)/admin.scss
CSSIMG_SRC_FILES  ?= $(CSSIMG_SRC)/*.png

JS_DEST_FILES     ?= $(patsubst $(JS_SRC)/%,$(JS_DEST)/%,$(JS_SRC_FILES))
CSS_DEST_FILES    ?= $(patsubst $(CSS_SRC)/%.scss,$(CSS_DEST)/%.css,$(CSS_SRC_FILES))
CSSIMG_DEST_FILES ?= $(patsubst $(CSSIMG_SRC)/%,$(CSSIMG_DEST)/%,$(CSSIMG_SRC_FILES))

JSON_FILES     = $(wildcard *.json)
