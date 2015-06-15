# zhangjie design
#########################################################################################
# OUTPUT: 上级配置目录,也是包含rule.mk的目录,该目录中有全局的编译配置文件config.mk
# CROSS: 交叉编译时的gcc前缀(默认没有)
# DEBUG: 编译是否带调试信息(默认没有，即编译优化版本-O3)
# EXTRACFLAGS: 额外的编译选项
# EXTRALDFLAGS: 额外的链接选项
# CPPFLAGS: 
# STATICLIB: 是否编译成静态库(默认没有，即编译成动态库)
# (建议都编译成动态库，因为静态库的函数属性__attribute__((constructor))在函数不使用时无效)
#
# TOP: 该软件包的顶层目录,该目录中有该软件包的默认配置文件def_config.mk文件，
# 该文件中可以定义一系列的XXXX1=y XXXX2=n ...等变量来配置编译过程，
# 并且可以定义CONFIG_H=XXXX1 XXXX2 ...来自动生成一个包含这些宏定义的头文件CONFIG_H_FILE
#
# PREFIX: 安装目录,如果没有定义，默认等于OUTPUT
#
# OUTPUT目录和TOP目录必须定义，内容可以相同
#
# CONFIG_H_FILE
#
# EXENAME
# EXESRCS
# EXECFLAGS
# EXELDFLAGS
#
# LIBNAME
# LIBSRCS
# LIBCFLAGS
# LIBLDFLAGS
# LIBVERSION
# LIBVERSION_SUB
#
# 在Makefile中首先定义OUTPUT目录和TOP目录
# 第一次包含rules.mk: 包含$(OUTPUT)/config.mk和$(TOP)/def_config.mk
# 第二次包含rules.mk: 根据EXENAME和LIBNAME 做编译安装的工作
# 变量总是先定义后使用，先确定变量的值再写依赖
#########################################################################################

ifeq ($(origin ALREADYFIRST),undefined)
#@@@@@@@@@@@@@@@@ 第一次包含rules.mk, 做默认配置的工作 @@@@@@@@@@@@@@@@@@@
ALREADYFIRST := Y

TOP := $(strip $(TOP))
ifeq ($(TOP),)
$(error "you are not set TOP dir")
endif
ifneq ($(shell if [ -d "$(TOP)" ]; then echo true; fi),true)
$(error "TOP directory $(TOP) does not exist")
endif
TOP := $(shell cd $(TOP) && /bin/pwd)

OUTPUT := $(strip $(OUTPUT))
ifeq ($(OUTPUT),)
$(error "you are not set OUTPUT directory")
endif
ifneq ($(shell if [ -d "$(OUTPUT)" ]; then echo true; fi),true)
$(error "OUTPUT directory $(OUTPUT) does not exist")
endif
OUTPUT := $(shell cd $(OUTPUT) && /bin/pwd)

PREFIX := $(strip $(PREFIX))
ifeq ($(PREFIX),)
PREFIX := $(OUTPUT)
else
ifneq ($(shell if [ -d "$(PREFIX)" ]; then echo true; fi),true)
$(error "PREFIX directory $(PREFIX) does not exist")
endif
PREFIX := $(shell cd $(PREFIX) && /bin/pwd)
endif

-include $(OUTPUT)/config.mk

-include $(TOP)/def_config.mk

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
else
#@@@@@@@@@@@@@ 第二次包含rules.mk,做编译安装的工作,一直到该文件尾 @@@@@@@@@

CC := $(CROSS)gcc
CCP := $(CROSS)g++
LD := $(CROSS)ld
AR := $(CROSS)ar
RANLIB := $(CROSS)ranlib
STRIP := $(CROSS)strip

EXEOBJS := $(patsubst %.c, %.o, $(EXESRCS))
LIBOBJS := $(patsubst %.c, %.lo, $(LIBSRCS))
EXEDEPS := $(patsubst %.c, %.d, $(EXESRCS))
LIBDEPS := $(patsubst %.c, %.d, $(LIBSRCS))

EXEOBJS := $(patsubst %.cpp, %.oo, $(EXEOBJS))
LIBOBJS := $(patsubst %.cpp, %.loo, $(LIBOBJS))
EXEDEPS := $(patsubst %.cpp, %.dd, $(EXEDEPS))
LIBDEPS := $(patsubst %.cpp, %.dd, $(LIBDEPS))



