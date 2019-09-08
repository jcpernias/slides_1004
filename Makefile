SHELL := /bin/sh

subject_code := 1004
units := 1A 1B # 1C 1D 1E
unit_figs := 1B

TEXI2DVI_SILENT := -q
# TEXI2DVI_SILENT :=

## Directories
## ================================================================================

rootdir := .
builddir := $(rootdir)/build
outdir := $(rootdir)/pdf
elispdir := $(rootdir)/elisp
pythondir := $(rootdir)/python
texdir := $(rootdir)/tex
depsdir := $(rootdir)/.deps
imgdir := $(rootdir)/img
figdir := $(rootdir)/figures

## Programs
## ================================================================================

emacsbin := /usr/local/bin/emacs
texi2dvibin := /usr/local/opt/texinfo/bin/texi2dvi
envbin  := /usr/local/opt/coreutils/libexec/gnubin/env
pythonbin := /usr/local/bin/python3

## Variables
## ================================================================================

EMACS := $(emacsbin) -Q -nw --batch
emacs_loads := --load=$(elispdir)/setup-org.el \
	--load=$(elispdir)/mats.el
org_to_latex := --eval "(tolatex (file-name-as-directory \"$(builddir)\"))"
org_to_beamer := --eval "(tobeamer (file-name-as-directory \"$(builddir)\"))"
tangle := --eval "(tangle-to (file-name-as-directory \"$(builddir)\"))"

TEXI2DVI := $(envbin) TEXI2DVI_USE_RECORDER=yes \
	$(texi2dvibin) --batch $(TEXI2DVI_SILENT) \
	-I $(texdir) --pdf --build=tidy \
	--build-dir=$(notdir $(builddir))

MAKEORGDEPS := $(pythonbin) $(pythondir)/makeorgdeps.py
MAKETEXDEPS := $(pythonbin) $(pythondir)/maketexdeps.py
MAKEFIGDEPS := $(pythonbin) $(pythondir)/makefigdeps.py

docs_es := $(addsuffix _$(subject_code)-es, \
	$(addprefix hdout-, $(units)) \
	$(addprefix pres-, $(units)))
docs_en := $(addsuffix _$(subject_code)-en, \
	$(addprefix hdout-, $(units)) \
	$(addprefix pres-, $(units)))

docs_base := $(docs_es) $(docs_en)
docs_pdf := $(addprefix $(outdir)/, $(addsuffix .pdf, $(docs_base)))

real_rootdir := $(realpath $(rootdir))
tex_check_dirs := $(rootdir)/paths.org $(builddir) $(depsdir)

## Automatic dependencies
## ================================================================================
docs_deps := $(addprefix $(depsdir)/, \
	$(addsuffix .pdf.d, $(docs_base)))

tex_deps := $(addprefix $(depsdir)/unit-, \
	$(addsuffix _$(subject_code)-es.tex.d, $(units))) \
	$(addprefix $(depsdir)/unit-, \
	$(addsuffix _$(subject_code)-en.tex.d, $(units)))

unit_figs_deps := $(addprefix $(depsdir)/unit-,\
	$(addsuffix _$(subject_code)-figs.d, $(unit_figs)))

all_deps := $(docs_deps) $(tex_deps) $(unit_figs_deps)

FIGURES :=

INCLUDEDEPS := yes

# Do not include dependency files if make goal is some kind of clean
ifneq (,$(findstring clean,$(MAKECMDGOALS)))
INCLUDEDEPS := no
endif

# $(call tex-wrapper,pres-or-hdout,tex-src) -> write to a file
define tex-wrapper
\PassOptionsToClass{$1}{unit}
\input{$2}
endef

# $(call tex-wrapper,spanish-or-english,fig-src) -> write to a file
define fig-wrapper
\documentclass[$1]{figure}
\begin{document}
\input{$2}
\end{document}
endef

hash := \#
$(hash) := \#

# $(paths-org) -> write to a file
define paths-org
$#+LATEX_HEADER: \graphicspath{{$(realpath $(figdir))/}{$(realpath $(imgdir))/}}
endef

vpath %.pdf $(figdir)
vpath %.png $(imgdir)
vpath %.jpg $(imgdir)

## Rules
## ================================================================================

all: $(docs_pdf)

# org to latex
.PRECIOUS: $(builddir)/%.tex
$(builddir)/%.tex: $(rootdir)/%.org | $(rootdir)/paths.org $(builddir)
	$(EMACS) $(emacs_loads) --visit=$< $(org_to_latex)

# dependencies for latex file
$(depsdir)/%.tex.d: $(rootdir)/%.org | $(rootdir)/paths.org $(depsdir)
	$(MAKEORGDEPS) -o $@ -t $(builddir)/$*.tex $<



# latex wrappers
.PRECIOUS: $(builddir)/pres-%.tex
.PRECIOUS: $(builddir)/hdout-%.tex
$(builddir)/pres-%.tex $(builddir)/hdout-%.tex: $(builddir)/unit-%.tex
	$(file > $(builddir)/pres-$*.tex,\
		$(call tex-wrapper,Presentation,$(realpath $(builddir))/unit-$*))
	$(file > $(builddir)/hdout-$*.tex,\
		$(call tex-wrapper,Handout,$(realpath $(builddir))/unit-$*))

## latex to pdf
$(outdir)/%.pdf: $(builddir)/%.tex | $(outdir)
	$(TEXI2DVI) --output=$@ $<

# pdf dependencies
$(depsdir)/%.pdf.d: $(builddir)/%.tex | $(outdir) $(depsdir)
	$(MAKETEXDEPS) -o $@ -t $(outdir)/$*.pdf $<

# figure wrappers
.PRECIOUS: $(builddir)/fig-%-en.tex
.PRECIOUS: $(builddir)/fig-%-es.tex
$(builddir)/fig-%-en.tex $(builddir)/fig-%-es.tex: $(builddir)/fig-%.tex
	$(file > $(builddir)/fig-$*-en.tex,\
		$(call fig-wrapper,English,$(realpath $(builddir))/fig-$*))
	$(file > $(builddir)/fig-$*-es.tex,\
		$(call fig-wrapper,Spanish,$(realpath $(builddir))/fig-$*))

# figure latex to pdf
$(figdir)/fig-%.pdf: $(builddir)/fig-%.tex | $(figdir)
	$(TEXI2DVI) --output=$@ $<

# paths to media files
$(rootdir)/paths.org: | $(figdir)
	$(file > $@,$(paths-org))


$(depsdir)/unit-%-figs.d: unit-%-figs.org | $(depsdir)
	$(MAKEFIGDEPS) -o $@ $<


## automatic dependencies
ifeq ($(INCLUDEDEPS),yes)
include $(all_deps)
endif

## Auxiliary directories
## --------------------------------------------------------------------------------

$(outdir):
	mkdir $(outdir)

$(builddir):
	mkdir $(builddir)

$(depsdir):
	mkdir $(depsdir)

$(figdir):
	mkdir $(figdir)

## Cleaning rules
## --------------------------------------------------------------------------------

.PHONY: clean
clean:
	-@rm -rf $(figdir)
	-@rm -rf $(builddir)
	-@rm -rf $(depsdir)
	-@rm -f $(rootdir)/paths.org

.PHONY: veryclean
veryclean: clean
	-@rm -rf $(outdir)
