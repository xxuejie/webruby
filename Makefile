# Makefile description.
# Build JavaScript module from mruby source code and link
# it against our provided source code including the main function
# This Makefile is inspired from the mruby Makefile

# compiler, linker, archiver path
export EMSCRIPTEN_PATH = ./modules/emscripten
export CC = $(EMSCRIPTEN_PATH)/emcc
export LL = $(EMSCRIPTEN_PATH)/emcc
export AR = $(EMSCRIPTEN_PATH)/emcc

# TODO: Due to the different compiler/linker/archiver options,
# now we leave to mruby itself to generate src/y.tab.c and
# mrblib/mrblib.c. But the disadvantage of this is that we need
# to build mruby first. What's more, these two files are
# temporary files and may be removed when build is finished in later
# versions of mruby. We will come back to this later.

# mruby settings
MRUBY_PATH := ./modules/mruby
MRBLIB_PATH := $(MRUBY_PATH)/mrblib

MRUBY_SRC_DIR := $(MRUBY_PATH)/src
MRUBY_BUILD_DIR := ./build/mruby

MRUBY_LIB := $(MRUBY_BUILD_DIR)/libruby.so

MRBLIBC := $(MRBLIB_PATH)/mrblib.c
YC := $(MRUBY_SRC_DIR)/y.tab.c
EXCEPT1 := $(YC) $(MRUBY_SRC_DIR)/minimain.c
MRUBY_OBJY := $(patsubst $(MRUBY_SRC_DIR)/%.c,$(MRUBY_BUILD_DIR)/%.o,$(YC))
MRBLIB_OBJ := $(patsubst $(MRBLIB_PATH)/%.c,$(MRUBY_BUILD_DIR)/%.o,$(MRBLIBC))
MRUBY_OBJS := $(patsubst $(MRUBY_SRC_DIR)/%.c,$(MRUBY_BUILD_DIR)/%.o,$(filter-out $(EXCEPT1),$(wildcard $(MRUBY_SRC_DIR)/*.c)))

# sources
SRC_DIR := ./src
BUILD_DIR := ./build

PATCH_DIR := $(CURDIR)/patches
PATCHES := $(wildcard $(PATCH_DIR)/*.patch)

OBJS := $(patsubst $(SRC_DIR)/%.c,$(BUILD_DIR)/%.o,$(wildcard $(SRC_DIR)/*.c))

# final js executable(or html page)
JS_EXECUTABLE := $(BUILD_DIR)/mruby.js
WEBPAGE := $(BUILD_DIR)/mruby.html

# libraries, includes
INCLUDES = -I$(MRUBY_SRC_DIR) -I$(MRUBY_SRC_DIR)/../include

ifeq ($(strip $(COMPILE_MODE)),)
  # default compile option
  COMPILE_MODE = debug
endif

ifeq ($(COMPILE_MODE),debug)
  JSFLAGS =
else ifeq ($(COMPILE_MODE),release)
  JSFLAGS = -O2
else ifeq ($(COMPILE_MODE),small)
  JSFLAGS = -Os
endif

ALL_CFLAGS = -Wall -Werror-implicit-function-declaration

##############################
# generic build targets, rules

.PHONY : all
all : js

js : $(JS_EXECUTABLE)

# NOTE: current version of emscripten would emit an exception if we
# use -O1 or -O2 here
$(JS_EXECUTABLE) : $(MRUBY_LIB) $(OBJS)
	$(LL) $(ALL_CFLAGS) $(MRUBY_LIB) $(OBJS) -o $@

webpage : $(MRUBY_LIB) $(OBJS)
	$(LL) $(ALL_CFLAGS) $(MRUBY_LIB) $(OBJS) -o $(WEBPAGE)

# TODO: .d files handling
$(BUILD_DIR)/%.o : $(SRC_DIR)/%.c
	$(CC) $(ALL_CFLAGS) -MMD $(INCLUDES) -c $< -o $@

# shared library, we create a .so file instead of .a due to emscripten's
# recommendations
$(MRUBY_LIB) : $(MRUBY_OBJS) $(MRUBY_OBJY) $(MRBLIB_OBJ)
	$(AR) -shared -o $@ $(MRUBY_OBJS) $(MRUBY_OBJY) $(MRBLIB_OBJ)

# objects compiled from source
# TODO: include dependencies for .d files
$(MRUBY_BUILD_DIR)/%.o : $(MRUBY_SRC_DIR)/%.c
	$(CC) $(ALL_CFLAGS) -MMD $(INCLUDES) -c $< -o $@

# parser compile
$(MRUBY_OBJY) : $(YC)
	$(CC) $(ALL_CFLAGS) -MMD $(INCLUDES) -c $(YC) -o $(MRUBY_OBJY)

# mruby library compile
$(MRBLIB_OBJ): $(MRBLIBC)
	$(CC) $(ALL_CFLAGS) -MMD $(INCLUDES) -c $(MRBLIBC) -o $(MRBLIB_OBJ)

# yacc compile
$(YC) :
	@(cd $(MRUBY_PATH); make)

# mrblib.c compile
$(MRBLIBC) :
	@(cd $(MRUBY_PATH); make)

# apply patches to mruby
applypatch :
ifneq ($(PATCHES),)
	@(cd $(MRUBY_PATH) && git reset --hard && git apply $(PATCH_DIR)/*.patch && make clean)
else
	@echo "No patches needed to apply!"
endif

# clean up
.PHONY : clean
clean :
	rm -f $(MRUBY_OBJS) $(MRUBY_OBJY) $(MRBLIB_OBJ) $(MRUBY_LIB)
	rm -rf $(JS_EXECUTABLE) $(WEBPAGE) $(OBJS)
	cd $(MRUBY_PATH); make clean
