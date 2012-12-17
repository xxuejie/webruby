# Makefile for webruby application source code

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
MRB_DIR := ../modules/mruby
MRB_SRC_DIR := $(MRB_DIR)/src
MRB_LIB := $(MRB_DIR)/lib/libmruby.a
MRB_MRBC := $(MRB_DIR)/bin/mrbc

# libraries, includes
INCLUDES = -I$(MRB_SRC_DIR) -I$(MRB_SRC_DIR)/../include

##############################
# generic build targets, rules

.PHONY : all
all : js

.PHONY : js
js : $(JS_EXECUTABLE)

$(JS_EXECUTABLE) : $(OBJ_MAIN)
	$(LL) $(ALL_CFLAGS) $(OBJ_MAIN) $(MRB_LIB) -o $@

.PHONY : webpage
webpage : $(OBJ_MAIN)
	$(LL) $(ALL_CFLAGS) $(OBJ_MAIN) $(MRB_LIB) -o $(WEBPAGE)

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
