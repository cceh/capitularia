PHP_DIRS   := plugins themes
JS_DIRS	   := plugins themes/Capitularia/js
JSON_DIRS  := .
LESS_DIRS  := plugins themes/Capitularia/css

PHP_FILES  := $(shell find $(PHP_DIRS)	-name '*.php')
JS_FILES   := $(shell find $(JS_DIRS)	-name '*.js')
JSON_FILES := $(shell find $(JSON_DIRS) -maxdepth 1 -name '*.json')
LESS_FILES := $(shell find $(LESS_DIRS) -name '*.less')
CSS_FILES  := $(patsubst %.less,%.css,$(LESS_FILES))

AFS     := $(or $(CAPITULARIA_AFS),/afs/rrz/vol/www/projekt/capitularia)
LOCALFS := $(or $(CAPITULARIA_LOCALFS),/var/www/capitularia)
BROWSER := $(or $(BROWSER),firefox)
GITUSER := $(CAPITULARIA_GITUSER)

RSYNC := rsync -rlptz --exclude='*~' --exclude='.*' --exclude='*.less' --exclude='node_modules'

WPCONTENT := $(AFS)/http/docs/wp-content
PUBL	  := $(AFS)/http/docs/cap/publ
TRANSFORM := $(AFS)/http/docs/cap/publ/transform

WPCONTENTLOCAL := $(LOCALFS)/wp-content

.PHONY: lint phplint jslint csslint docs

%.css : %.less
	lessc --include-path=themes/Capitularia/css:themes/Capitularia/bower_components/bootstrap/less --autoprefix="last 2 versions" --source-map $? $@

all: lint

lint: phplint csslint jslint

doc: phpdoc phpmd phpmetrics sami

docs:
	-rm docs/_images/*
	cd doc_src; make html; cd ..

csslint: css

css: $(CSS_FILES)

phplint:
	for f in $(PHP_FILES); do php -l $$f || exit; done

jslint:
	eslint --format=unix $(JS_FILES)
	jshint --reporter=unix $(JSON_FILES)

# csslint --quiet --format=compact $(CSS_FILES) | sed -r -e 's/: line ([0-9]+), col ([0-9]+), /:\1:\2:/g'
csslint:
	csslint --quiet --format=compact $(CSS_FILES) | node unmap-reports

deploy: lint mo
	$(RSYNC) themes/Capitularia/* $(WPCONTENT)/themes/Capitularia/
	$(RSYNC) plugins/cap-* $(WPCONTENT)/plugins/
	$(RSYNC) xslt/*.xsl xslt/test/*xml $(TRANSFORM)/
	$(RSYNC) scripts $(PUBL)

testdeploy: lint mo
	$(RSYNC) themes/Capitularia/* $(WPCONTENTLOCAL)/themes/Capitularia/
	$(RSYNC) plugins/cap-* $(WPCONTENTLOCAL)/plugins/

deploy_xml:
	$(RSYNC) xml/*xml $(PUBL)/mss/

import_xml:
	$(RSYNC) $(PUBL)/mss/*xml xml/


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

git-fetch-collation:
	git clone https:$(GITUSER)@github.com/cceh/capitularia-collation.git $(AFS)/local/capitularia-collation


### Localization ###

TRANSLATIONS := de_DE  # space-separated list of translations we have eg. de_ED fr_FR

LANGDIR := themes/Capitularia/languages

define LOCALE_TEMPLATE

mo: $(LANGDIR)/$(1).mo

$(LANGDIR)/$(1).mo: $(LANGDIR)/$(1).po
	-mkdir -p $$(dir $$@)
	msgfmt -o $$@ $$?

.PRECIOUS: $(LANGDIR)/$(1).po

po: $(LANGDIR)/$(1).po

$(LANGDIR)/$(1).po: $(LANGDIR)/capitularia.pot
	if test -e $$@; \
	then msgmerge -U --backup=numbered $$@ $$?; \
	else msginit --locale=$(1) -i $$? -o $$@; \
	fi

endef

$(foreach lang,$(TRANSLATIONS),$(eval $(call LOCALE_TEMPLATE,$(lang))))

pot: $(LANGDIR)/capitularia.pot

$(LANGDIR)/capitularia.pot: $(PHP_FILES)
	xgettext --default-domain=capitularia --from-code=utf-8 \
	--copyright-holder="CCeH Cologne" --package-name=Capitularia --package-version=2.0 \
	--msgid-bugs-address=marcello@perathoner.de \
	-k'__' -k'_e' -k'_n:1,2' -k'_x:1,2c' -o $@ $^
