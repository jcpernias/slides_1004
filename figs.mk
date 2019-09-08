unit-1B_1004-figs.d: unit-1B_1004-figs.org

$(builddir)/fig-1B_1004-tab_fpp1.tex \
$(builddir)/fig-1B_1004-prod.tex \
$(builddir)/fig-1B_1004-prod2.tex \
$(builddir)/fig-1B_1004-tab_fpp2.tex \
$(builddir)/fig-1B_1004-fpp1.tex \
$(builddir)/fig-1B_1004-fpp2a.tex \
$(builddir)/fig-1B_1004-fpp1a.tex \
$(builddir)/fig-1B_1004-fpp2.tex \
$(builddir)/fig-1B_1004-fpp3a.tex \
$(builddir)/fig-1B_1004-fpp3.tex \
$(builddir)/fig-1B_1004-fpp4.tex \
$(builddir)/fig-1B_1004-fpp5.tex \
$(builddir)/fig-1B_1004-tab_fpp3.tex \
$(builddir)/fig-1B_1004-fpp6.tex \
$(builddir)/fig-1B_1004-fpp7.tex \
$(builddir)/fig-1B_1004-gr2.tex \
$(builddir)/fig-1B_1004-gr3.tex \
$(builddir)/fig-1B_1004-gr1.tex: unit-1B_1004-figs.intermediate ;

.INTERMEDIATE: unit-1B_1004-figs.intermediate
unit-1B_1004-figs.intermediate: unit-1B_1004-figs.org
	$(EMACS) $(emacs_loads) --visit=$< $(tangle)
