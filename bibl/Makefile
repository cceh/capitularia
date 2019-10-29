FN=capitularia

LATEX=TEXINPUTS=.:build; xelatex -output-directory build/
BIBER=biber --output-directory=build/

all: build/$(FN).pdf

clean:
	-rm *~ build/*

build/capitularia.bib: Bibliographie_Capitularia.xml convertbib.xsl
	saxon -s:$< convertbib.xsl style=biblatex > $@

build/capitularia-zotero.bib: Bibliographie_Capitularia.xml convertbib.xsl
	saxon -s:$< convertbib.xsl style=zotero > $@

build/capitularia-citavi.bib: Bibliographie_Capitularia.xml convertbib.xsl
	saxon -s:$< convertbib.xsl style=citavi > $@

build/$(FN).bcf: $(FN).ltx
	$(LATEX) $<

build/$(FN).bbl: $(FN).ltx build/capitularia.bib biber.conf
	$(LATEX) $<
	$(BIBER) $(FN)

build/$(FN).pdf: $(FN).ltx capitularia.bbx build/$(FN).bbl
	$(LATEX) $<

prod: build/$(FN).pdf
	$(LATEX) $(FN).ltx # again

update_bib_xml:
	cp ~/uni/capitularia/http/docs/cap/publ/bibl/Bibliographie_Capitularia.xml .

bibliography.rnc: bibliography.rng
	trang $< $@
