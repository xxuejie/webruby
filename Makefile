# Makefile description.
# Build JavaScript module from mruby source code and link
# it against our provided source code including the main function

BASE_DIR := $(realpath .)

export EMSCRIPTEN_DIR = $(BASE_DIR)/modules/emscripten
export CC = $(EMSCRIPTEN_DIR)/emcc
export LL = $(EMSCRIPTEN_DIR)/emcc
export AR = $(EMSCRIPTEN_DIR)/emar

BUILD_DIR := ./build

MRB_DIR := ./modules/mruby
MRB_SRC_DIR := $(MRB_DIR)/src
MRB_MRBC_DIR := $(MRB_DIR)/tools/mrbc
MRB_LIB_DIR := $(MRB_DIR)/mrblib
MRB_TEST_DIR := $(MRB_DIR)/test

# mruby files
MRB_TEST_TARGET := $(BASE_DIR)/$(BUILD_DIR)/mrbtest.js

MRB_CORE_LIB := $(MRB_DIR)/lib/libmruby_core.a
MRB_LIB := $(MRB_DIR)/lib/libmruby.a
MRB_MRBC := $(MRB_DIR)/bin/mrbc
MRB_MRBC_JS := $(MRB_DIR)/bin/mrbc.js

# mrbgems settings
ifeq ($(strip $(ENABLE_GEMS)),)
  # by default GEMs are deactivated
  ENABLE_GEMS = false
endif

ifeq ($(strip $(ACTIVE_GEMS)),)
  # the default file which contains the active GEMs
  ACTIVE_GEMS = GEMS.active
endif

# Note: we found that when compiling mruby using double,
# the unit test String#to_f [15.2.10.5.39] would fail, since
# according to v8, the difference between 123456789 and
# 123456789.0 is 1.4901161193848e-08, which is larger than
# 1E-12. So until we found a way to work around this(this may
# due to the generated js code or the problem with v8, we
# just cannot tell which is the reason for now), we have
# to compile mruby in float mode here.
ALL_CFLAGS = -Werror-implicit-function-declaration \
	-DMRB_USE_FLOAT

# NOTE: current version of emscripten would emit an exception if we
# use -O1 or -O2 optimizations, so we do not add any link flags here.
MRB_GENERAL_FLAGS = CC=$(CC) LL=$(LL) AR=$(AR) CP=cp CAT=cat ALL_CFLAGS='$(ALL_CFLAGS)' ENABLE_GEMS='$(ENABLE_GEMS)' ACTIVE_GEMS='$(ACTIVE_GEMS)'

MRB_MAKE_FLAGS = $(MRB_GENERAL_FLAGS)

# one test case in exception.rb tests the case of a very
# deeply recursive function, which needs a lot of memory
MRB_TEST_FLAGS = $(MRB_GENERAL_FLAGS) LDFLAGS='-s ALLOW_MEMORY_GROWTH=1'


##############################
# generic build targets, rules

.PHONY : all
all:
	make -C $(MRB_SRC_DIR) $(MRB_MAKE_FLAGS)
	make -q -C $(MRB_MRBC_DIR) $(MRB_MAKE_FLAGS) EXE=$(BASE_DIR)/$(MRB_MRBC_JS) || (cp scripts/mrbc $(MRB_MRBC) && touch $(MRB_MRBC))
	make -C $(MRB_MRBC_DIR) $(MRB_MAKE_FLAGS) EXE=$(BASE_DIR)/$(MRB_MRBC_JS)
	make -C $(MRB_LIB_DIR) $(MRB_MAKE_FLAGS)
	make -C src $(MRB_GENERAL_FLAGS)

.PHONY : webpage
webpage: all
	make -C src webpage $(MRB_GENERAL_FLAGS)

# Note this is the test for mruby itself running in JavaScript.
# Normally it shall only be useful for developers of webruby.
# It does not test the actual mruby code in src folder!
.PHONY : mruby-test
mruby-test : all
	make -C $(MRB_TEST_DIR) $(MRB_TEST_FLAGS) EXE=$(MRB_TEST_TARGET) $(MRB_TEST_TARGET)
	@echo "Running mruby test in Node.js!"
	node $(MRB_TEST_TARGET)

# clean up
.PHONY : clean
clean :
	rm -f $(MRB_TEST_TARGET) $(MRB_MRBC_JS)
	make -C src clean $(MRB_MAKE_FLAGS)
	make -C $(MRB_DIR) clean $(MRB_MAKE_FLAGS)
