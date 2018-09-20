.PHONY: lint phplint jslint csslint docs

clean:
	find . -name '*~' -delete
	-rm src/css/*.css
	-rm src/css/*.map

doc: phpdoc phpmd phpmetrics sami

# sass --embed-source-map crashes with NullError: method not found: 'length' on null
# so we cannot pipe things
$(CSS_DEST)/%.css : $(CSS_SRC)/%.scss
	$(SASS) $(SASSFLAGS) $< $@.tmp.css
	$(POSTCSS) $(POSTCSSFLAGS) -u autoprefixer -o $@ $@.tmp.css
	-rm $@.tmp.css

# node-sass doe not work !!!! it royally botches @include media-breakpoint-up(md) {...}
#$(CSS_DEST)/%.css : $(CSS_SRC)/%.scss
#	$(POSTCSS) $(POSTCSSFLAGS) -o $@ $<

$(CSSIMG_DEST)/%.png : $(CSSIMG_SRC)/%.png
	cp $< $@

$(JS_DEST)/%.js : $(JS_SRC)/%.js
	$(BABEL) $(BABELFLAGS) --out-file $@ $<

css: $(CSS_DEST_FILES)

js: $(JS_DEST_FILES)

csslint:
	$(STYLELINT) $(CSS_SRC_FILES)

jslint:
	$(ESLINT) $(ESLINTFLAGS) $(JS_SRC_FILES)
	$(JSHINT) $(JSHINTFLAGS) $(JSON_FILES)

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
LANG_DEST := languages

define LOCALE_TEMPLATE

mo: $(LANG_DEST)/$(1).mo

$(LANG_DEST)/$(1).mo: $(LANG_SRC)/$(1).po
	-mkdir -p $$(dir $$@)
	msgfmt -o $$@ $$?

.PRECIOUS: $(LANG_SRC)/$(1).po

po: $(LANG_SRC)/$(1).po

$(LANG_SRC)/$(1).po: $(LANG_SRC)/capitularia.pot
	if test -e $$@; \
	then msgmerge -U --backup=numbered $$@ $$?; \
	else msginit --locale=$(1) -i $$? -o $$@; \
	fi

endef

$(foreach lang,$(TRANSLATIONS),$(eval $(call LOCALE_TEMPLATE,$(lang))))

pot: $(LANG_SRC)/capitularia.pot

$(LANG_SRC)/capitularia.pot: $(PHP_FILES)
	xgettext --default-domain=capitularia --from-code=utf-8 \
	--copyright-holder="CCeH Cologne" --package-name=Capitularia --package-version=2.0 \
	--msgid-bugs-address=marcello@perathoner.de \
	-k'__' -k'_e' -k'_n:1,2' -k'_x:1,2c' -o $@ $^
