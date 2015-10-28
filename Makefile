# ====================
#  LIBRARY DEFINITIONS
# ====================

TARGET= vis

###############################################################################
##  SETTINGS                                                                 ##
###############################################################################

CLANG := $(shell which clang)
CCACHE := $(shell which ccache)

#prefer clang over g++
ifneq ($(CLANG),)
COMPILER=clang++
else
COMPILER=g++
endif

#use ccache if available
ifneq ($(CCACHE),)
CC=ccache $(COMPILER)
else
CC=$(COMPILER)
endif

DIR=$(shell pwd)
BUILD_DIR = $(DIR)/build

# Override optimizations via: make OPT_LEVEL=n
OPT_LEVEL = 3

# Make-local Compiler Flags
CC_FLAGS = -std=c++14
CC_FLAGS += -Werror -Weverything -Wno-variadic-macros -Wno-format-nonliteral -Wno-global-constructors -Wno-exit-time-destructors -Wno-padded -Wno-reserved-id-macro -Wno-gnu-zero-variadic-macro-arguments -Wno-c++98-compat
CC_FLAGS += -O$(OPT_LEVEL)
CC_FLAGS += -march=native
CC_FLAGS += -ffast-math
CC_FLAGS += -fno-omit-frame-pointer

ifeq ($(OS),Darwin)
CC_FLAGS += -D_OS_OSX
else
CC_FLAGS += -D_LINUX
endif

# Linker flags
LD_FLAGS = $(LDFLAGS) -fno-omit-frame-pointer

ifeq ($(OS),Darwin)
LD_FLAGS += -undefined dynamic_lookup
endif

# DEBUG Settings
ifdef DEBUG
OPT_LEVEL=0
CC_FLAGS += -pg -fprofile-arcs -ftest-coverage -g2
LD_FLAGS += -pg -fprofile-arcs -lgcov
endif

# Include Paths
INCLUDE_PATH = -I/usr/local/include -I$(DIR)/include -I$(DIR)/src

# Lib Paths
LIB_PATH = -L/usr/local/lib

# Libs
LIBS = -lncurses -lfftw3 -ljemalloc



###############################################################################
##  OBJECTS                                                                  ##
###############################################################################

SOURCES= $(wildcard src/*.cpp) $(wildcard src/*/*.cpp) $(wildcard src/*/*/*.cpp)

HEADERS= $(wildcard include/*.h) $(wildcard include/*/*.h) $(wildcard src/*.h) $(wildcard src/*/*.h) $(wildcard src/*/*/*.h)

OBJECTS= $(addprefix $(BUILD_DIR)/,$(notdir $(SOURCES:.cpp=.o)))

VPATH= $(dir $(wildcard src/*/ src/*/*/))

###############################################################################
##  MAIN TARGETS                                                             ##
###############################################################################

all: prepare build

.PHONY: prepare
prepare:
	mkdir -p $(BUILD_DIR)

.PHONY: build
build: $(OBJECTS) $(TARGET)

.PHONY:clean
clean:
	@rm -rf $(BUILD_DIR)

install:
	cp $(BUILD_DIR)/$(TARGET) /usr/local/bin/

###############################################################################
##  BUILD TARGETS                                                            ##
###############################################################################

$(BUILD_DIR)/%.o: %.cpp
	$(CC) $(CC_FLAGS) $(LD_FLAGS) $(INCLUDE_PATH) -c $< -o $@

$(TARGET): $(OBJECTS)
	$(CC) $(CC_FLAGS) $(LDFLAGS) $(INCLUDE_PATH) $(LIB_PATH) -o $(BUILD_DIR)/$(TARGET) $(OBJECTS) $(LIBS)

clang_modernize: $(HEADERS) $(SOURCES)
	clang-modernize $? -- -x c++ -std=c++14 -I$(INCLUDE_PATH)

clang_format: $(HEADERS) $(SOURCES)
	clang-format -i $?
