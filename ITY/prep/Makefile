# K suboru: proj1.tex
# Datum:    28.2. 2025
# Autor:    Radim Pokorny (xpokorr00@fit.vutbr.cz)
# Projekt:  ITY proj 1

PROJ=prep


$(PROJ).pdf: $(PROJ).tex
	latex $(PROJ).tex
	latex $(PROJ).tex
	dvips -t a4 $(PROJ).dvi
	ps2pdf $(PROJ).ps

clean:
	rm -f $(PROJ).aux $(PROJ).dvi $(PROJ).log $(PROJ).ps $(PROJ).out
# VS Code automated compilation files	
	rm -f $(PROJ).fdb_latexmk $(PROJ).fls $(PROJ).*.gz

clean-all: clean
	rm -f $(PROJ).pdf