#GCOVFILES:=$(patsubst %.c, %.gc*, $(EXESRCS)) $(patsubst %.c, %.gc*, $(LIBSRCS)) $(patsubst %.c, %.c.gcov, $(EXESRCS)) $(patsubst %.c, %.c.gcov, $(LIBSRCS)) 

################################################

CFLAGS := -g -O2 -DUNIV_LINUX -DUNIV_LINUX
LDFLAGS := 

ifeq ($(DEBUG),Y)
CFLAGS += -DTD_DEBUG -O0 -ggdb3
#CFLAGS += -pg -fprofile-arcs -ftest-coverage
#LDFLAGS += -pg -fprofile-arcs -ftest-coverage
else
CFLAGS += -DNDEBUG -O3 -fomit-frame-pointer
endif

EXTRACFLAGS := -I$(TOP)/include -I$(OUTPUT)/include $(EXTRACFLAGS)
EXTRALDFLAGS := -L$(TOP)/lib -L$(OUTPUT)/lib $(EXTRALDFLAGS)

################################################
ifneq ($(LIBNAME),)

$(shell mkdir -p $(TOP)/lib)
LIBCFLAGS += -fPIC -DPIC

ifeq ($(STATICLIB),Y)

#=====================如果是编译静态链接库===================
REALLIBNAME = $(LIBNAME).a
$(LIBNAME): $(CONFIG_H_FILE) $(LIBDEPS) $(LIBOBJS)
	$(AR) cr $(REALLIBNAME) $(LIBOBJS)
	$(RANLIB) $(REALLIBNAME)
	mv $(REALLIBNAME) $(TOP)/lib/
	@echo "========= create static libray $@ end ========"

else

#=========================如果是编译动态链接库========================

REALLIBNAME = $(LIBNAME).so
ifneq ($(LIBVERSION),)
SETSONAME := -Wl,-soname,$(LIBNAME).so.$(LIBVERSION)
REALLIBNAME = $(LIBNAME).so.$(LIBVERSION)
SIMPLE_LIBNAME = $(LIBNAME).so
ifneq ($(LIBVERSION_SUB),)
SOLIBNAME = $(LIBNAME).so.$(LIBVERSION)
REALLIBNAME = $(LIBNAME).so.$(LIBVERSION).$(LIBVERSION_SUB)
endif
endif

$(LIBNAME): $(CONFIG_H_FILE) $(LIBDEPS) $(LIBOBJS)
	$(CC) -shared -Wl,-Bsymbolic-functions $(SETSONAME) -o $(REALLIBNAME) $(LIBOBJS) $(LDFLAGS) $(LIBLDFLAGS) $(EXTRALDFLAGS)
	mv $(REALLIBNAME) $(TOP)/lib
	@[ -z $(SOLIBNAME) ] || ln -sf $(REALLIBNAME) $(SOLIBNAME)
	@[ -z $(SOLIBNAME) ] || mv $(SOLIBNAME) $(TOP)/lib
	@[ -z $(SIMPLE_LIBNAME) ] || ln -sf $(REALLIBNAME) $(SIMPLE_LIBNAME)
	@[ -z $(SIMPLE_LIBNAME) ] || mv $(SIMPLE_LIBNAME) $(TOP)/lib
	@echo "========= create share libray $@ end ========"

endif
endif
##################################################

##################################################
ifneq ($(EXENAME),)
$(shell mkdir -p $(TOP)/bin)
$(EXENAME): $(CONFIG_H_FILE) $(EXEDEPS) $(EXEOBJS)
	$(CC) -Wl,--allow-shlib-undefined -o $(EXENAME) $(EXEOBJS) $(LDFLAGS) $(EXELDFLAGS) $(EXTRALDFLAGS)
	mv $(EXENAME) $(TOP)/bin/
	@echo "========= Link execute $@ end ========"
endif

ifneq ($(EXENAMEP),)
$(shell mkdir -p $(TOP)/bin)
$(EXENAMEP): $(CONFIG_H_FILE) $(EXEDEPS) $(EXEOBJS)
	$(CCP) $(CPPFLAGS) -o $(EXENAMEP) $(EXEOBJS) $(LDFLAGS) $(EXELDFLAGS) $(EXTRALDFLAGS)
	mv $(EXENAMEP) $(TOP)/bin/
	@echo "========= Link execute $@ end ========"
endif

##################################################

.PHONY: rules_clean rules_install

