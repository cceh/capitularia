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

SASSFLAGS   = -I $(THEME)/src/css

deploy:
	$(RSYNC) * $(WPCONTENT)/plugins/$(notdir $(CURDIR))
