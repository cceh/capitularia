include ../Variables.mak

GEODATA_SRC_DIR    = ./geodata

GEODATA_CLIENT_DIR = ../client/build/geodata
GEODATA_SERVER_DIR = ../server/geodata

GEODATA_LAYERS     = countries_843 countries_870 countries_888 countries_modern regions_843

GEODATA_CLIENT_FILES = $(patsubst %,$(GEODATA_CLIENT_DIR)/%.geojson,$(GEODATA_LAYERS))

GEODATA_SERVER_FILES = $(GEODATA_SERVER_DIR)/NE2_HR_LC_SR/NE2_HR_LC_SR.tif \
				       $(GEODATA_SERVER_DIR)/Vidal-LaBlache-1898-22-23.tif \
				       $(GEODATA_SERVER_DIR)/Shepherd-Carolingian-Empire-843-888.tif \
				       $(GEODATA_SERVER_DIR)/10m_physical/ne_10m_ocean.shp \
				       $(GEODATA_SERVER_DIR)/10m_physical/ne_10m_rivers_lake_centerlines.shp \
				       $(GEODATA_SERVER_DIR)/10m_physical/ne_10m_rivers_europe.shp \
				       $(GEODATA_SERVER_DIR)/10m_physical/ne_10m_lakes.shp \
				       $(GEODATA_SERVER_DIR)/10m_physical/ne_10m_lakes_europe.shp

OGR2OGR = ogr2ogr -t_srs epsg:4326 -nlt MULTIPOLYGON
OGRPG   = -f PostgreSQL PG:'host=$(CAPITULARIA_PGHOST) user=$(CAPITULARIA_PGSUPERUSER) dbname=$(CAPITULARIA_PGDATABASE)'

$(GEODATA_SERVER_DIR)/%.shp : $(GEODATA_SRC_DIR)/%.shp $(GEODATA_SERVER_DIR)/%.shx $(GEODATA_SERVER_DIR)/%.dbf
	cp $< $@

.PRECIOUS: $(GEODATA_SERVER_DIR)/%.shx $(GEODATA_SERVER_DIR)/%.dbf

$(GEODATA_SERVER_DIR)/%.shx : $(GEODATA_SRC_DIR)/%.shx
	cp $< $@

$(GEODATA_SERVER_DIR)/%.dbf : $(GEODATA_SRC_DIR)/%.dbf
	cp $< $@

$(GEODATA_SERVER_DIR)/%.tif : $(GEODATA_SRC_DIR)/%.tif
	cp $< $@

#$(GEODATA_SRC_DIR)/%.geojson:
#	$(OGR2OGR) -preserve_fid $@ $(OGRPG) $(basename $(notdir $@))

$(GEODATA_CLIENT_DIR)/%.geojson: $(GEODATA_SRC_DIR)/%.geojson
	cp $< $@

$(GEODATA_CLIENT_DIR)/countries_modern.geojson: $(GEODATA_SRC_DIR)/10m_cultural/ne_10m_admin_0_countries.shp
	$(OGR2OGR) -f GeoJSON -preserve_fid -nln $(basename $(notdir $@)) \
		-sql "SELECT name as geo_name, 'PCLI' as geo_fcode FROM $(basename $(notdir $<)) \
              WHERE continent = 'Europe'" $@ $<

geodata: geodata-server geodata-client

geodata-client: $(GEODATA_CLIENT_FILES)

geodata-server: $(GEODATA_SERVER_FILES)

.PHONY: import-geodata-to-postgres

import-geodata-to-postgres: $(GEODATA_CLIENT_FILES)
	for layer in $(GEODATA_LAYERS); do \
		echo $$layer; \
		$(OGR2OGR) $(OGRPG) -preserve_fid -nln $$layer -append --config OGR_TRUNCATE YES \
		    -sql "SELECT fid as geo_id, geo_name, geo_fcode FROM $$layer" $(GEODATA_CLIENT_DIR)/$$layer.geojson; \
	done

directories:
	-mkdir -p $(GEODATA_SERVER_DIR)/10m_physical $(GEODATA_SERVER_DIR)/NE2_HR_LC_SR $(GEODATA_CLIENT_DIR)/10m_cultural

clean:
	rm -rf $(GEODATA_SERVER_DIR)/* $(GEODATA_CLIENT_DIR)/*

download_geodata:
	for zip in 10m/raster/NE2_HR_LC_SR 10m/cultural/10m_cultural 10m/physical/10m_physical ; do \
		wget -P /tmp "$(NAT_EARTH)/$$zip.zip" ;     \
	done
	mkdir -p gis/geodata/10m_physical
	unzip -d gis/geodata              /tmp/NE2_HR_LC_SR.zip
	unzip -d gis/geodata              /tmp/10m_cultural.zip
	unzip -d gis/geodata/10m_physical /tmp/10m_physical.zip

install_prereq:
	sudo apt-get install gdal-bin