#因为后面包含依赖文件会自动在all前面执行.d的规则，所以后面要加上$(CONFIG_H_FILE)，
#因为在规则中$<表示第一个依赖文件名
%.d: %.c $(CONFIG_H_FILE)
	@$(CC) -MM $(CFLAGS) $(EXECFLAGS) $(LIBCFLAGS) $(EXTRACFLAGS) $< | sed -e 's,^[0-9a-zA-Z._-]*: \([0-9a-zA-Z._-]*/\),\1&,' -e 's,^\([0-9a-zA-Z._-/]*\)\.o:,\1.o \1.d \1.lo:,' > $@

%.o: %.c
	$(CC) $(CFLAGS) $(EXECFLAGS) $(EXTRACFLAGS) -c -o $@ $<

%.lo: %.c
	$(CC) $(CFLAGS) $(LIBCFLAGS) $(EXTRACFLAGS) -c -o $@ $<

%.dd: %.cpp $(CONFIG_H_FILE)
	@$(CCP) -MM $(CPPFLAGS) $(CFLAGS) $(EXECFLAGS) $(LIBCFLAGS) $(EXTRACFLAGS) $< | sed -e 's,^[0-9a-zA-Z._-]*: \([0-9a-zA-Z._-]*/\),\1&,' -e 's,^\([0-9a-zA-Z._-/]*\)\.o:,\1.oo \1.dd \1.loo:,' > $@

%.oo: %.cpp
	$(CCP) $(CPPFLAGS) $(CFLAGS) $(EXECFLAGS) $(EXTRACFLAGS) -c -o $@ $<

%.loo: %.cpp
	$(CCP) $(CPPFLAGS) $(CFLAGS) $(LIBCFLAGS) $(EXTRACFLAGS) -c -o $@ $<



rules_clean:
	-rm -f $(CONFIG_H_FILE) $(EXENAME) $(REALLIBNAME) $(EXEOBJS) $(LIBOBJS) $(EXEDEPS) $(LIBDEPS) $(GCOVFILES)
	-[ -z $(EXENAME) ] || rm -f $(TOP)/bin/$(EXENAME)
	-[ -z $(EXENAMEP) ] || rm -f $(TOP)/bin/$(EXENAMEP)
	-[ -z $(LIBNAME) ] || rm -f $(TOP)/lib/$(LIBNAME).*

rules_install: $(LIBNAME) $(EXENAME)
	mkdir -p $(PREFIX)/include $(PREFIX)/bin $(PREFIX)/lib $(PREFIX)/etc
	-[ ! -d $(TOP)/include ] || cp -af $(TOP)/include/* $(PREFIX)/include/
	-[ ! -d $(TOP)/lib ] || cp -af $(TOP)/lib/* $(PREFIX)/lib/
	-[ ! -d $(TOP)/bin ] || cp -af $(TOP)/bin/* $(PREFIX)/bin/
	-[ ! -d $(TOP)/etc ] || cp -af $(TOP)/etc/* $(PREFIX)/etc/

ifneq ($(CONFIG_H_FILE),)
define CONFIG_H_ITEM
if [ "$($(1))" = "Y" ] || [ "$($(1))" = "y" ] ; then echo "#define $(1) 1" >> $(CONFIG_H_FILE) ; else echo "/*no define $(1) */" >> $(CONFIG_H_FILE) ; fi ;
endef
$(CONFIG_H_FILE): $(TOP)/def_config.mk $(OUTPUT)/config.mk
	@echo "/*this file is auto generated by rules.mk from config.mk*/" > $(CONFIG_H_FILE)
	@echo "#ifndef _$(EXENAME)_$(LIBNAME)_CONFIG_H"  >> $(CONFIG_H_FILE)
	@echo "#define _$(EXENAME)_$(LIBNAME)_CONFIG_H"  >> $(CONFIG_H_FILE)
	@echo ""  >> $(CONFIG_H_FILE)
	@$(foreach ITEM,$(CONFIG_H),$(call CONFIG_H_ITEM,$(ITEM)))
	@echo ""  >> $(CONFIG_H_FILE)
	@echo "#endif"  >> $(CONFIG_H_FILE)
	@echo ""  >> $(CONFIG_H_FILE)
	@echo "========= generate $@ end ========"
endif

ifneq ($(MAKECMDGOALS),clean)
-include $(EXEDEPS) $(LIBDEPS)
endif

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
endif

