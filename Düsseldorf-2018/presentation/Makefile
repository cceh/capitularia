# Minimal makefile for Sphinx documentation
#

# You can set these variables from the command line.
SPHINXOPTS    =
SPHINXBUILD   = python3 -msphinx
SPHINXPROJ    = Mainz2017
SOURCEDIR     = .
BUILDDIR      = _build

.PHONY: html clean Makefile

html: Makefile
	$(SPHINXBUILD) -b html $(SPHINXOPTS) $(SOURCEDIR) $(BUILDDIR)
	@echo
	@echo "Build finished. The HTML pages are in $(BUILDDIR)."

clean:
	rm -rf $(BUILDDIR)/*
