#--------------------------------------------------------------#
TOP=.
OUTPUT?=./output
include $(OUTPUT)/rules.mk
#--------------------------------------------------------------#

#CONFIG_H_FILE:=include/TCore/tdcore_config.h

EXENAMEP:=test_main

EXESRCS := src/test_main.cpp src/sfh_string.cpp


all: $(EXENAMEP)

clean: rules_clean

install: all rules_install

#--------------------------------------------------------------#
include $(OUTPUT)/rules.mk
#--------------------------------------------------------------#

