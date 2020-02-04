#
# This is the Makefile that generates all the files in the cache directory.
#
# The cache directory contains the HTML files for display to the user and lots
# of other files: one big corpus file with all metadata tags and one file for
# every chapter in every manuscript, and more.
#
# This Makefile is run by cron on the API server.
#

ROOT_DIR  := /afs/rrz.uni-koeln.de/vol/www/projekt/capitularia/http/docs/cap

PUB_DIR   := $(ROOT_DIR)/publ
PRIV_DIR  := $(ROOT_DIR)/intern/Transkriptionen
CACHE_DIR := $(ROOT_DIR)/publ/cache

IMPORT := cd ../server; python3 -m scripts.import_data -vvv -c ./server.conf

XSL_DIR         := .
MSS_DIR         := $(PUB_DIR)/mss
MSS_PRIV_DIR    := $(PRIV_DIR)/Transkriptionsauftraege/FertigeTranskriptionen
CAPIT_DIR       := $(PUB_DIR)/capit
MSS_LISTS_DIR   := $(PUB_DIR)/mss/lists
CAPIT_LISTS_DIR := $(PUB_DIR)/capit/lists
BIB_DIR         := $(PUB_DIR)/bibl

BK_TEXT_DIR     := $(PRIV_DIR)/BK_Text_Superstruktur
BK_TEXTZEUGE    := $(BK_TEXT_DIR)/bk-textzeuge.xml

