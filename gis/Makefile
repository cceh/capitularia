include ../variables.mak

IMPORT := cd ../server; python3 -m scripts.import_data -vv -c ./server.conf

GEODATA_SRC_DIR    = ./geodata

GEODATA_CLIENT_DIR = ../dist/geodata
GEODATA_SERVER_DIR = ../server/geodata

GEODATA_LAYERS       = $(basename $(notdir $(wildcard $(GEODATA_SRC_DIR)/*.geojson)))

GEODATA_CLIENT_FILES = $(subst $(GEODATA_SRC_DIR),$(GEODATA_CLIENT_DIR),$(wildcard $(GEODATA_SRC_DIR)/*.geojson))

GEODATA_SERVER_FILES = $(GEODATA_SERVER_DIR)/NE2_HR_LC_SR/NE2_HR_LC_SR.tif \
				       $(GEODATA_SERVER_DIR)/Vidal-LaBlache-1898-22-23.tif \
				       $(GEODATA_SERVER_DIR)/Shepherd-Carolingian-Empire-843-888.tif \
				       $(GEODATA_SERVER_DIR)/Droysen-1886-22-23.tif \
				       $(GEODATA_SERVER_DIR)/10m_physical/ne_10m_ocean.shp \
				       $(GEODATA_SERVER_DIR)/10m_physical/ne_10m_rivers_lake_centerlines.shp \
				       $(GEODATA_SERVER_DIR)/10m_physical/ne_10m_rivers_europe.shp \
				       $(GEODATA_SERVER_DIR)/10m_physical/ne_10m_lakes.shp \
				       $(GEODATA_SERVER_DIR)/10m_physical/ne_10m_lakes_europe.shp

SQL     = $(PSQL) $(PGLOCAL)

$(GEODATA_SERVER_DIR)/%.shp : $(GEODATA_SRC_DIR)/%.shp $(GEODATA_SERVER_DIR)/%.shx $(GEODATA_SERVER_DIR)/%.dbf
	cp $< $@

.PRECIOUS: $(GEODATA_SERVER_DIR)/%.shx $(GEODATA_SERVER_DIR)/%.dbf

$(GEODATA_SERVER_DIR)/%.shx : $(GEODATA_SRC_DIR)/%.shx
	cp $< $@

$(GEODATA_SERVER_DIR)/%.dbf : $(GEODATA_SRC_DIR)/%.dbf
	cp $< $@

$(GEODATA_SERVER_DIR)/%.tif : $(GEODATA_SRC_DIR)/%.tif
	cp $< $@

$(GEODATA_CLIENT_DIR)/%.geojson: $(GEODATA_SRC_DIR)/%.geojson
	mkdir -p $(GEODATA_CLIENT_DIR)
	cp $< $@

geodata: geodata-client geodata-server

geodata-client: $(GEODATA_CLIENT_FILES)
	$(IMPORT) --geoareas $^

geodata-server: geodata-client $(GEODATA_SERVER_FILES)

directories:
	mkdir -p $(GEODATA_SERVER_DIR)/10m_physical \
			 $(GEODATA_SERVER_DIR)/NE2_HR_LC_SR \
			 $(GEODATA_CLIENT_DIR)/10m_cultural

clean:
	rm -rf $(GEODATA_SERVER_DIR)/* $(GEODATA_CLIENT_DIR)/*

download_geodata:
	for zip in 10m/raster/NE2_HR_LC_SR 10m/cultural/10m_cultural 10m/physical/10m_physical ; do \
		wget -P /tmp "$(NAT_EARTH)/$$zip.zip" ;     \
	done
	for dir in 10m_physical 10m_cultural NE2_HR_LC_SR ; do \
		rm -rf "$(GEODATA_SRC_DIR)/$$dir" ; \
	done
	mkdir -p $(GEODATA_SRC_DIR)/10m_physical
	unzip -d $(GEODATA_SRC_DIR)              /tmp/NE2_HR_LC_SR.zip
	unzip -d $(GEODATA_SRC_DIR)              /tmp/10m_cultural.zip
	unzip -d $(GEODATA_SRC_DIR)/10m_physical /tmp/10m_physical.zip

install_prereq:
	sudo apt-get install gdal-bin
