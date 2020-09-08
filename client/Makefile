include ../Variables.mak

.PHONY: build build-production

AUX := build/index.html build/api.conf.js

build: $(AUX)
	$(WEBPACK) --config webpack.dev.js

build-production: clean $(AUX)
	$(WEBPACK) --config webpack.prod.js

dev-server: $(AUX)
	$(WEBPACK_DEV_SERVER) --config webpack.dev.js

dev-server-debug: $(AUX)
	env DEBUG="express:*" $(WEBPACK_DEV_SERVER) --config webpack.dev.js

dev-server-production: clean $(AUX)
	$(WEBPACK_DEV_SERVER) --config webpack.prod.js

upload: build
	$(RSYNC) --exclude "api.conf.js" build/* $(HOST_CLIENT)

lint: eslint csslint

eslint:
	$(ESLINT) src/components/*.vue src/js/*.js src/*.js *.js *.json

csslint:
	$(STYLELINT) src/components/*.vue src/less/*.less

clean:
	rm -rf build/*
	find . -name "*~" -delete

build/index.html: src/index.html
	-mkdir -p build
	cp $< $@

build/api.conf.js: src/api.conf.js
	-mkdir -p build
	cp $< $@
