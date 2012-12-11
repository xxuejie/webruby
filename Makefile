# Makefile description.
# Build JavaScript module from mruby source code and link
# it against our provided source code including the main function
# This Makefile is inspired from the mruby Makefile

# TODO: This makefile has gone too big, it contains several
# different parts:
# 1. normal mruby compiling for generated c files
# 2. emscripten mruby compiling
# 3. emscripten mruby tests
# 4. source code compiling and final linking
# mruby and emscripten reside in separate modules, so if we
# split mruby compiling part, we may result in a folder with
# only a Makefile(is this a good practice?). We may want to
# come back to this later for a better directory structure.

# compiler, linker, archiver path
export EMSCRIPTEN_PATH = ./modules/emscripten
export CC = $(EMSCRIPTEN_PATH)/emcc
export LL = $(EMSCRIPTEN_PATH)/emcc
export AR = $(EMSCRIPTEN_PATH)/emcc

export RM_F := rm -f
export CAT := cat

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

MRBC := $(MRUBY_PATH)/bin/mrbc

# mruby js tests
MRUBY_TEST_SRC_DIR := $(MRUBY_PATH)/test
MRUBY_TEST_BUILD_DIR := $(BUILD_DIR)/mruby/test

MRUBY_CLIB_SRC := $(MRUBY_TEST_SRC_DIR)/mrbtest.c
MRUBY_TEST_SRC := $(MRUBY_CLIB_SRC) $(MRUBY_TEST_SRC_DIR)/driver.c

MRUBY_TEST_OBJS := $(patsubst $(MRUBY_TEST_SRC_DIR)/%.c,$(MRUBY_TEST_BUILD_DIR)/%.o,$(MRUBY_TEST_SRC))

TEST_TARGET := $(BUILD_DIR)/mruby-test.js

# sources
SRC_DIR := ./src
SRC_ENTRYPOINT := $(SRC_DIR)/app.rb
SRC_REST := $(filter-out $(SRC_ENTRYPOINT),$(wildcard $(SRC_DIR)/*.rb))
SRC_DRIVER := $(SRC_DIR)/driver.c

SRC_RBTMP := $(BUILD_DIR)/rbcode.rb
SRC_CTMP := $(BUILD_DIR)/rbcode.c
SRC_MAIN := $(BUILD_DIR)/main.c
OBJ_MAIN := $(BUILD_DIR)/main.o

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
	-DMRB_USE_FLOAT

# one test case in exception.rb tests the case of a very
# deeply recursive function, which needs a lot of memory
TEST_FLAGS = -s ALLOW_MEMORY_GROWTH=1

##############################
# generic build targets, rules

.PHONY : all
all : js

.PHONY : js
js : $(JS_EXECUTABLE)

# NOTE: current version of emscripten would emit an exception if we
# use -O1 or -O2 here
$(JS_EXECUTABLE) : $(MRUBY_LIB) $(OBJ_MAIN)
	$(LL) $(ALL_CFLAGS) $(MRUBY_LIB) $(OBJ_MAIN) -o $@

.PHONY : webpage
webpage : $(MRUBY_LIB) $(OBJ_MAIN)
	$(LL) $(ALL_CFLAGS) $(MRUBY_LIB) $(OBJ_MAIN) -o $(WEBPAGE)

$(OBJ_MAIN) : $(SRC_MAIN)
	$(CC) $(ALL_CFLAGS) -MMD $(INCLUDES) -c $< -o $@

$(SRC_MAIN) : $(SRC_CTMP) $(SRC_DRIVER)
	$(CAT) $(SRC_DRIVER) $(SRC_CTMP) > $(SRC_MAIN)

$(SRC_CTMP) : $(SRC_RBTMP) $(MRBC)
	$(MRBC) -Bapp_irep -o$@ $(SRC_RBTMP)

# entrypoint file comes last
$(SRC_RBTMP) : $(SRC_ENTRYPOINT) $(SRC_REST)
	$(CAT) $(SRC_REST) $(SRC_ENTRYPOINT) > $(SRC_RBTMP)

############################
# mruby build targets, rules

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

# mrbc binary(used for compiling mruby source code into bytecode)
$(MRBC) : mruby

# mruby build
.PHONY : mruby
mruby :
	@(cd $(MRUBY_PATH); make)

# mruby tests
.PHONY : test
test: $(TEST_TARGET)
	@echo "Running mruby test in Node.js!"
	node $(TEST_TARGET)

$(TEST_TARGET) : $(MRUBY_TEST_OBJS) $(MRUBY_LIB)
	$(LL) $(ALL_CFLAGS) $(TEST_FLAGS) $(MRUBY_TEST_OBJS) $(MRUBY_LIB) -o $(TEST_TARGET)

$(MRUBY_TEST_BUILD_DIR)/%.o : $(MRUBY_TEST_SRC_DIR)/%.c
	$(CC) $(ALL_CFLAGS) -MMD $(INCLUDES) -c $< -o $@

$(MRUBY_CLIB_SRC):
	@(cd $(MRUBY_PATH); make test)

# clean up
.PHONY : clean
clean :
	$(RM_F) $(MRUBY_OBJS) $(MRUBY_OBJY) $(MRBLIB_OBJ) $(MRUBY_LIB)
	$(RM_F) $(JS_EXECUTABLE) $(WEBPAGE)
	$(RM_F) $(OBJ_MAIN) $(SRC_MAIN) $(SRC_CTMP) $(SRC_RBTMP)
	$(RM_F) $(TEST_TARGET) $(MRUBY_TEST_OBJS)
	cd $(MRUBY_PATH); make clean
