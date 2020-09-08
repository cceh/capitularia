PHP_SRC     := .
JS_SRC      := src/js
CSS_SRC     := src/css

PHP_FILES   := $(wildcard $(PHP_SRC)/*.php) $(wildcard $(PHP_SRC)/widgets/*.php)

JS_DEST     := js
CSS_DEST    := css

CSS_SRC_FILES :=

# webpack-ed JS files
JS_DEST_FILES = $(JS_DEST)/front.js $(JS_DEST)/admin.js

include ../../Variables.mak
include ../../Makefile.inc

deploy:
	$(RSYNC) * $(WPCONTENT)/themes/Capitularia/


define LOCALE_TEMPLATE

mo: $(LANG_DEST)/$(1).mo

$(LANG_DEST)/$(1).mo: $(LANG_SRC)/$(1).po
	-mkdir -p $$(dir $$@)
	msgfmt -o $$@ $$?

endef

$(foreach lang,$(TRANSLATIONS),$(eval $(call LOCALE_TEMPLATE,$(lang))))
