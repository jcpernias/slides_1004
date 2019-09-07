SHELL := /bin/sh

subject_code := 1004
units := 1A 1B # 1C 1D 1E

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

docs_es := $(addsuffix _$(subject_code)-es, \
	$(addprefix hdout-, $(units)) $(addprefix pres-, $(units)))
docs_en := $(addsuffix _$(subject_code)-en, \
	$(addprefix hdout-, $(units)) $(addprefix pres-, $(units)))

docs_base := $(docs_es) $(docs_en)
docs_pdf := $(addprefix $(outdir)/, $(addsuffix .pdf, $(docs_base)))

real_rootdir := $(realpath $(rootdir))
tex_check_dirs := $(rootdir)/paths.org $(builddir) $(depsdir)

## Automatic dependencies
## ================================================================================
docs_deps := $(addprefix $(depsdir)/, \
	$(addsuffix .tex.d, $(docs_base)) \
	$(addsuffix .pdf.d, $(docs_base)))

INCLUDEDEPS := yes

# Do not include dependency files if make goal is some kind of clean
ifneq (,$(findstring clean,$(MAKECMDGOALS)))
INCLUDEDEPS := no
endif

# Do not include dependency files in dry runs
ifneq (,$(findstring n,$(MAKEFLAGS)))
INCLUDEDEPS := no
endif


# $(call tex-wrapper,pres-or-hdout,tex-src) -> write to a file
define tex-wrapper
\PassOptionsToClass{$1}{unit}
\RequirePackage{import}
\import{$(real_rootdir)/}{$2}
endef

hash := \#
$(hash) := \#

# $(paths-org) -> write to a file
define paths-org
$#+LATEX_HEADER: \newcommand*{\rootdir}{$(real_rootdir)}
$#+LATEX_HEADER: \graphicspath{{\rootdir/img/}{\rootdir/figures/}}
endef

# $(call fls-file,basename)
define fls-file
$(builddir)/pdf!$1.t2d/pdf/build/$1.fls
endef

## Rules
## ================================================================================

all: $(docs_pdf)

## org to latex
.PRECIOUS: $(builddir)/%.tex
.PRECIOUS: $(builddir)/unit-%.tex
.PRECIOUS: $(builddir)/pres-%.tex
.PRECIOUS: $(builddir)/hdout-%.tex

$(builddir)/unit-%.tex $(depsdir)/unit-%.tex.d: $(rootdir)/unit-%.org | $(tex_check_dirs)
	$(EMACS) $(emacs_loads) --visit=$< $(org_to_beamer)
	$(MAKEORGDEPS) -o $(depsdir)/unit-$*.tex.d -t $(builddir)/unit-$*.tex $<

$(builddir)/pres-%.tex $(builddir)/hdout-%.tex: $(builddir)/unit-%.tex
	$(file > $(builddir)/pres-$*.tex,$(call tex-wrapper,Presentation,$<))
	$(file > $(builddir)/hdout-$*.tex,$(call tex-wrapper,Handout,$<))

$(rootdir)/paths.org:
	$(file > $@,$(paths-org))

$(builddir)/%.tex $(depsdir)/%.tex.d: $(rootdir)/%.org | $(tex_check_dirs)
	$(EMACS) $(emacs_loads) --visit=$< $(org_to_latex)
	$(MAKEORGDEPS) -o $(depsdir)/$*.tex.d -t $(builddir)/$*.tex $<

## latex to pdf
$(outdir)/%.pdf $(depsdir)/%.pdf.d: $(builddir)/%.tex | $(outdir) $(depsdir)
	$(TEXI2DVI) --output=$(outdir)/$*.pdf $<
	$(MAKETEXDEPS) -o $(depsdir)/$*.pdf.d -t $< $(call fls-file,$*)


## automatic dependencies
ifeq ($(INCLUDEDEPS),yes)
-include $(docs_deps)
endif

include figs.mk


## Auxiliary directories
## --------------------------------------------------------------------------------

$(outdir):
	mkdir $(outdir)

$(builddir):
	mkdir $(builddir)

$(depsdir):
	mkdir $(depsdir)

## Cleaning rules
## --------------------------------------------------------------------------------

.PHONY: clean
clean:
	-@rm -rf $(builddir)
	-@rm -rf $(depsdir)
	-@rm -f $(rootdir)/paths.org

.PHONY: veryclean
veryclean: clean
	-@rm -rf $(outdir)
