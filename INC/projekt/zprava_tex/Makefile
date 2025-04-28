# Makefile pro PDF výstup z LaTeX (pouze pdflatex)

PROJ=zprava

$(PROJ).pdf: $(PROJ).tex
	pdflatex $(PROJ).tex
	pdflatex $(PROJ).tex  # kvůli referencím a hyperref warningům

clean:
	rm -f $(PROJ).aux $(PROJ).log $(PROJ).out $(PROJ).toc
# VS Code automated compilation files	
	rm -f $(PROJ).fdb_latexmk $(PROJ).fls $(PROJ).*.gz

clean-all: clean
	rm -f $(PROJ).pdf