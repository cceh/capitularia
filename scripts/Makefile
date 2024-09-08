AUTO_DIR := /var/www/capitularia.uni-koeln.de/cap/intern/Automatik

cte_index: $(AUTO_DIR)/Index/index.xml

$(AUTO_DIR)/Index/index.xml : $(subst \ ,+,$(wildcard $(AUTO_DIR)/Index/*.txt))
	python3 $(CAPITULARIA_PRJ)/scripts/cte_index_merger.py $^ > $@
