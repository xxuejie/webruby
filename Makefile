# Makefile for webruby
# Now that we use minirake as mruby, now this is only a wrapper around it.

RAKE = ruby ./modules/mruby/minirake

.PHONY : all
all :
	$(RAKE)

.PHONY : html
html:
	$(RAKE) html

.PHONY : mruby_test
mrbtest :
	$(RAKE) mrbtest

.PHONY : clean
clean :
	$(RAKE) clean
