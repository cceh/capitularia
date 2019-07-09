include Variables.mak

THEMES  = themes/Capitularia
PLUGINS = $(wildcard plugins/cap-*)

lint: phplint csslint jslint

deploy: css js_prod lint mo deploy_xslt deploy_scripts

deploy_xslt:
	$(RSYNC) xslt/*.xsl  $(TRANSFORM)/

deploy_xml:
	$(RSYNC) xml/*.xml $(PUBL)/mss/

deploy_scripts:
	$(RSYNC) --exclude='env' scripts $(PUBL)

upload_client: client
	cd $(CLIENT); make upload; cd ..

upload_server:
	cd $(SERVER); make upload; cd ..

import_xml:
	$(RSYNC) $(PUBL)/mss/*xml   xml/
	$(RSYNC) $(PUBL)/capit/*    capit/

import_backups:
	$(RSYNC) $(AFS)/backups/* ../backups/

import_backup_mysql: import_backups
	bzcat $(AFS)/backups/mysql/capitularia-mysql-$(shell date +%F).sql.bz2 | $(MYSQL_LOCAL)

.PHONY: docs mysql-remote mysql-local

docs:
	cd doc_src; make html; cd ..

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
	cd $(CLIENT); make build; cd ..

.PHONY: dev-server
dev-server: geodata-client
	cd $(CLIENT); make dev-server; cd ..

.PHONY: geodata-server geodata-client
geodata-server:
	cd $(GIS); make geodata-server; cd ..

geodata-client:
	cd $(GIS); make geodata-client; cd ..

init_geodata_db: import_xml
	cd $(SERVER); make init_geodata_db
	cd $(GIS); make import-geodata-to-postgres


TARGETS = css js js_prod csslint jslint phplint mo po pot deploy clean

define TARGETS_TEMPLATE

$(1):
	for f in $(THEMES) $(PLUGINS); do cd "$$$$f"; make $(1); cd ..; cd ..; done

endef

$(foreach target,$(TARGETS),$(eval $(call TARGETS_TEMPLATE,$(target))))
