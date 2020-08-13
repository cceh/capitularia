include ../Makefile.inc

$(JS_DEST)/%.js : $(JS_SRC)/%.js webpack.*.js
	@true

$(JS_DEST)/front.js : $(JS_SRC)/*.js webpack.*.js
	$(WEBPACK) --config $(WEBPACK_CONFIG)
