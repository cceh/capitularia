include ../Variables.mak

IMPORT := python3 -m scripts.import_data -vvv -c ./server.conf

upload:
	$(RSYNCPY) --exclude "server.conf" ./* $(HOST_SERVER)
	$(RSYNC) ../xslt/*.xsl ../xslt/Makefile $(HOST_SERVER)/../xslt/

install_prereq:
	sudo apt-get install python3-mapnik
	sudo pip3 install -r requirements.txt

scrape_geodata:
	$(IMPORT) --geonames --dnb
