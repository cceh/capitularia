#
# This is the Makefile that generates all HTML files from all TEI files.
# It is run by cron on the API server.
#

ROOT_DIR  := /afs/rrz.uni-koeln.de/vol/www/projekt/capitularia/http/docs/cap

PUB_DIR   := $(ROOT_DIR)/publ
PRIV_DIR  := $(ROOT_DIR)/intern/Transkriptionen
CACHE_DIR := $(ROOT_DIR)/publ/cache

XSL_DIR         := .
MSS_DIR         := $(PUB_DIR)/mss
MSS_PRIV_DIR    := $(PRIV_DIR)/Transkriptionsauftraege/FertigeTranskriptionen
CAPIT_DIR       := $(PUB_DIR)/capit
MSS_LISTS_DIR   := $(PUB_DIR)/mss/lists
CAPIT_LISTS_DIR := $(PUB_DIR)/capit/lists
BIB_DIR         := $(PUB_DIR)/bibl

BK_TEXT_DIR     := $(PRIV_DIR)/BK_Text_Superstruktur
BK_TEXTZEUGE    := $(BK_TEXT_DIR)/bk-textzeuge.xml

XSLTPROC  := /usr/bin/xsltproc --nonet --novalid --nomkdir
XSLTPROC2  = $(XSLTPROC) -o $@ $(word 2,$^) $<
SAXON     := /usr/bin/saxon
SAXON2     = $(SAXON) -s:"$<" -xsl:"$(word 2,$^)" -o:"$@"

TOUCH = mkdir -p $(dir $@) && touch "$@"

all: mss mss_priv capits lists
	touch $(CACHE_DIR)/last_make_run

collation:
	touch $(CACHE_DIR)/last_collation_run


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
mss-header     := mss-header.xsl $(common)
mss-footer     := mss-footer.xsl $(common)
mss-transcript := mss-transcript.xsl mss-transcript-footnotes.xsl $(common)
mss-transcript-cte           := mss-transcript-cte.xsl $(mss-transcript)
mss-transcript-with-comments := mss-transcript-with-comments.xsl $(mss-transcript)
mss-transcript-collation     := mss-transcript-collation.xsl $(mss-transcript)
capit      := capit.xsl      $(common)
mss-capit  := mss-capit.xsl  $(common)
mss-idno   := mss-idno.xsl   $(common)
mss-key    := mss-key.xsl    $(common)
mss-table  := mss-table.xsl  $(common)
capit-list := capit-list.xsl $(common)

mss-extract-chapters := mss-extract-chapters.xsl common-3.xsl

################ MSS

SECTIONS := header transcript footer

define MSS_TEMPLATE =

$(CACHE_DIR)/mss/%.$(1).html : $(MSS_DIR)/%.xml $(mss-$(1))
	$(XSLTPROC) -o $$@ $$(word 2,$$^) $$<

