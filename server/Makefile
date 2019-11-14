include ../Variables.mak

upload:
	$(RSYNCPY) --exclude "server.conf" ./* $(HOST_SERVER)
	$(RSYNC) ../xslt/*.xsl ../xslt/Makefile $(HOST_SERVER)/../xslt/

# sudo -u postgres psql
#
# CREATE USER capitularia PASSWORD '<password>';
# CREATE DATABASE capitularia OWNER capitularia;
#
# \c capitularia
# CREATE EXTENSION postgis;
# CREATE SCHEMA capitularia AUTHORIZATION capitularia;
# ALTER DATABASE capitularia SET search_path = capitularia, public;
# \q

init_db:
	python3 -m scripts.import_data -vvv -c ./server.conf --init

scrape_corpus:
	python3 -m scripts.import_data -vvv -c ./server.conf \
		--mss ../cache/lists/corpus.xml \
		--cap-list ../capit/lists/capit_all.xml \
		--publish

scrape_geodata:
	python3 -m scripts.import_data -vvv -c ./server.conf --geonames --dnb

install_prereq:
	sudo apt-get install python3-mapnik
	sudo pip3 install -r requirements.txt

import:
	python3 -m scripts.import_data -vvv -c ./server.conf --init --init-geolayers \
		--mss ../cache/lists/corpus.xml
