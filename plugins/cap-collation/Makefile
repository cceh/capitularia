# just this file. its webpack-ed!
JS_DEST_FILES = $(JS_DEST)/front.js

include ../Makefile.inc

$(JS_DEST)/front.js : $(JS_SRC)/*.js $(CSS_SRC)/*.scss webpack.*.js
	$(WEBPACK) --config $(WEBPACK_CONFIG)

dev-server: $(AUX)
	$(WEBPACK_DEV_SERVER) --config webpack.dev.js
