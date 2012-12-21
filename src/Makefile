# Makefile for webruby application source code

# We separate the two Makefile for two reasons:
# 1. Simplicty
# 2. mrbgems library files detection

MRUBY_ROOT := ../modules/mruby

ifeq ($(strip $(ENABLE_GEMS)),)
  # by default GEMs are deactivated
  ENABLE_GEMS = false
endif

ifeq ($(ENABLE_GEMS),false)
  GEM_ARCHIVE_FILES =
else
  MAKEFILE_GEM_LIST := $(MRUBY_ROOT)/mrbgems/g/MakefileGemList
  ifeq ($(wildcard $(MAKEFILE_GEM_LIST)),)
    GEM_ARCHIVE_FILES =
  else
    include $(MAKEFILE_GEM_LIST)
  endif
endif

BUILD_DIR := ../build

# sources
SRC_DIR := .
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

# mruby
MRB_SRC_DIR := $(MRUBY_ROOT)/src
MRB_LIB := $(MRUBY_ROOT)/lib/libmruby.a
MRB_MRBC := $(MRUBY_ROOT)/bin/mrbc

# libraries, includes
INCLUDES = -I$(MRB_SRC_DIR) -I$(MRB_SRC_DIR)/../include

##############################
# generic build targets, rules

.PHONY : js
js : $(JS_EXECUTABLE)

$(JS_EXECUTABLE) : $(OBJ_MAIN) $(MRB_LIB) $(GEM_ARCHIVE_FILES)
	$(LL) $(ALL_CFLAGS) $(OBJ_MAIN) $(MRB_LIB) $(GEM_ARCHIVE_FILES) -o $@

.PHONY : html
html : $(WEBPAGE)

$(WEBPAGE) : $(OBJ_MAIN) $(MRB_LIB) $(GEM_ARCHIVE_FILES)
	$(LL) $(ALL_CFLAGS) $(OBJ_MAIN) $(MRB_LIB) $(GEM_ARCHIVE_FILES) -o $(WEBPAGE)

$(OBJ_MAIN) : $(SRC_MAIN)
	$(CC) $(ALL_CFLAGS) -MMD $(INCLUDES) -c $< -o $@

$(SRC_MAIN) : $(SRC_CTMP) $(SRC_DRIVER)
	$(CAT) $(SRC_DRIVER) $(SRC_CTMP) > $(SRC_MAIN)

$(SRC_CTMP) : $(SRC_RBTMP)
	$(MRB_MRBC) -Bapp_irep -o$@ $(SRC_RBTMP)

# entrypoint file comes last
$(SRC_RBTMP) : $(SRC_ENTRYPOINT) $(SRC_REST)
	$(CAT) $(SRC_REST) $(SRC_ENTRYPOINT) > $(SRC_RBTMP)

# clean up
.PHONY : clean
clean :
	rm -f $(JS_EXECUTABLE) $(WEBPAGE)
	rm -f $(OBJ_MAIN) $(SRC_MAIN) $(SRC_CTMP) $(SRC_RBTMP)
