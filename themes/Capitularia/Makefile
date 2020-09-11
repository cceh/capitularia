PHP_SRC     := .
JS_SRC      := src/js
CSS_SRC     := src/css

PHP_FILES   := $(wildcard $(PHP_SRC)/*.php) $(wildcard $(PHP_SRC)/widgets/*.php)

TEXT_DOMAIN := 'capitularia'

include ../../Variables.mak
include ../../Makefile.inc

deploy:
	$(RSYNC) * $(WPCONTENT)/themes/Capitularia/
