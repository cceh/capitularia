PHP_SRC     := .
JS_SRC      := src/js
CSS_SRC     := src/css
CSSIMG_SRC  := src/css/images

JS_DEST     := js
CSS_DEST    := css
CSSIMG_DEST := css/images

include ../../Variables.mak
include ../../Makefile.inc

THEME  = ../../themes/Capitularia

PLUGIN = $(notdir $(CURDIR))
TEXT_DOMAIN = $(PLUGIN)

SASSFLAGS   = -I $(THEME)/src/css

deploy:
	$(RSYNC) * $(WPCONTENT)/plugins/$(notdir $(CURDIR))


define LOCALE_TEMPLATE

mo: $(LANG_DEST)/$(TEXT_DOMAIN)-$(1).mo

$(LANG_DEST)/$(TEXT_DOMAIN)-$(1).mo: $(LANG_SRC)/$(1).po
	-mkdir -p $$(dir $$@)
	msgfmt -o $$@ $$?

endef

$(foreach lang,$(TRANSLATIONS),$(eval $(call LOCALE_TEMPLATE,$(lang))))
