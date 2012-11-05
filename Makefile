# Makefile description.
# build JavaScript module from mruby source code
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

# project-specific macros
MRUBY_PATH := ./modules/mruby
MRBLIB_PATH := $(MRUBY_PATH)/mrblib

SRCDIR := $(MRUBY_PATH)/src
BUILDDIR := ./build

TARGET := $(BUILDDIR)/libruby.so
JS_TARGET := $(BUILDDIR)/libruby.js

MRBLIBC := $(MRBLIB_PATH)/mrblib.c
YC := $(SRCDIR)/y.tab.c
EXCEPT1 := $(YC) $(SRCDIR)/minimain.c
OBJY := $(patsubst $(SRCDIR)/%.c,$(BUILDDIR)/%.o,$(YC))
OBJ_MRBLIB := $(patsubst $(MRBLIB_PATH)/%.c,$(BUILDDIR)/%.o,$(MRBLIBC))
OBJS := $(patsubst $(SRCDIR)/%.c,$(BUILDDIR)/%.o,$(filter-out $(EXCEPT1),$(wildcard $(SRCDIR)/*.c)))

# libraries, includes
INCLUDES = -I$(SRCDIR) -I$(SRCDIR)/../include

ifeq ($(strip $(COMPILE_MODE)),)
  # default compile option
  COMPILE_MODE = debug
endif

ifeq ($(COMPILE_MODE),debug)
  JSFLAGS =
  CFLAGS = -g
else ifeq ($(COMPILE_MODE),release)
  JSFLAGS = -O2
else ifeq ($(COMPILE_MODE),small)
  JSFLAGS = -Os
endif

ALL_CFLAGS = -Wall -Werror-implicit-function-declaration $(CFLAGS)


##############################
# generic build targets, rules

.PHONY : all
all : $(JS_TARGET)

$(JS_TARGET) : $(TARGET)
	$(CC) $(JSFLAGS) $< -o $@

# shared library, we create a .so file instead of .a due to emscripten's
# recommendations
$(TARGET) : $(OBJS) $(OBJY) $(OBJ_MRBLIB)
	$(CC) -shared -o $@ $(OBJS) $(OBJY) $(OBJ_MRBLIB)

# TODO: fix this later, currently .o files and .d files are not in the
# same directory
# -include $(OBJS:.o=.d) $(OBJY:.o=.d)

# objects compiled from source
$(BUILDDIR)/%.o : $(SRCDIR)/%.c
	$(CC) $(ALL_CFLAGS) -MMD $(INCLUDES) -c $< -o $@

# parser compile
$(OBJY) : $(YC)
	$(CC) $(ALL_CFLAGS) -MMD $(INCLUDES) -c $(YC) -o $(OBJY)

# mruby library compile
$(OBJ_MRBLIB): $(MRBLIBC)
	$(CC) $(ALL_CFLAGS) -MMD $(INCLUDES) -c $(MRBLIBC) -o $(OBJ_MRBLIB)

# yacc compile
$(YC) :
	@(cd $(MRUBY_PATH); make)

# mrblib.c compile
$(MRBLIBC) :
	@(cd $(MRUBY_PATH); make)

# clean up
.PHONY : clean #cleandep
clean :
	rm -f $(OBJS) $(OBJY) $(OBJ_MRBLIB) $(TARGET) $(JS_TARGET)
