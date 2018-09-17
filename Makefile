THEME      := themes/Capitularia

PHP_DIRS   := plugins themes
JS_DIRS	   := plugins $(THEME)/js
JSON_DIRS  := .
SCSS_DIRS  := plugins $(THEME)/css

PHP_FILES   := $(shell find $(PHP_DIRS)	-name '*.php')
JS_FILES    := $(shell find $(JS_DIRS)	-name '*.js')
JSON_FILES  := $(shell find $(JSON_DIRS) -maxdepth 1 -name '*.json')
SCSS_FILES  := $(shell find . -name 'front.scss' -or -name 'admin.scss')
CSS_FILES   := $(patsubst %.scss,%.css,$(SCSS_FILES))

AFS     := $(or $(CAPITULARIA_AFS),/afs/rrz/vol/www/projekt/capitularia)
LOCALFS := $(or $(CAPITULARIA_LOCALFS),/var/www/capitularia)
BROWSER := $(or $(BROWSER),firefox)
GITUSER := $(CAPITULARIA_GITUSER)

SASS    := node_modules/.bin/sass -I $(THEME)/css/
POSTCSS := node_modules/.bin/postcss
RSYNC   := rsync -rlptz --exclude='*~' --exclude='.*'

WPCONTENT := $(AFS)/http/docs/wp-content
PUBL	  := $(AFS)/http/docs/cap/publ
TRANSFORM := $(AFS)/http/docs/cap/publ/transform

WPCONTENTLOCAL := $(LOCALFS)/wp-content

.PHONY: lint phplint jslint csslint docs

all: lint

lint: phplint csslint jslint

doc: phpdoc phpmd phpmetrics sami

docs:
	-rm docs/_images/*
	cp doc_src/_images/*svg docs/_images/
	cd doc_src; make html; cd ..

css: $(CSS_FILES) $(THEME)/css/jquery-ui.css
	mkdir -p $(THEME)/css/images/
	cp $(THEME)/node_modules/jquery-ui/themes/base/images/*.png $(THEME)/css/images/

%.css : %.scss
	$(SASS) $< | $(POSTCSS) --use autoprefixer -b 'last 2 versions' > $@

$(THEME)/css/front.css: $(THEME)/css/front.scss $(THEME)/css/colors.scss $(THEME)/css/fonts.scss \
						$(THEME)/css/content.scss $(THEME)/css/navigation.scss $(THEME)/css/qtranslate-x.scss

phplint:
	for f in $(PHP_FILES); do php -l $$f || exit; done

jslint:
	eslint --format=unix $(JS_FILES)
	jshint --reporter=unix $(JSON_FILES)

csslint: css
	csslint --quiet --format=compact $(CSS_FILES) | node unmap-reports

deploy: lint mo
	$(RSYNC) $(THEME)/* $(WPCONTENT)/themes/Capitularia/
	$(RSYNC) plugins/cap-* $(WPCONTENT)/plugins/
	$(RSYNC) xslt/*.xsl xslt/test/*xml $(TRANSFORM)/
	$(RSYNC) scripts $(PUBL)

deploy_xml:
	$(RSYNC) xml/*xml $(PUBL)/mss/

import_xml:
	$(RSYNC) $(PUBL)/mss/*xml xml/

import_backups:
	$(RSYNC) $(AFS)/backups/* backups/


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

LANGDIR := $(THEME)/languages

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
