# Makefile for webruby
# Now that we use minirake as mruby, now this is only a wrapper around it.

RAKE = ruby ./modules/mruby/minirake
# mrbgems settings
ifeq ($(strip $(ENABLE_GEMS)),)
  # by default GEMs are deactivated
  ENABLE_GEMS = false
endif

ACTIVE_GEMS = $(realpath ./GEMS.active)

.PHONY : all
all :
	ENABLE_GEMS=$(ENABLE_GEMS) ACTIVE_GEMS=$(ACTIVE_GEMS) $(RAKE)

.PHONY : mruby_test
mruby_test :
	ENABLE_GEMS=$(ENABLE_GEMS) ACTIVE_GEMS=$(ACTIVE_GEMS) $(RAKE) mruby_test

.PHONY : clean
clean :
	ENABLE_GEMS=$(ENABLE_GEMS) ACTIVE_GEMS=$(ACTIVE_GEMS) $(RAKE) clean
