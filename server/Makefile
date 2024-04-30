include ../Variables.mak

IMPORT := ../.venv/bin/python3 -m scripts.import_data -vvv -c ./server.conf

deploy:
	$(RSYNCPY) --exclude "server.conf" ./* $(HOST_SERVER)

install_prereq:
	sudo apt-get install python3-mapnik
	sudo pip3 install -r requirements.txt

scrape_geodata:
	$(IMPORT) --geonames --dnb
