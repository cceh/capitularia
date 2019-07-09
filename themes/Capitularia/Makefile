PHP_SRC     := .
JS_SRC      := src/js
CSS_SRC     := src/css
CSSIMG_SRC  := src/css/images

JS_DEST     := js
CSS_DEST    := css
CSSIMG_DEST := css/images

FONTS_PATH  := src/webfonts:node_modules/@fortawesome/fontawesome-free/webfonts
FONTS_DEST  := webfonts

OPENSANS    := src/webfonts
FONTAWESOME := node_modules/@fortawesome/fontawesome-free

OPENSANS_FILES    := $(patsubst $(OPENSANS)/%,$(FONT_DEST)/%,$(wildcard $(OPENSANS)/*))
FONTAWESOME_FILES := $(patsubst $(FONTAWESOME)/%,$(FONT_DEST)/%,$(wildcard $(FONTAWESOME)/*))

CSS_SRC_FILES := $(CSS_SRC)/front.scss $(CSS_SRC)/admin.scss $(CSS_SRC)/jquery-ui.scss

include ../../Variables.mak
include ../../Makefile.inc

fonts: $(CSS_DEST)/opensans.css $(CSS_DEST)/fontawesome.css
	cp $(OPENSANS)/*             $(FONTS_DEST)/
	cp $(FONTAWESOME)/webfonts/* $(FONTS_DEST)/

SASSFLAGS += -I node_modules/bootstrap/scss -I node_modules/jquery-ui/themes/base

$(CSS_DEST)/jquery-ui.css: $(CSSIMG_DEST_FILES)

$(CSS_DEST)/front.css: \
	$(CSS_SRC)/bootstrap-custom.scss \
	$(CSS_SRC)/opensans.scss \
	$(CSS_SRC)/fontawesome.scss \
	$(CSS_SRC)/fonts.scss \
	$(CSS_SRC)/qtranslate-x.scss \
	$(CSS_SRC)/general.scss \
	$(CSS_SRC)/content-col.scss \
	$(CSS_SRC)/navigation.scss \
	$(CSS_SRC)/front-page.scss \
	$(CSS_SRC)/slideout.scss \

deploy:
	$(RSYNC) * $(WPCONTENT)/themes/Capitularia/


define LOCALE_TEMPLATE

mo: $(LANG_DEST)/$(1).mo

$(LANG_DEST)/$(1).mo: $(LANG_SRC)/$(1).po
	-mkdir -p $$(dir $$@)
	msgfmt -o $$@ $$?

endef

$(foreach lang,$(TRANSLATIONS),$(eval $(call LOCALE_TEMPLATE,$(lang))))