MSS := $(wildcard $(MSS_DIR)/*.xml)
IDS := $(notdir $(basename $(MSS)))

XSLTPROC  := /usr/bin/xsltproc --nonet --novalid --nomkdir
XSLTPROC2  = $(XSLTPROC) -o $@ $(word 2,$^) $<
SAXON     := /usr/bin/saxon
SAXON2     = $(SAXON) -s:"$<" -xsl:"$(word 2,$^)" -o:"$@"

TOUCH = mkdir -p $(dir $@) && touch "$@"
CLEAN_TARGET_DIR = -rm -rf $(dir $@) && mkdir -p $(dir $@)

all: mss mss_priv capits lists
	touch $(CACHE_DIR)/last_make_run

# do not waste time trying to make these files:

%.xml: ;
Makefile: ;
%.xsl: ;

# make directories first

mss: | dirs

mss_priv: | dirs

capits: | dirs

lists: | dirs

# stylesheet dependencies

vpath %.xsl $(XSL_DIR)

common         := base_variables.xsl
common-3       := common-3.xsl config-3.xsl

mss-header     := mss-header.xsl $(common)
mss-footer     := mss-footer.xsl $(common)
mss-transcript := mss-transcript.xsl mss-transcript-footnotes.xsl $(common)
mss-transcript-cte           := mss-transcript-cte.xsl $(mss-transcript)
mss-transcript-with-comments := mss-transcript-with-comments.xsl $(mss-transcript)

capit      := capit.xsl      $(common-3)
mss-capit  := mss-capit.xsl  $(common-3)
mss-idno   := mss-idno.xsl   $(common-3)
mss-key    := mss-key.xsl    $(common-3)
mss-table  := mss-table.xsl  $(common-3)
capit-list := capit-list.xsl $(common-3)

mss-transcript-collation := mss-transcript-collation.xsl mss-transcript-phase-1.xsl $(common-3)
mss-extract-chapters     := mss-extract-chapters.xsl $(mss-transcript-collation)

################ MSS

SECTIONS := header transcript footer

define MSS_TEMPLATE =

$(CACHE_DIR)/mss/%.$(1).html : $(MSS_DIR)/%.xml $(mss-$(1))
	$(XSLTPROC) -o $$@ $$(word 2,$$^) $$<

mss : $(patsubst %,$(CACHE_DIR)/mss/%.$(1).html,$(IDS))

$(CACHE_DIR)/internal/mss/%.$(1).html : $(MSS_PRIV_DIR)/%.xml $(mss-$(1))
	$(XSLTPROC) -o $$@ $$(word 2,$$^) $$<

mss_priv : $(patsubst %.xml,$(CACHE_DIR)/internal/mss/%.$(1).html,$(notdir $(wildcard $(MSS_PRIV_DIR)/*.xml)))

endef

$(foreach s,$(SECTIONS),$(eval $(call MSS_TEMPLATE,$(s))))

## commented transcripts for the editors

$(CACHE_DIR)/mss/%.transcript.commented.html : $(MSS_DIR)/%.xml $(mss-transcript-with-comments)
	$(XSLTPROC) -o $@ $(word 2,$^) $<

mss : $(patsubst %,$(CACHE_DIR)/mss/%.transcript.commented.html,$(IDS))

## extract each xml corresp as file
## fulltext and collation

$(CACHE_DIR)/extracted/%/ : $(MSS_DIR)/%.xml $(mss-extract-chapters)
	$(CLEAN_TARGET_DIR)
	$(SAXON) -s:"$<" -xsl:mss-extract-chapters.xsl directory="$(dir $@)"
	-$(TOUCH)

fulltext : $(patsubst %,$(CACHE_DIR)/extracted/%/,$(IDS))


################ CAPITS

CAPITS := pre814 ldf post840 undated

define CAPIT_TEMPLATE =

$(CACHE_DIR)/capits/$(1)/%.html : $(CAPIT_DIR)/$(1)/%.xml $(capit)
	$(SAXON) -s:"$$<" -xsl:"$$(word 2,$$^)" -o:"$$@"

capits : $(patsubst %.xml,$(CACHE_DIR)/capits/$(1)/%.html,$(notdir $(wildcard $(CAPIT_DIR)/$(1)/*.xml)))

endef

$(foreach c,$(CAPITS),$(eval $(call CAPIT_TEMPLATE,$(c))))


################ MSS LISTS

MSS_LISTS := mss-table mss-capit mss-idno mss-key

mss-table_XML  := $(MSS_LISTS_DIR)/ueberblick_mordek.xml
mss-capit_XML  := $(MSS_LISTS_DIR)/mss_by_cap.xml  $(MSS_LISTS_DIR)/manuscripts.xml
mss-idno_XML   := $(MSS_LISTS_DIR)/manuscripts.xml $(CACHE_DIR)/lists/corpus.xml
mss-key_XML    := $(MSS_LISTS_DIR)/manuscripts.xml

define MSS_LISTS_TEMPLATE =

$(CACHE_DIR)/lists/$(1).html : $($(1)_XML) $($(1))
	$(SAXON) -s:"$$<" -xsl:"$(1).xsl" -o:"$$@" corpus="$(CACHE_DIR)/lists/corpus.xml" \
	                                           manuscripts="$(MSS_LISTS_DIR)/manuscripts.xml"

lists : $(CACHE_DIR)/lists/$(1).html

endef

$(foreach l,$(MSS_LISTS),$(eval $(call MSS_LISTS_TEMPLATE,$(l))))

################ CAPIT LISTS

CAPIT_LISTS := capit-all capit-pre814 capit-ldf capit-post840 capit-undated

capit-list_XML := $(CAPIT_LISTS_DIR)/capit_all.xml

define CAPIT_LISTS_TEMPLATE =

$(CACHE_DIR)/lists/$(1).html : $(capit-list_XML) $(capit-list)
	$(SAXON) -s:"$$<" -xsl:"$$(word 2,$$^)" -o:"$$@" type=$(patsubst capit-%,%,$(1))

lists : $(CACHE_DIR)/lists/$(1).html

endef

$(foreach l,$(CAPIT_LISTS),$(eval $(call CAPIT_LISTS_TEMPLATE,$(l))))


################ BIB

bib_XML := $(BIB_DIR)/Bibliographie_Capitularia.xml

$(CACHE_DIR)/lists/bib.html : $(bib_XML) bib-bibliography.xsl
	$(XSLTPROC) -o $@ $(word 2,$^) $<

lists : $(CACHE_DIR)/lists/bib.html


################ Bits and pieces

$(CACHE_DIR)/lists/places.html : $(PUB_DIR)/resources/capitularia_place.xml register_cap_places.xsl
	$(XSLTPROC2)

lists : $(CACHE_DIR)/lists/places.html


$(CACHE_DIR)/mss/cte-137.html: $(MSS_DIR)/texts/137.xml $(mss-transcript-cte)
	$(XSLTPROC) --stringparam title Edition -o $@ $(word 2,$^) $<

mss : $(CACHE_DIR)/mss/cte-137.html


$(CACHE_DIR)/mss/cte-137-de.html: $(MSS_DIR)/texts/137-de.xml $(mss-transcript-cte)
	$(XSLTPROC) --stringparam title Übersetzung -o $@ $(word 2,$^) $<

mss : $(CACHE_DIR)/mss/cte-137-de.html


$(CACHE_DIR)/lists/corpus.xml : corpus.xsl $(MSS_DIR)/*.xml
	$(SAXON) -it:main -xsl:"$<" -o:"$@" dir="$(MSS_DIR)"

$(CACHE_DIR)/lists/downloads.html : $(CACHE_DIR)/lists/corpus.xml downloads.xsl
	$(SAXON2)

$(CACHE_DIR)/lists/changes.html : $(CACHE_DIR)/lists/corpus.xml changes.xsl
	$(SAXON2) prefix=A

$(CACHE_DIR)/lists/changes90.html : $(CACHE_DIR)/lists/corpus.xml changes.xsl
	$(SAXON2) prefix=B scope=P90D

corpus : $(CACHE_DIR)/lists/corpus.xml

downloads: $(CACHE_DIR)/lists/downloads.html

changes: $(CACHE_DIR)/lists/changes.html $(CACHE_DIR)/lists/changes90.html

lists : corpus downloads changes


## scrape targets
# these are timestamp files

init_db:
	$(IMPORT) --init
	$(RM) $(CACHE_DIR)/last_*_scrape

$(CACHE_DIR)/last_corpus_scrape : $(CACHE_DIR)/lists/corpus.xml $(capit-list_XML)
	$(IMPORT) --mss      $(CACHE_DIR)/lists/corpus.xml
	$(IMPORT) --cap-list $(capit-list_XML)
	touch "$@"

$(CACHE_DIR)/last_fulltext_scrape : $(wildcard $(CACHE_DIR)/extracted/*/*.xml $(CACHE_DIR)/extracted/*/*.txt)
	$(file >$@,$?)            # put the very long argument list into a file
	$(IMPORT) --fulltext @$@  # read filenames to import from the file
	sed -i -e 's/ /\n/g' "$@" # make it human-readable for debugging, also touch-es the file

# copies information from the wordpress db into the postgres db
# the timestamp file doesn't depend on anything
$(CACHE_DIR)/last_status_scrape :
	$(IMPORT) --publish
	touch "$@"


scrape_corpus :   $(CACHE_DIR)/last_corpus_scrape

scrape_fulltext : $(CACHE_DIR)/last_fulltext_scrape

scrape_status :   $(CACHE_DIR)/last_status_scrape


################

clean:
	rm -rf $(CACHE_DIR)

dirs:
	mkdir -p $(CACHE_DIR)
	mkdir -p $(CACHE_DIR)/mss $(CACHE_DIR)/capits $(CACHE_DIR)/lists \
			 $(CACHE_DIR)/internal/mss \
			 $(CACHE_DIR)/extracted    \
			 $(CACHE_DIR)/collation
	mkdir -p $(foreach c,$(CAPITS),$(CACHE_DIR)/capits/$(c))

.PHONY: all mss capits lists clean dirs corpus fulltext

.PHONY: init_db scrape_corpus scrape_fulltext scrape_status $(CACHE_DIR)/last_status_scrape
