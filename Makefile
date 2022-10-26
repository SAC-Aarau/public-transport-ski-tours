MAKEFILE_PATH=$(abspath $(lastword $(MAKEFILE_LIST)))
ROOT=$(shell dirname "$(MAKEFILE_PATH)")
UID=$(shell uuid -v5 50403402-3616-42a9-8c80-6a614d79b1e6 "$(ROOT)")
DATE=$(shell date '+%-d. %B %Y')
DATE_ISO=$(shell date --iso-8601=date)

PDFLATEX=pdflatex
PANDOC=pandoc
MMDC=mmdc
INKSCAPE=inkscape
TEMP=$(shell mktemp -u -d | xargs dirname | xargs printf '%s/$(UID)')
DIST=$(ROOT)/dist
MEDIA=$(ROOT)/media
SRC=$(ROOT)/src

PANDOC_PARAMS= \
	--embed-resources \
	--standalone \
	--metadata-file='$(ROOT)/meta.yml' \
	--resource-path='$(SRC)'

MMD_FILES=$(wildcard $(MEDIA)/*.mmd)
MMD_PDF_FILES=$(foreach wrd,$(MMD_FILES),$(wrd).pdf)

TEX_FILES=$(wildcard $(MEDIA)/*.tex)
TEX_PDF_FILES=$(foreach wrd,$(TEX_FILES),$(wrd).pdf)

SVG_FILES=$(wildcard $(MEDIA)/*.svg)
SVG_PDF_FILES=$(foreach wrd,$(SVG_FILES),$(wrd).pdf)

DISCLAIMER_WEB=$(SRC)/web/disclaimer.md
DISCLAIMER_DOC=$(SRC)/doc/disclaimer.md
TABLE=$(SRC)/common/table.md
TITLE=$(SRC)/doc/title.md
INTRO=$(SRC)/web/intro.md
STYLES=$(SRC)/web/styles.html
CONFIGS=$(wildcard $(ROOT)/*.yml)
DOCUMENT_TEX=$(TEMP)/template.tex
DOCUMENT_PDF=$(DIST)/oev-skitouren-ab-aarau.pdf
WEBPAGE_HTML=$(DIST)/index.html

all: init $(DOCUMENT_PDF) $(WEBPAGE_HTML)
$(MEDIA)/%.mmd.pdf: $(MEDIA)/%.mmd
	$(MMDC) --input $^ --output "$@" --backgroundColor transparent --pdfFit --width 600 --height 600 --theme neutral
$(MEDIA)/%.tex.pdf: $(MEDIA)/%.tex
	cp $^ $(TEMP)/temp.tex
	$(PDFLATEX) -interaction=nonstopmode -output-directory=$(TEMP) $(TEMP)/temp.tex
	mv $(TEMP)/temp.pdf "$@"
	rm -f $(TEMP)/temp.*
$(MEDIA)/%.svg.pdf: $(MEDIA)/%.svg
	inkscape --export-area-drawing --export-filename="$@" "$^"
$(DOCUMENT_PDF): $(CONFIGS) $(MMD_PDF_FILES) $(TEX_PDF_FILES) $(SVG_PDF_FILES) $(TITLE) $(TABLE) $(DISCLAIMER_DOC)
	$(PANDOC) \
		$(PANDOC_PARAMS) \
		--output='$(DOCUMENT_TEX)' \
		'$(TITLE)' '$(TABLE)' '$(DISCLAIMER_DOC)'
	cat $(DOCUMENT_TEX) | sed 's@\\\\@\\\\ \\midrule()@' > $(DOCUMENT_TEX).temp
	tac $(DOCUMENT_TEX).temp | sed -E '0,/\\midrule\(\)/{s@\\midrule\(\)@@}' | tac > $(DOCUMENT_TEX)
	xelatex -output-directory $(TEMP) $(DOCUMENT_TEX)
	xelatex -output-directory $(TEMP) $(DOCUMENT_TEX)
	mv $(TEMP)/template.pdf $(DOCUMENT_PDF)
$(WEBPAGE_HTML): $(CONFIGS) $(DOCUMENT_PDF) $(MMD_PDF_FILES) $(TEX_PDF_FILES) $(SVG_PDF_FILES) $(INTRO) $(TABLE) $(DISCLAIMER_WEB) $(STYLES)
	$(PANDOC) \
		$(PANDOC_PARAMS) \
		--strip-comments \
		--section-divs \
		--include-in-header='$(STYLES)' \
		--metadata author='' \
		--metadata date-meta='$(DATE_ISO)' \
		--output=$(WEBPAGE_HTML) \
		$(INTRO) $(TABLE) $(DISCLAIMER_WEB)
	sed -i -E 's@\{publish-date\}@$(DATE)@' $(WEBPAGE_HTML)
init:
	mkdir -p $(TEMP)
	mkdir -p $(DIST)
clean:
	rm -rf $(TEMP)
	rm -rf $(DIST)
	rm -f $(MEDIA)/*.mmd.pdf
	rm -f $(MEDIA)/*.tex.pdf
	rm -f $(MEDIA)/*.svg.pdf
