include ../Makefile.inc

$(JS_DEST)/%.js : $(JS_SRC)/%.js
	@true

$(JS_DEST)/front.js : $(JS_SRC)/*.js
	$(WEBPACK) --config $(WEBPACK_CONFIG)
