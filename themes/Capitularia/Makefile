PHP_SRC     := .
JS_SRC      := src/js
CSS_SRC     := src/css
CSSIMG_SRC  := src/css/images

JS_DEST     := js
CSS_DEST    := css
CSSIMG_DEST := css/images

CSS_SRC_FILES := $(CSS_SRC)/front.scss $(CSS_SRC)/admin.scss $(CSS_SRC)/jquery-ui.scss

include ../../Variables.mak
include ../../Makefile.inc

SASSFLAGS += -I node_modules/bootstrap/scss -I node_modules/jquery-ui/themes/base

$(CSS_DEST)/jquery-ui.css: $(CSSIMG_DEST_FILES)

$(CSS_DEST)/front.css: $(CSS_SRC)/content.scss $(CSS_SRC)/navigation.scss $(CSS_SRC)/qtranslate-x.scss

deploy:
	$(RSYNC) * $(WPCONTENT)/themes/Capitularia/
