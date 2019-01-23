include Variables.mak

THEMES  = themes/Capitularia
PLUGINS = $(wildcard plugins/cap-*)

lint: phplint csslint jslint

deploy: css js lint mo deploy_xslt deploy_scripts

deploy_xslt:
	$(RSYNC) xslt/*.xsl xslt/test/*xml $(TRANSFORM)/

deploy_scripts:
	$(RSYNC) scripts $(PUBL)

deploy_xml:
	$(RSYNC) xml/*xml $(PUBL)/mss/

upload_client:
	cd $(CLIENT); make upload; cd ..

upload_server:
	$(RSYNCPY) --exclude "server.conf" $(SERVER)/* $(HOST_SERVER)

import_xml:
	$(RSYNC) $(PUBL)/mss/*xml xml/

import_backups:
	$(RSYNC) $(AFS)/backups/* backups/

.PHONY:  server
server:
	python3 -m server.server -vvv

download_geodata:
	for zip in 10m/raster/NE2_HR_LC_SR 10m/cultural/10m_cultural 10m/physical/10m_physical ; do \
		wget -P /tmp "$(NAT_EARTH)/$$zip.zip" ;     \
	done
	mkdir -p server/geodata client/src/geodata
	unzip -d server/geodata              /tmp/NE2_HR_LC_SR.zip
	unzip -d server/geodata/10m_physical /tmp/10m_physical.zip
	unzip -d client/src/geodata          /tmp/10m_cultural.zip

TARGETS = css js csslint jslint phplint mo po pot deploy clean

define TARGETS_TEMPLATE

$(1):
	for f in $(THEMES) $(PLUGINS); do cd "$$$$f"; make $(1); cd ..; cd ..; done

endef

$(foreach target,$(TARGETS),$(eval $(call TARGETS_TEMPLATE,$(target))))
