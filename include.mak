.PHONY: lint phplint jslint eslint jsonlint csslint docs

doc: phpdoc phpmd phpmetrics sami

csslint:
	$(STYLELINT) --allow-empty-input $(CSS_SRC)/*.scss

jslint: eslint jsonlint

eslint: $(wildcard $(JS_SRC)/*.js $(JS_SRC)/*.vue *.js .*.js)
	$(ESLINT) $(ESLINTFLAGS) --no-ignore $?

jsonlint: $(wildcard .*.json)
	$(JSHINT) $(JSHINTFLAGS) $?

phplint:
	for f in $(PHP_FILES); do php -l $$f || exit; done

# PHP_CodeSniffer https://github.com/squizlabs/PHP_CodeSniffer
phpcs:
	-vendor/bin/phpcs --standard=tools/phpcs --report=emacs -s --extensions=php themes plugins

# PHP Mess Detector http://phpmd.org/
phpmd:
	-vendor/bin/phpmd "themes,plugins" html tools/phpmd/ruleset.xml --reportfile "tools/reports/phpmd/index.html"
	$(BROWSER) tools/reports/phpmd/index.html

# PhpMetrics http://www.phpmetrics.org/
phpmetrics:
	vendor/bin/phpmetrics --config="tools/phpmetrics/config.yml" .
	$(BROWSER) tools/reports/phpmetrics/index.html

# Sami Documentation Generator https://github.com/FriendsOfPHP/Sami
sami:
	vendor/bin/sami.php update tools/sami/config.php
	$(BROWSER) tools/reports/sami/build/index.html

### Localization ###

TRANSLATIONS := de_DE  # space-separated list of translations we have eg. de_ED fr_FR

LANG_SRC  := src/languages
LANG_DEST := $(ROOT)/dist/languages

define LOCALE_TEMPLATE

.PRECIOUS: $(LANG_SRC)/$(1).po

po: pot $(LANG_SRC)/$(1).po

$(LANG_SRC)/$(1).po: $(LANG_SRC)/capitularia.pot
	if test -e $$@; \
	then msgmerge -U --force-po --backup=numbered $$@ $$?; \
	else msginit --locale=$(1) -i $$? -o $$@; \
	fi

$(eval HANDLE := $(TEXT_DOMAIN)-front.js)

mo: $(LANG_DEST)/$(1).mo $(LANG_DEST)/$(TEXT_DOMAIN)-$(1).mo $(LANG_DEST)/$(TEXT_DOMAIN)-$(1)-$(HANDLE).json

$(LANG_DEST)/$(1).mo: $(LANG_SRC)/$(1).po
	mkdir -p $$(dir $$@)
	msgfmt -o $$@ $$?

$(LANG_DEST)/$(TEXT_DOMAIN)-$(1).mo: $(LANG_SRC)/$(1).po
	mkdir -p $$(dir $$@)
	msgfmt -o $$@ $$?

$(LANG_DEST)/$(TEXT_DOMAIN)-$(1)-$(HANDLE).json: $(LANG_SRC)/$(1).po $(PO2JSON)
	$$(PYTHON) $$(PO2JSON) --domain $$(TEXT_DOMAIN) --lang $(1) $$< $$@

endef

$(foreach lang,$(TRANSLATIONS),$(eval $(call LOCALE_TEMPLATE,$(lang))))


pot: $(LANG_SRC)/capitularia.pot

$(LANG_SRC)/capitularia.pot: $(LANG_SRC)/php.pot $(LANG_SRC)/js.pot $(LANG_SRC)/vue.pot
	msgcat -o $@ $^

$(LANG_SRC)/php.pot: $(PHP_FILES)
	touch $@
	$(XGETTEXT) -o $@ $^

$(LANG_SRC)/js.pot: $(wildcard $(JS_SRC)/*.js)
	touch $@
	-$(EASYGETTEXT) --output $@ $^

$(LANG_SRC)/vue.pot: $(wildcard $(JS_SRC)/*.vue)
	touch $@
	-$(EASYGETTEXT) --output $@ $^

poedit: po
	poedit $(LANG_SRC)/de_DE.po
	$(MAKE) mo
