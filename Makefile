include Variables.mak

THEMES  = themes/Capitularia
PLUGINS = $(wildcard plugins/cap-*)

lint: phplint csslint jslint

deploy: css js_prod lint mo deploy_xslt deploy_scripts

deploy_xslt:
	$(RSYNC) xslt/*.xsl $(TRANSFORM)/
	$(RSYNC) xslt/*.xsl xslt/Makefile $(HOST_SERVER)/../xslt/

deploy_xml:
	$(RSYNC) xml/*.xml $(PUBL)/mss/

deploy_scripts:
	$(RSYNC) --exclude='env' scripts $(PUBL)

upload_client: client
	cd $(CLIENT) && $(MAKE) upload

upload_server:
	cd $(SERVER) && $(MAKE) upload

import_xml:
	$(RSYNC) --del $(PUBL)/mss/*xml   xml/
	$(RSYNC) --del $(PUBL)/capit/*    capit/

import_backups:
	$(RSYNC) $(AFS)/backups/* ../backups/

import_backup_mysql: import_backups
	bzcat $(AFS)/backups/mysql/capitularia-mysql-$(shell date +%F).sql.bz2 | $(MYSQL_LOCAL)

.PHONY: docs mysql-remote mysql-local

docs:
	cd doc_src && $(MAKE) html

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

corpus:
	cd xslt; XSL_DIR=. CACHE_DIR=../cache make -e corpus

collation:
	cd xslt; XSL_DIR=. CACHE_DIR=../cache make -e -j 7 collation

init_db:
	cd $(SERVER) && $(MAKE) init_db

upload_db:
	$(PGDUMP) --clean --if-exists $(PGLOCAL) | $(PSQL) -v ON_ERROR_STOP=1 $(PGREMOTESUPER)

scrape_corpus: import_xml
	cd $(SERVER) && $(MAKE) scrape_corpus

scrape_geodata: import_xml
	cd $(SERVER) && $(MAKE) scrape_geodata

# PhpMetrics http://www.phpmetrics.org/
phpmetrics:
	vendor/bin/phpmetrics --config="tools/phpmetrics/config.yml" .
	$(BROWSER) tools/reports/phpmetrics/index.html


TARGETS = css js js_prod csslint jslint phplint mo po pot deploy clean

define TARGETS_TEMPLATE

$(1):
	for f in $(THEMES) $(PLUGINS); do cd "$$$$f" && $(MAKE) $(1); cd ..; cd ..; done

endef

$(foreach target,$(TARGETS),$(eval $(call TARGETS_TEMPLATE,$(target))))
