WEBPACK := node_modules/.bin/webpack --no-color
WEBPACK_DEV_SERVER := node_modules/.bin/webpack-dev-server --no-color
ESLINT := node_modules/.bin/eslint -f unix
STYLELINT := node_modules/.bin/stylelint --custom-formatter ./stylelint-unix-formatter.js

.PHONY: build build-production

GEODATA_SRC_DIR    = src/geodata
GEODATA_DEST_DIR   = build/geodata
GEODATA_JSON_FILES = $(GEODATA_DEST_DIR)/10m_cultural/ne_10m_admin_0_boundary_lines_land.json

AUX := build/index.html build/api.conf.js $(GEODATA_JSON_FILES)

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

geodata: $(GEODATA_JSON_FILES)

$(GEODATA_DEST_DIR)/%.json : $(GEODATA_SRC_DIR)/%.shp
	-mkdir -p $(GEODATA_DEST_DIR)/10m_cultural
	ogr2ogr -f GeoJSON -spat -30 30 60 90 -t_srs epsg:4326 $@ $<


NEDATA = http://naciscdn.org/naturalearth

install_prereq:
	sudo apt-get install gdal-bin

download_geodata:
	mkdir -p src/geodata
	cd src/geodata ;						\
	for zip in 10m/raster/NE2_HR_LC_SR 10m/cultural/10m_cultural 10m/physical/10m_physical ; do \
		wget "$(NEDATA)/$$zip.zip" ; 		\
	done									\
	unzip NE2_HR_LC_SR.zip					\
	unzip 10m_cultural.zip					\
	unzip -d 10m_physical 10m_physical.zip
