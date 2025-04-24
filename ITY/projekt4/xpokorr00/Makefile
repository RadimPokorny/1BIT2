# K suboru: proj4.tex
# Datum:    18.4. 2025
# Autor:    Radim Pokorny (xpokorr00@fit.vutbr.cz)
# Projekt:  ITY proj 4

PROJ=proj4

all: $(PROJ).pdf

$(PROJ).pdf: $(PROJ).tex literatura.bib
	pdflatex $(PROJ).tex
	biber $(PROJ)
	pdflatex $(PROJ).tex
	pdflatex $(PROJ).tex

clean:
	rm -f $(PROJ).aux $(PROJ).bbl $(PROJ).bcf $(PROJ).blg \
	       $(PROJ).log $(PROJ).run.xml $(PROJ).toc
# VS Code automated compilation files	
	rm -f $(PROJ).fdb_latexmk $(PROJ).fls $(PROJ).*.gz

clean-all: clean
	rm -f $(PROJ).pdf