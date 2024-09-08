PHP_SRC     := .
JS_SRC      := src/js
CSS_SRC     := src/css

TEXT_DOMAIN := $(notdir $(CURDIR))

include ../../variables.mak
include ../../include.mak

deploy:
	$(RSYNC) * $(WPCONTENT)/plugins/$(notdir $(CURDIR))
