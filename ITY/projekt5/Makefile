# K suboru: proj4.tex
# Datum:    25.4. 2025
# Autor:    Radim Pokorny (xpokorr00@fit.vutbr.cz)
# Projekt:  ITY proj 5

PROJ=proj5

all: $(PROJ).pdf

$(PROJ).pdf: $(PROJ).tex 
	pdflatex $(PROJ).tex
	pdflatex $(PROJ).tex
	pdflatex $(PROJ).tex

clean:
	rm -f $(PROJ).aux $(PROJ).bcf $(PROJ).blg \
	       $(PROJ).log $(PROJ).run.xml $(PROJ).toc
# VS Code automated compilation files	
	rm -f $(PROJ).fdb_latexmk $(PROJ).fls $(PROJ).*.gz

clean-all: clean
	rm -f $(PROJ).pdf