include Variables.mak

THEMES  = themes/Capitularia
PLUGINS = $(wildcard plugins/cap-*)

lint: phplint csslint jslint

deploy: css js_prod lint mo deploy_xslt deploy_scripts

deploy_xslt: make_dependencies
	$(RSYNC) xslt/*.xsl $(TRANSFORM)/
	$(RSYNC) xslt/*.xsl xslt/*.inc xslt/Makefile $(HOST_SERVER)/../xslt/

deploy_xml:
	$(RSYNC) mss/*.xml $(PUBL)/mss/

deploy_scripts:
	$(RSYNC) --exclude='env' scripts $(PUBL)

upload_client: client
	cd $(CLIENT) && $(MAKE) upload

upload_server:
	cd $(SERVER) && $(MAKE) upload

import_xml:
	$(RSYNC) --del $(PUBL)/mss/*    mss/
	$(RSYNC) --del $(PUBL)/capit/*  capit/

import_backups:
	$(RSYNC) $(AFS)/backups/* ../backups/

import_backup_mysql: import_backups
	bzcat $(AFS)/backups/mysql/capitularia-mysql-$(shell date +%F).sql.bz2 | $(MYSQL_LOCAL)

.PHONY: docs mysql-remote mysql-local

doc_src/phpdoc/structure.xml: $(wildcard plugins/*/*.php $(THEMES)/*.php $(THEMES)/widgets/*.php)
	mkdir -p doc_src/phpdoc
	$(PHPDOC) -d "plugins,themes" -t ./doc_src/phpdoc --ignore="*/node_modules/*" --template="xml" --template="clean"

doc_src/jsdoc/structure.json: $(shell find . -not -path "*node_modules*" -a -path "*/src/js/*.js")
	mkdir -p doc_src/jsdoc/
	$(JSDOC) -X $^ > $@

doc_src/xslt_dep/structure.ttl: xslt/*.xsl python/xslt_dep.py
	cd xslt && ../python/xslt_dep.py -e "r *.xsl; save ../$@"

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

mysql-remote:
	$(MYSQL_REMOTE)

mysql-local:
	$(MYSQL_LOCAL)

.PHONY: server
server: geodata-server
	export PYTHONPATH=$(ROOT)/server; \
	python3 -m server.server -vvv

.PHONY: client
client: geodata-client
	cd $(CLIENT) && $(MAKE) build

.PHONY: dev-server
dev-server: geodata-client
	cd $(CLIENT) && $(MAKE) dev-server

.PHONY: geodata-server geodata-client
geodata-server:
	cd $(GIS) && $(MAKE) geodata-server

geodata-client:
	cd $(GIS) && $(MAKE) geodata-client

upload_db:
	$(PGDUMP) --clean --if-exists $(PGLOCAL) | $(PSQL) -v ON_ERROR_STOP=1 $(PGREMOTESUPER)

rebuild_db: init_db scrape_corpus scrape_status scrape_fulltext

init_db:
	cd xslt && $(MAKE) init_db

corpus:
	cd xslt; XSL_DIR=. CACHE_DIR=../cache make -e corpus

fulltext:
	cd xslt; XSL_DIR=. CACHE_DIR=../cache make -e -j 7 fulltext

scrape_corpus:
	cd xslt && $(MAKE) scrape_corpus

scrape_fulltext:
	cd xslt && $(MAKE) scrape_fulltext

scrape_status:
	cd xslt && $(MAKE) scrape_status

scrape_geodata:
	cd $(SERVER) && $(MAKE) scrape_geodata

copy-hunspell:
	sudo cp $(SERVER)/hunspell/latin.* /usr/share/postgresql/11/tsearch_data/
	sudo service postgresql restart

# PhpMetrics http://www.phpmetrics.org/
phpmetrics:
	vendor/bin/phpmetrics --config="tools/phpmetrics/config.yml" .
	$(BROWSER) tools/reports/phpmetrics/index.html

# PHP_CodeSniffer https://github.com/squizlabs/PHP_CodeSniffer
phpcs:
	-vendor/bin/phpcs --standard=tools/phpcs --report=emacs -s --extensions=php --ignore=node_modules themes plugins


TARGETS = css js js_prod csslint jslint phplint mo po pot deploy clean

define TARGETS_TEMPLATE

$(1):
	for f in $(THEMES) $(PLUGINS); do cd "$$$$f" && $(MAKE) $(1); cd ..; cd ..; done

endef

$(foreach target,$(TARGETS),$(eval $(call TARGETS_TEMPLATE,$(target))))
