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
	$(RSYNC) Makefile* Variables.mak $(HOST_SERVER)/../

import_xml: import_mss import_capits

import_mss:
	$(RSYNC) --del $(PUBL)/mss/*    mss/

import_capits:
	$(RSYNC) --del $(PUBL)/capit/*  capit/

import_backups:
	$(RSYNC) $(SERVERFS)/backups/* ../backups/

import_backup_mysql:
	bzcat $(SERVERFS)/backups/mysql/capitularia-mysql-$(shell date +%F).sql.bz2 | $(MYSQL_LOCAL)

.PHONY: docs mysql-remote mysql-local

doc_src/phpdoc/structure.xml: $(wildcard plugins/*/*.php $(THEMES)/*.php $(THEMES)/widgets/*.php)
	mkdir -p doc_src/phpdoc
	$(PHPDOC) --template=xml -d "plugins,themes" -t ./doc_src/phpdoc --ignore="*/node_modules/*"

doc_src/jsdoc/structure.json: $(shell find . -not -path "*node_modules*" -a -path "*/src/js/*.js")
	mkdir -p doc_src/jsdoc/
	$(JSDOC) -X $^ > $@

doc_src/xslt_dep/structure.ttl: xslt/*.xsl python/xslt_dep.py
	cd $(XSLT) && ../python/xslt_dep.py -e "r *.xsl; save ../$@"

make_dependencies: doc_src/xslt_dep/structure.ttl
	python/xslt_dep.py -e "l $<; make" > xslt/dependencies.inc

docs: doc_src/phpdoc/structure.xml doc_src/jsdoc/structure.json doc_src/xslt_dep/structure.ttl
	cd doc_src && $(MAKE) -e html

doccs: doc_src/phpdoc/structure.xml doc_src/jsdoc/structure.json doc_src/xslt_dep/structure.ttl
	$(RM) -r docs/*
	cd doc_src && $(MAKE) -e html

jsdoc: doc_src/jsdoc/structure.json

doxygen:
	doxygen
	mkdir -p doc_src/webprojekt/doxygen/
	doxyphp2sphinx -v --xml-dir doxygen_build/xml/ --out-dir doc_src/webprojekt/doxygen/ cceh::capitularia

# needs VPN
mysql-remote:
	$(MYSQL_REMOTE)

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
	-mypy server/


TARGETS = csslint jslint phplint mo po pot

define TARGETS_TEMPLATE

$(1):
	for f in $(THEMES) $(PLUGINS); do cd "$$$$f" && $(MAKE) $(1); cd ..; cd ..; done

endef

$(foreach target,$(TARGETS),$(eval $(call TARGETS_TEMPLATE,$(target))))
