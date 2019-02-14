include ../Variables.mak

upload:
	$(RSYNCPY) --exclude "server.conf" ./* $(HOST_SERVER)

init_geodata_db:
	python3 -m scripts.init_geonames -vvv -c ./server.conf --init --init-geolayers \
		--mss ../xml/*.xml --cap-list ../capit/lists/capit_all.xml --geonames --dnb

install_prereq:
	sudo apt-get install python3-mapnik
	sudo pip3 install geoalchemy2
