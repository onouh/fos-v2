#
# This makefile system follows the structuring conventions
# recommended by Peter Miller in his excellent paper:
#
#	Recursive Make Considered Harmful
#	http://aegis.sourceforge.net/auug97.pdf
#

ifeq ($(OS),Windows_NT)
    # WINDOWS (MinGW / MSYS2)
    # Usually requires installing 'gcc-arm-none-eabi' or 'i686-elf-gcc' via MSYS2
    TOOLPREFIX := i686-elf-
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Darwin)
        # MAC (MacPorts)
        TOOLPREFIX := /opt/local/bin/i386-elf-
    else
        # LINUX (Standard)
        TOOLPREFIX := i386-elf-
    endif
endif

V 			:= @
TOP 		:= .
OBJDIR 		:= obj
TOOLPREFIX := /opt/local/bin/i386-elf-
QEMU 		:= qemu-system-i386
PERL		:= perl
IMAGE 		:= $(OBJDIR)/fos.img

CC			:= $(TOOLPREFIX)gcc -m32 -pipe
# This points to a more generic 32-bit math helper if it exists
GCC_LIB := $(shell $(CC) -print-libgcc-file-name)
$(info VERIFYING MACPORTS LIB: $(GCC_LIB))
AS			:= $(TOOLPREFIX)as --32
AR			:= $(TOOLPREFIX)ar
LD          := $(TOOLPREFIX)ld -m elf_i386 $(GCC_LIB)
OBJCOPY		:= $(TOOLPREFIX)objcopy
OBJDUMP		:= $(TOOLPREFIX)objdump
NM			:= $(TOOLPREFIX)nm


# Compiler flags
# -fno-builtin is required to avoid refs to undefined functions in the kernel.
# Only optimize to -O1 to discourage inlining, which complicates backtraces.
# CFLAGS	:= -O0 -fno-builtin -I$(TOP) -MD -Wall -Wno-format -Wno-unused -Werror -fno-stack-protector -ggdb -g3
CFLAGS := -O0 -fno-builtin -I$(TOP) -MD -Wall -Wno-format -Wno-unused -fno-stack-protector -gdwarf-2

# Linker flags for FOS user programs
ULDFLAGS := -T user/user.ld $(GCC_LIB)

# Lists that the */Makefrag makefile fragments will add to
OBJDIRS :=

# Make sure that 'all' is the first target
all:

# Eliminate default suffix rules
.SUFFIXES:

# Delete target files if there is an error (or make is interrupted)
.DELETE_ON_ERROR:

# make it so that no intermediate .o files are ever deleted
.PRECIOUS: %.o \
 	$(OBJDIR)/boot/%.o \
	$(OBJDIR)/kern/%.o \
	$(OBJDIR)/lib/%.o \
	$(OBJDIR)/user/%.o

KERN_CFLAGS := $(CFLAGS) -DFOS_KERNEL -ggdb
USER_CFLAGS := $(CFLAGS) -DFOS_USER -ggdb


# Include Makefrags for subdirectories
include boot/Makefrag
include kern/Makefrag
include lib/Makefrag
include user/Makefrag


# Emulators

GDBPORT 	= 26000
QEMUGDB 	= -gdb tcp::$(GDBPORT)
QEMUEXTRAS	= -parallel file:fos-shell.log
QEMUOPTS 	= -drive file=$(IMAGE),media=disk,format=raw -smp 2 -m 32 $(QEMUEXTRAS)

qemu: all
	$(V)$(QEMU) -parallel mon:stdio $(QEMUOPTS)

qemu-gdb: all
	$(QEMU) $(QEMUOPTS) -S $(QEMUGDB)


# For deleting the build

clean:
	rm -rf $(OBJDIR)


# This magic automatically generates makefile dependencies
# for header files included from C source files we compile,
# and keeps those dependencies up-to-date every time we recompile.
# See 'mergedep.pl' for more information.
$(OBJDIR)/.deps: $(foreach dir, $(OBJDIRS), $(wildcard $(OBJDIR)/$(dir)/*.d))
	@mkdir -p $(@D)
	@$(PERL) mergedep.pl $@ $^

-include $(OBJDIR)/.deps


.PHONY: all clean qemu