mss : $(patsubst %.xml,$(CACHE_DIR)/mss/%.$(1).html,$(notdir $(wildcard $(MSS_DIR)/*.xml)))

$(CACHE_DIR)/internal/mss/%.$(1).html : $(MSS_PRIV_DIR)/%.xml $(mss-$(1))
	$(XSLTPROC) -o $$@ $$(word 2,$$^) $$<

mss_priv : $(patsubst %.xml,$(CACHE_DIR)/internal/mss/%.$(1).html,$(notdir $(wildcard $(MSS_PRIV_DIR)/*.xml)))

endef

$(foreach s,$(SECTIONS),$(eval $(call MSS_TEMPLATE,$(s))))


$(CACHE_DIR)/mss/%.transcript.commented.html : $(MSS_DIR)/%.xml $(mss-transcript-with-comments)
	$(XSLTPROC) -o $@ $(word 2,$^) $<

mss : $(patsubst %.xml,$(CACHE_DIR)/mss/%.transcript.commented.html,$(notdir $(wildcard $(MSS_DIR)/*.xml)))


$(CACHE_DIR)/collation/%/timestamp : $(MSS_DIR)/%.xml $(mss-extract-chapters)
	$(SAXON) -s:"$<" -xsl:mss-extract-chapters.xsl directory="$(dir $@)"
	-$(TOUCH)

$(CACHE_DIR)/collation/bk-textzeuge/timestamp : $(BK_TEXTZEUGE) $(mss-extract-chapters)
	$(SAXON) -s:"$<" -xsl:mss-extract-chapters.xsl directory="$(dir $@)"
	-$(TOUCH)

collation : $(patsubst %.xml,$(CACHE_DIR)/collation/%/timestamp,$(notdir $(wildcard $(MSS_DIR)/*.xml)))

collation : $(CACHE_DIR)/collation/bk-textzeuge/timestamp


################ CAPITS

CAPITS := pre814 ldf post840 undated

define CAPIT_TEMPLATE =

$(CACHE_DIR)/capits/$(1)/%.html : $(CAPIT_DIR)/$(1)/%.xml $(capit)
	$(XSLTPROC) -o $$@ $$(word 2,$$^) $$<

capits : $(patsubst %.xml,$(CACHE_DIR)/capits/$(1)/%.html,$(notdir $(wildcard $(CAPIT_DIR)/$(1)/*.xml)))

endef

$(foreach c,$(CAPITS),$(eval $(call CAPIT_TEMPLATE,$(c))))


################ MSS LISTS

MSS_LISTS := mss-capit mss-idno mss-key mss-table

mss-capit_XML  := $(MSS_LISTS_DIR)/mss_by_cap.xml
mss-idno_XML   := $(MSS_LISTS_DIR)/BibCapitMordek.xml
mss-key_XML    := $(MSS_LISTS_DIR)/sigle.xml
mss-table_XML  := $(MSS_LISTS_DIR)/ueberblick_mordek.xml

define MSS_LISTS_TEMPLATE =

$(CACHE_DIR)/lists/$(1).html : $($(1)_XML) $($(1))
	$(XSLTPROC) -o $$@ $$(word 2,$$^) $$<

lists : $(CACHE_DIR)/lists/$(1).html

endef

$(foreach l,$(MSS_LISTS),$(eval $(call MSS_LISTS_TEMPLATE,$(l))))


################ CAPIT LISTS

CAPIT_LISTS := capit-pre814 capit-ldf capit-post840 capit-undated

capit-list_XML := $(CAPIT_LISTS_DIR)/capit_all.xml

define CAPIT_LISTS_TEMPLATE =

$(CACHE_DIR)/lists/$(1).html : $(capit-list_XML) $(capit-list)
	$(XSLTPROC) --stringparam type $(patsubst capit-%,%,$(1)) -o $$@ $$(word 2,$$^) $$<

lists : $(CACHE_DIR)/lists/$(1).html

endef

$(foreach l,$(CAPIT_LISTS),$(eval $(call CAPIT_LISTS_TEMPLATE,$(l))))

$(CACHE_DIR)/lists/capit-all.html : $(capit-list_XML) $(capit-list)
	$(XSLTPROC) -o $@ $(word 2,$^) $<

lists : $(CACHE_DIR)/lists/capit-all.html


################ BIB

bib_XML := $(BIB_DIR)/Bibliographie_Capitularia.xml

$(CACHE_DIR)/lists/bib.html : $(bib_XML) bib-bibliography.xsl
	$(XSLTPROC) -o $@ $(word 2,$^) $<

lists : $(CACHE_DIR)/lists/bib.html


################ Bits and pieces

$(CACHE_DIR)/lists/places.html : $(PUB_DIR)/resources/capitularia_place.xml register_cap_places.xsl
	$(XSLTPROC2)

lists : $(CACHE_DIR)/lists/places.html


$(CACHE_DIR)/internal/mss/bk-textzeuge.html : $(BK_TEXTZEUGE) $(mss-transcript)
	$(XSLTPROC2)

mss_priv : $(CACHE_DIR)/internal/mss/bk-textzeuge.html


$(CACHE_DIR)/mss/cte-137.html: $(MSS_DIR)/texts/137.xml $(mss-transcript-cte)
	$(XSLTPROC) --stringparam title Edition -o $@ $(word 2,$^) $<

mss : $(CACHE_DIR)/mss/cte-137.html


$(CACHE_DIR)/mss/cte-137-de.html: $(MSS_DIR)/texts/137-de.xml $(mss-transcript-cte)
	$(XSLTPROC) --stringparam title Übersetzung -o $@ $(word 2,$^) $<

mss : $(CACHE_DIR)/mss/cte-137-de.html


$(CACHE_DIR)/lists/corpus.xml : corpus.xsl $(MSS_DIR)/*.xml $(BK_TEXTZEUGE)
	$(SAXON) -it:main -xsl:"$<" -o:"$@" dir="$(MSS_DIR)" dir2="$(BK_TEXTDIR)"

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


################

clean:
	rm -rf $(CACHE_DIR)

dirs:
	mkdir -p $(CACHE_DIR)
	mkdir -p $(CACHE_DIR)/mss $(CACHE_DIR)/capits $(CACHE_DIR)/lists \
			 $(CACHE_DIR)/internal/mss $(CACHE_DIR)/collation
	mkdir -p $(foreach c,$(CAPITS),$(CACHE_DIR)/capits/$(c))

.PHONY: all mss capits lists clean dirs
