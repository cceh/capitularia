include Variables.mak

THEMES  = themes/Capitularia
PLUGINS = $(wildcard plugins/cap-*)

lint: phpcs jslint csslint

clean:
	find . -name '*~' -type f -delete
	rm -rf dist/*

deploy: clean geodata-client deploy_php

deploy_php: lint mo js
	$(RSYNC) themes  $(WPCONTENT)
	$(RSYNC) plugins $(WPCONTENT)
	$(RSYNC) --delete --exclude "api.conf.js" dist $(WPCONTENT)

deploy_xslt: make_dependencies
	$(RSYNC) xslt/*.xsl xslt/*.inc xslt/Makefile $(HOST_XSLT)/
	$(RSYNC) xslt/*.xsl $(TRANSFORM)/
	$(RSYNC) server/scripts/import_data.py $(HOST_SERVER)/scripts/

deploy_xml: deploy_mss deploy_capits

deploy_mss:
	$(RSYNC) --exclude='bk-textzeuge.xml' mss/*.xml $(PUBL)/mss/

deploy_capits:
	$(RSYNC) capit/ $(PUBL)/capit/

deploy_scripts:
	$(RSYNC) --exclude='env' scripts $(HOST_PRJ_DIR)/

deploy_schemas:
	# $(RSYNC) schemas $(PUBL)/schemata
	$(RSYNC) bibl/*.rng bibl/*.sch $(PUBL)/bibl

deploy_server:
	cd $(SERVER) && $(MAKE) deploy
	$(RSYNC) Makefile* Variables.mak $(HOST_PRJ_DIR)/
	$(RSYNC) solr $(HOST_PRJ_DIR)/

import_xml: import_mss import_capits

import_mss:
	$(RSYNC) --del $(PUBL)/mss/*    mss/

import_capits:
	$(RSYNC) --del $(PUBL)/capit/*  capit/

import_backups:
	$(RSYNC) $(SERVERFS)/backups/* ../backups/

import_backup_mysql:
	bzcat $(SERVERFS)/backups/mysql/capitularia-mysql-$(shell date +%F).sql.bz2 | $(MYSQL_LOCAL)

.PHONY: docs psql-local psql-remote mysql-remote mysql-local

################ docs

.PHONY: docs clean_docs phpdoc jsdoc xsltdoc

DOCS_DIR = $(CAPITULARIA_PRJ)/docs
DOCS_SRC_DIR = $(DOCS_DIR)/src
DOCS_BUILD_DIR = $(DOCS_DIR)/build
DOCS_DIST_DIR = $(DOCS_DIR)/gh-pages
export SPHINXBUILD=$(PYTHON) -m sphinx -c $(DOCS_DIR)
export SRCDIR=$(DOCS_SRC_DIR)
export BUILDDIR=$(DOCS_BUILD_DIR)

phpdoc: $(DOCS_BUILD_DIR)/phpdoc/structure.xml

jsdoc: $(DOCS_BUILD_DIR)/jsdoc/structure.json

xsltdoc: $(DOCS_BUILD_DIR)/xsltdoc/structure.ttl

$(DOCS_BUILD_DIR)/phpdoc/structure.xml: $(wildcard plugins/*/*.php $(THEMES)/*.php $(THEMES)/widgets/*.php)
	mkdir -p $(DOCS_BUILD_DIR)/phpdoc
	$(PHPDOC) --template=xml -d "plugins,themes" -t $(DOCS_BUILD_DIR)/phpdoc --ignore="*/node_modules/*"

$(DOCS_BUILD_DIR)/jsdoc/structure.json: $(shell find . -not -path "*node_modules*" -a -path "*/src/js/*")
	mkdir -p $(DOCS_BUILD_DIR)/jsdoc/
	$(JSDOC) -c $(DOCS_DIR)/jsdoc.conf.js -X $^ > $@

$(DOCS_BUILD_DIR)/xsltdoc/structure.ttl: xslt/*.xsl python/xslt_dep.py
	mkdir -p $(DOCS_BUILD_DIR)/xsltdoc/
	cd $(XSLT) && PYTHONPATH=../python $(PYTHON) -m xslt_dep -e "r *.xsl; save $@"

make_dependencies: xsltdoc
	$(PYTHON) -m python.xslt_dep -e "l $<; make" > xslt/dependencies.inc

docs: phpdoc jsdoc xsltdoc
	cd $(DOCS_DIR) && $(MAKE) -e html
	-cp    $(DOCS_DIR)/_config.yml $(DOCS_BUILD_DIR)/
	-cp -r $(DOCS_SRC_DIR)/_images $(DOCS_BUILD_DIR)/

doccs: clean_docs docs

tar-docs:
	mkdir -p $(DOCS_DIST_DIR)
	tar -h --hard-dereference -cvf $(DOCS_DIST_DIR)/artifact.tar.gz $(DOCS_BUILD_DIR)

clean_docs:
	$(RM) -r $(DOCS_BUILD_DIR)/*

################ Solr

solr-init:
	-$(SOLR) delete -c capitularia
	$(SOLR) create -c capitularia -d $(ROOT)/solr/configsets/capitularia

solr-start:
	$(SOLR) start

solr-stop:
	$(SOLR) stop

solr-restart:
	$(SOLR) restart

solr-import:
	cd $(XSLT) && $(MAKE) solr-import

solr-logs:
	less $(SOLR_INST)/server/logs/solr.log

solr-prereq:
	cp $(SOLR_PRJ)/lib/build/libs/lib.jar $(SOLR_INST)/lib/capitularia.jar

# needs VPN
psql-remote:
	$(PSQL) $(PGREMOTE)

# needs VPN
mysql-remote:
	$(MYSQL_REMOTE)

psql-local:
	$(PSQL) $(PGLOCAL)

mysql-local:
	$(MYSQL_LOCAL)

.PHONY: server
server:
	export PYTHONPATH=$(ROOT)/server; \
	$(PYTHON) -OO -m server.server -vvv

dist/api.conf.js: client/src/api.conf.js
	mkdir -p dist
	cp $< $@

.PHONY: js dev-server
js: dist/api.conf.js
	$(WEBPACK) --config $(WEBPACK_PROD_CONFIG)

dev-server: dist/api.conf.js
	$(WEBPACK_DEV_SERVER) --config $(WEBPACK_DEV_CONFIG)

.PHONY: geodata-server geodata-client
geodata-server:
	cd $(GIS) && $(MAKE) geodata-server

geodata-client:
	cd $(GIS) && $(MAKE) geodata-client

upload_db:
	$(PGDUMP) --clean --if-exists $(PGLOCAL) | $(PSQL) -v ON_ERROR_STOP=1 $(PGREMOTESUPER)

rebuild_db: init_db scrape_corpus scrape_capits scrape_status scrape_fulltext scrape_geodata

init_db:
	cd $(XSLT) && $(MAKE) init_db

corpus:
	cd $(XSLT) && $(MAKE) corpus

fulltext:
	cd $(XSLT) && $(MAKE) -j 7 fulltext

scrape_corpus: corpus
	cd $(XSLT) && $(MAKE) scrape_corpus

scrape_capits:
	cd $(XSLT) && $(MAKE) scrape_capits

scrape_fulltext: fulltext
	cd $(XSLT) && $(MAKE) scrape_fulltext

scrape_status:
	cd $(XSLT) && $(MAKE) scrape_status

scrape_geodata:
	cd $(SERVER) && $(MAKE) scrape_geodata

# PhpMetrics http://www.phpmetrics.org/
phpmetrics:
	vendor/bin/phpmetrics --config="tools/phpmetrics/config.yml" .
	$(BROWSER) tools/reports/phpmetrics/index.html

# PHP_CodeSniffer https://github.com/squizlabs/PHP_CodeSniffer
phpcs:
	-vendor/bin/phpcs --standard=tools/phpcs --report=emacs -s --extensions=php --ignore=node_modules themes plugins

mypy:
	-mypy server/ python/

black:
	-black server/ python/


TARGETS = csslint jslint phplint mo po pot

define TARGETS_TEMPLATE

$(1):
	for f in $(THEMES) $(PLUGINS); do cd "$$$$f" && $(MAKE) $(1); cd ..; cd ..; done

endef

$(foreach target,$(TARGETS),$(eval $(call TARGETS_TEMPLATE,$(target))))
