PHP_SRC     := .
JS_SRC      := src/js
CSS_SRC     := src/css

TEXT_DOMAIN := $(notdir $(CURDIR))

include ../../Variables.mak
include ../../Makefile.inc

deploy:
	$(RSYNC) * $(WPCONTENT)/plugins/$(notdir $(CURDIR))
