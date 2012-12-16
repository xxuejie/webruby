# Makefile description.
# Build JavaScript module from mruby source code and link
# it against our provided source code including the main function

export EMSCRIPTEN_PATH = ./modules/emscripten
export CC = $(EMSCRIPTEN_PATH)/emcc
export LL = $(EMSCRIPTEN_PATH)/emcc

BUILD_DIR := ./build
MRUBY_PATH := ./modules/mruby

# mruby files
MRUBY_TEST_TARGET := $(BUILD_DIR)/mrbtest.js
MRUBY_LIB := $(BUILD_DIR)/libmruby.a
MRBC := $(BUILD_DIR)/mrbc
MRUBY_FILES := $(MRUBY_LIB) $(MRBC) $(BUILD_DIR)/last-commit.txt

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
MRUBY_SRC_DIR := $(MRUBY_PATH)/src
INCLUDES = -I$(MRUBY_SRC_DIR) -I$(MRUBY_SRC_DIR)/../include

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

##############################
# generic build targets, rules

.PHONY : all
all : js

.PHONY : js
js : $(JS_EXECUTABLE)

# NOTE: current version of emscripten would emit an exception if we
# use -O1 or -O2 here
$(JS_EXECUTABLE) : $(MRUBY_LIB) $(OBJ_MAIN)
	$(LL) $(ALL_CFLAGS) $(OBJ_MAIN) $(MRUBY_LIB) -o $@

.PHONY : webpage
webpage : $(MRUBY_LIB) $(OBJ_MAIN)
	$(LL) $(ALL_CFLAGS) $(OBJ_MAIN) $(MRUBY_LIB) -o $(WEBPAGE)

$(OBJ_MAIN) : $(SRC_MAIN)
	$(CC) $(ALL_CFLAGS) -MMD $(INCLUDES) -c $< -o $@

$(SRC_MAIN) : $(SRC_CTMP) $(SRC_DRIVER)
	cat $(SRC_DRIVER) $(SRC_CTMP) > $(SRC_MAIN)

$(SRC_CTMP) : $(SRC_RBTMP) $(MRBC)
	$(MRBC) -Bapp_irep -o$@ $(SRC_RBTMP)

# entrypoint file comes last
$(SRC_RBTMP) : $(SRC_ENTRYPOINT) $(SRC_REST)
	cat $(SRC_REST) $(SRC_ENTRYPOINT) > $(SRC_RBTMP)

$(MRUBY_LIB) : mruby

$(MRBC) : mruby

# mruby build, this target would generate 3 different files:
# build/mrbc, build/libmruby.so and build/last-commit.txt
# We put them in a single target for simplicity
.PHONY : mruby
mruby :
	@./scripts/rebuild_mruby_module

# mruby tests. Note this is the test for mruby itself running
# in JavaScript. It should only used by developers of webruby.
# It does not test the mruby code!
.PHONY : mruby-test
mruby-test :
	@./scripts/rebuild_mruby_module test
	@echo "Running mruby test in Node.js!"
	node $(MRUBY_TEST_TARGET)

# clean up
.PHONY : clean
clean :
	rm -f $(JS_EXECUTABLE) $(WEBPAGE)
	rm -f $(OBJ_MAIN) $(SRC_MAIN) $(SRC_CTMP) $(SRC_RBTMP)
	rm -f $(MRUBY_TEST_TARGET) $(MRUBY_FILES)
	make -C $(MRUBY_PATH) clean
