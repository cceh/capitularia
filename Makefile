include Variables.mak

THEMES  = themes/Capitularia
PLUGINS = $(wildcard plugins/cap-*)

lint: phplint csslint jslint

deploy: lint mo deploy_xslt deploy_scripts

deploy_xslt:
	$(RSYNC) xslt/*.xsl xslt/test/*xml $(TRANSFORM)/

deploy_scripts:
	$(RSYNC) scripts $(PUBL)

deploy_xml:
	$(RSYNC) xml/*xml $(PUBL)/mss/

import_xml:
	$(RSYNC) $(PUBL)/mss/*xml xml/

import_backups:
	$(RSYNC) $(AFS)/backups/* backups/

TARGETS = css js csslint jslint phplint mo deploy clean

define TARGETS_TEMPLATE

$(1):
	for f in $(THEMES) $(PLUGINS); do cd "$$$$f"; make $(1); cd ..; cd ..; done

endef

$(foreach target,$(TARGETS),$(eval $(call TARGETS_TEMPLATE,$(target))))
