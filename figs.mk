$(builddir)/unit-1B-tab-fpp1.tex \
$(builddir)/unit-1B-fig-prod.tex \
$(builddir)/unit-1B-fig-prod2.tex \
$(builddir)/unit-1B-tab-fpp2.tex \
$(builddir)/unit-1B-fig-fpp1.tex \
$(builddir)/unit-1B-fig-fpp2a.tex \
$(builddir)/unit-1B-fig-fpp1a.tex \
$(builddir)/unit-1B-fig-fpp2.tex \
$(builddir)/unit-1B-fig-fpp3a.tex \
$(builddir)/unit-1B-fig-fpp3.tex \
$(builddir)/unit-1B-fig-fpp4.tex \
$(builddir)/unit-1B-fig-fpp5.tex \
$(builddir)/unit-1B-tab-fpp3.tex \
$(builddir)/unit-1B-fig-fpp6.tex \
$(builddir)/unit-1B-fig-fpp7.tex \
$(builddir)/unit-1B-fig-gr2.tex \
$(builddir)/unit-1B-fig-gr3.tex \
$(builddir)/unit-1B-fig-gr1.tex: unit-1B_1004-figs.intermediate ;

.INTERMEDIATE: unit-1B_1004-figs.intermediate
unit-1B_1004-figs.intermediate: unit-1B_1004-figs.org
	$(EMACS) $(emacs_loads) --visit=$< $(tangle)
