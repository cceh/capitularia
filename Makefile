include Variables.mak

THEMES  = themes/Capitularia
PLUGINS = $(wildcard plugins/cap-*)

lint: phplint csslint jslint

deploy: css js lint mo deploy_xslt deploy_scripts

deploy_xslt:
	$(RSYNC) xslt/*.xsl  $(TRANSFORM)/

deploy_xml:
	$(RSYNC) xml/*.xml $(PUBL)/mss/

deploy_scripts:
	$(RSYNC) scripts $(PUBL)

upload_client: client
	cd $(CLIENT); make upload; cd ..

upload_server:
	cd $(SERVER); make upload; cd ..

import_xml:
	$(RSYNC) $(PUBL)/mss/*xml   xml/
	$(RSYNC) $(PUBL)/capit/*    capit/

import_backups:
	$(RSYNC) $(AFS)/backups/* backups/

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


TARGETS = css js csslint jslint phplint mo po pot deploy clean

define TARGETS_TEMPLATE

$(1):
	for f in $(THEMES) $(PLUGINS); do cd "$$$$f"; make $(1); cd ..; cd ..; done

endef

$(foreach target,$(TARGETS),$(eval $(call TARGETS_TEMPLATE,$(target))))
