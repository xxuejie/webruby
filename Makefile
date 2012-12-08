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

BUILD_DIR := ./build

# mruby settings
MRUBY_PATH := ./modules/mruby
MRBLIB_PATH := $(MRUBY_PATH)/mrblib

MRUBY_SRC_DIR := $(MRUBY_PATH)/src
MRUBY_BUILD_DIR := $(BUILD_DIR)/mruby/src

MRUBY_LIB := $(MRUBY_BUILD_DIR)/libruby.so

MRBLIBC := $(MRBLIB_PATH)/mrblib.c
YC := $(MRUBY_SRC_DIR)/y.tab.c
EXCEPT1 := $(YC) $(MRUBY_SRC_DIR)/minimain.c
MRUBY_OBJY := $(patsubst $(MRUBY_SRC_DIR)/%.c,$(MRUBY_BUILD_DIR)/%.o,$(YC))
MRBLIB_OBJ := $(patsubst $(MRBLIB_PATH)/%.c,$(MRUBY_BUILD_DIR)/%.o,$(MRBLIBC))
MRUBY_OBJS := $(patsubst $(MRUBY_SRC_DIR)/%.c,$(MRUBY_BUILD_DIR)/%.o,$(filter-out $(EXCEPT1),$(wildcard $(MRUBY_SRC_DIR)/*.c)))

# mruby js tests
MRUBY_TEST_SRC_DIR := $(MRUBY_PATH)/test
MRUBY_TEST_BUILD_DIR := $(BUILD_DIR)/mruby/test

MRUBY_CLIB_SRC := $(MRUBY_TEST_SRC_DIR)/mrbtest.c
MRUBY_TEST_SRC := $(MRUBY_CLIB_SRC) $(MRUBY_TEST_SRC_DIR)/driver.c

MRUBY_TEST_OBJS := $(patsubst $(MRUBY_TEST_SRC_DIR)/%.c,$(MRUBY_TEST_BUILD_DIR)/%.o,$(MRUBY_TEST_SRC))

TEST_TARGET := $(BUILD_DIR)/mruby-test.js

# sources
SRC_DIR := ./src

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

# Note: we found that when compiling mruby using double,
# the unit test String#to_f [15.2.10.5.39] would fail, since
# according to v8, the difference between 123456789 and
# 123456789.0 is 1.4901161193848e-08, which is larger than
# 1E-12. So until we found a way to work around this(this may
# due to the generated js code or the problem with v8, we
# just cannot tell which is the reason for now), we have
# to compile mruby in float mode here.
ALL_CFLAGS = -Werror-implicit-function-declaration \
	-DMRB_USE_FLOAT \
	-DMRB_USE_EXCEPTION -Wno-write-strings \
	-s EXCEPTION_DEBUG=0 \
	-s ALLOW_MEMORY_GROWTH=1
# TODO: test why we need to allow memory growth

##############################
# generic build targets, rules

.PHONY : all
all : js

.PHONY : js
js : $(JS_EXECUTABLE)

# NOTE: current version of emscripten would emit an exception if we
# use -O1 or -O2 here
$(JS_EXECUTABLE) : $(MRUBY_LIB) $(OBJS)
	$(LL) $(ALL_CFLAGS) $(MRUBY_LIB) $(OBJS) -o $@

.PHONY : webpage
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
$(YC) : mruby

# mrblib.c compile
$(MRBLIBC) : mruby

# mruby build
.PHONY : mruby
mruby :
	@(cd $(MRUBY_PATH); make)

# apply patches to mruby
.PHONY : applypatch
applypatch :
ifneq ($(PATCHES),)
	@(cd $(MRUBY_PATH) && git reset --hard && git apply $(PATCH_DIR)/*.patch && make clean)
else
	@echo "No patches needed to apply!"
endif

# tests
.PHONY : test
test: $(TEST_TARGET)
	@echo "Running mruby test in Node.js!"
	node $(TEST_TARGET)

$(TEST_TARGET) : $(MRUBY_TEST_OBJS) $(MRUBY_LIB)
	$(LL) $(ALL_CFLAGS) $(MRUBY_TEST_OBJS) $(MRUBY_LIB) -o $(TEST_TARGET)

$(MRUBY_TEST_BUILD_DIR)/%.o : $(MRUBY_TEST_SRC_DIR)/%.c
	$(CC) $(ALL_CFLAGS) -MMD $(INCLUDES) -c $< -o $@

$(MRUBY_CLIB_SRC):
	@(cd $(MRUBY_PATH); make test)

# clean up
.PHONY : clean
clean :
	rm -f $(MRUBY_OBJS) $(MRUBY_OBJY) $(MRBLIB_OBJ) $(MRUBY_LIB)
	rm -f $(JS_EXECUTABLE) $(WEBPAGE) $(OBJS)
	rm -f $(TEST_TARGET) $(MRUBY_TEST_OBJS)
	cd $(MRUBY_PATH); make clean
