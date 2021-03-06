# Compiler options here.
USE_OPT = -Os -fomit-frame-pointer -falign-functions=16
USE_OPT += -fno-exceptions #--specs=nosys.specs 
USE_OPT += -nostartfiles --specs=nano.specs -lc -lgcc -lm -nodefaultlibs
#USE_OPT += -ffunction-sections -fdata-sections -fno-common 
#USE_OPT += -fno-unwind-tables -fno-stack-protector 
#USE_OPT += -ftracer -ftree-loop-distribute-patterns 
#USE_OPT += -frename-registers -freorder-blocks -fconserve-stack  

# C specific options here (added to USE_OPT).
USE_COPT = -std=c99

# C++ specific options here (added to USE_OPT).
USE_CPPOPT += -std=c++11 -fno-rtti -fno-exceptions -fno-threadsafe-statics

# Enable this if you want the linker to remove unused code and data
USE_LINK_GC = yes

# Linker extra options here.
USE_LDOPT = 

# Enable this if you want link time optimizations (LTO)
USE_LTO = no

# If enabled, this option allows to compile the application in THUMB mode.
USE_THUMB = yes

# Enable this if you want to see the full log while compiling.
USE_VERBOSE_COMPILE = no

##############################################################################
#
# Project, sources and paths

PROJECT = cam_ctrl

UDEFS = -DFW_VERSION_MAJOR=0 -DFW_VERSION_MINOR=1

# Imported source files and paths
CHIBIOS = modules/ChibiOS
include board/board.mk
include $(CHIBIOS)/os/hal/platforms/STM32F1xx/platform.mk
include $(CHIBIOS)/os/hal/hal.mk
include $(CHIBIOS)/os/ports/GCC/ARMCMx/STM32F1xx/port.mk
include $(CHIBIOS)/os/kernel/kernel.mk
include $(CHIBIOS)/os/various/cpp_wrappers/kernel.mk

LDSCRIPT= $(PORTLD)/STM32F103xB.ld

VARIOUSSRC = $(CHIBIOS)/os/various/syscalls.c    \
             $(CHIBIOS)/os/various/chprintf.c    \
             $(CHIBIOS)/os/various/shell.c       \
             $(CHIBIOS)/os/various/memstreams.c  \
             $(CHIBIOS)/os/various/evtimer.c

CSRC = $(PORTSRC) \
       $(KERNSRC) \
       $(TESTSRC) \
       $(HALSRC) \
       $(PLATFORMSRC) \
       $(BOARDSRC) \
	   
CSRC += $(wildcard src/*.c)	    \
		$(wildcard src/*/*.c)	\
		$(wildcard src/*/*/*.c)

#CPPSRC = src/main.cpp
#CPPSRC = 
CPPSRC = $(wildcard src/*.cpp)	\
		 $(wildcard src/*/*.cpp)
		 
CPPSRC += $(CHCPPSRC)

#
# UAVCAN library
#

UDEFS += -DUAVCAN_STM32_CHIBIOS=1      \
		 -DUAVCAN_STM32_NUM_IFACES=1   \
	     -DUAVCAN_STM32_TIMER_NUMBER=2 \
		 -DSTDOUT_SD=SD1 -DSTDIN_SD=STDOUT_SD \
		 -DRELEASE_BUILD=1
		 
include modules/libuavcan/libuavcan/include.mk
CPPSRC+= $(LIBUAVCAN_SRC)
UINCDIR = $(LIBUAVCAN_INC)

include modules/libuavcan/libuavcan_drivers/stm32/driver/include.mk
CPPSRC += $(LIBUAVCAN_STM32_SRC)
UINCDIR += $(LIBUAVCAN_STM32_INC)

# Invoke DSDL compiler and add its default output directory to the include search path
#$(info $(shell $(LIBUAVCAN_DSDLC) $(UAVCAN_DSDL_DIR)))
UINCDIR += dsdlc_generated

#
# End ov UAVCAN libray
#

# List ASM source files here
ASMSRC = $(PORTASM)

INCDIR = $(PORTINC) $(KERNINC) $(TESTINC) \
         $(HALINC) $(PLATFORMINC) $(BOARDINC) $(CHCPPINC)\
         $(CHIBIOS)/os/various os_config src src/sys

#
# Project, sources and paths
##############################################################################

##############################################################################
# Compiler settings
#

MCU  = cortex-m3

TRGT = arm-none-eabi-
CC   = $(TRGT)gcc
CPPC = $(TRGT)g++
# Enable loading with g++ only if you need C++ runtime support.
# NOTE: You can use C++ even without C++ support if you are careful. C++
#       runtime support makes code size explode.
#LD   = $(TRGT)gcc
LD   = $(TRGT)g++
CP   = $(TRGT)objcopy
AS   = $(TRGT)gcc -x assembler-with-cpp
OD   = $(TRGT)objdump
SZ   = $(TRGT)size
HEX  = $(CP) -O ihex
BIN  = $(CP) -O binary

# ARM-specific options here
AOPT =

# THUMB-specific options here
TOPT = -mthumb -DTHUMB=1

CWARN += -Wall -Wextra -Werror -Wstrict-prototypes
CPPWARN += -Wall -Wextra -Werror

# asm statement fix
DDEFS += -Dasm=__asm

RULESPATH = $(CHIBIOS)/os/ports/GCC/ARMCMx
include $(RULESPATH)/rules.mk
