XML=$(HOME)/uni/prj/capitularia/Documents/"Italische Sammlungen 8.xml"
OUT=/tmp
DEST=mperatho@dialog.rrz.uni-koeln.de:~/capitularia/http/docs/cap/intern/workspace/grafics/

BRITTA=$(OUT)/britta
COLLECTIONS=$(OUT)/collections

britta: pyc
	-rm -rf $(BRITTA)
	-mkdir -p $(BRITTA)
	./britta.sh $(XML) $(BRITTA)

collections: pyc
	-rm -rf $(COLLECTIONS)
	-mkdir -p $(COLLECTIONS)
	./collections.sh $(XML) $(COLLECTIONS)

sync-britta:
	rsync -v $(BRITTA)/* $(DEST)/britta/

sync-collections:
	rsync -v $(COLLECTIONS)/* $(DEST)/collections/

.PHONY: pyc
pyc:
	python3 -m compileall ./
