# GCC — Build Systems

## Make

### Basic Makefile

```makefile
# Compiler and flags
CC := gcc
CFLAGS := -Wall -Wextra -pedantic -O2 -std=c17 -g
LDFLAGS :=
LDLIBS := -lm -lpthread

# Directories
SRCDIR := src
INCDIR := include
BUILDDIR := build
OBJDIR := $(BUILDDIR)/obj

# Target
TARGET := myapp
VERSION := 1.0.0

# Source and object files
SOURCES := $(wildcard $(SRCDIR)/*.c)
OBJECTS := $(patsubst $(SRCDIR)/%.c,$(OBJDIR)/%.o,$(SOURCES))
HEADERS := $(wildcard $(INCDIR)/*.h)

# Phony targets
.PHONY: all clean install test

# Default target
all: $(TARGET)

# Link
$(TARGET): $(OBJECTS)
	$(CC) $(OBJECTS) -o $@ $(LDFLAGS) $(LDLIBS)

# Compile
$(OBJDIR)/%.o: $(SRCDIR)/%.c $(HEADERS) | $(OBJDIR)
	$(CC) $(CFLAGS) -I$(INCDIR) -c $< -o $@

# Create build directory
$(OBJDIR):
	mkdir -p $(OBJDIR)

# Install
install: $(TARGET)
	install -d $(PREFIX)/bin
	install -m 755 $(TARGET) $(PREFIX)/bin/

# Uninstall
uninstall:
	rm -f $(PREFIX)/bin/$(TARGET)

# Clean
clean:
	rm -rf $(BUILDDIR) $(TARGET)

# Run tests
test: $(TARGET)
	./$(TARGET) --test

# Debug target
debug:
	$(MAKE) CFLAGS="$(CFLAGS) -g -O0 -DDEBUG" all

# Release target
release:
	$(MAKE) CFLAGS="$(CFLAGS) -O2 -flto" LDFLAGS="-flto" all

# Cross-compile
cross:
	$(MAKE) CC=aarch64-linux-gnu-gcc TARGET=arm64 all
```

### Pattern Rules

```makefile
# Generic pattern rule
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Header dependency generation
-include $(OBJECTS:.o=.d)

%.d: %.c
	@set -e; $(CC) -MM $(CFLAGS) $< | sed 's/$$/$@ $@.d/' > $@
```

---

## CMake

### Minimal CMakeLists.txt

```cmake
cmake_minimum_required(VERSION 3.16)
project(myapp VERSION 1.0.0 LANGUAGES C)

# Set defaults
set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Find packages
find_package(Threads REQUIRED)
find_package(OpenSSL REQUIRED)

# Library target
add_library(utils STATIC src/utils.c src/parser.c)
target_include_directories(utils PUBLIC include)
target_link_libraries(utils PUBLIC m)

# Executable target
add_executable(${PROJECT_NAME} src/main.c)
target_link_libraries(${PROJECT_NAME} PRIVATE utils OpenSSL::SSL Threads::Threads)

# Test executable
add_executable(${PROJECT_NAME}-test tests/test_main.c)
target_link_libraries(${PROJECT_NAME}-test PRIVATE utils)

# Enable testing
enable_testing()
add_test(NAME test_main COMMAND ${PROJECT_NAME}-test)
```

### CMake Build Configuration

```bash
# Configure
cmake -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DENABLE_TESTS=ON \
    -DENABLE_SHARED=ON

# Build
cmake --build build --parallel

# Run tests
ctest --test-dir build --output-on-failure

# Install
cmake --install build

# Generate compile database (for IDE support)
cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
```

### CMake Presets (cmake-presets.json)

```json
{
  "version": 3,
  "configurePresets": [
    {
      "name": "default",
      "binaryDir": "${sourceDir}/build",
      "cacheVariables": {
        "CMAKE_BUILD_TYPE": "Debug"
      }
    },
    {
      "name": "release",
      "inherits": "default",
      "cacheVariables": {
        "CMAKE_BUILD_TYPE": "Release"
      }
    },
    {
      "name": "cross-arm",
      "inherits": "default",
      "toolchainFile": "toolchains/arm64.cmake",
      "cacheVariables": {
        "CMAKE_SYSTEM_NAME": "Linux",
        "CMAKE_SYSTEM_PROCESSOR": "arm64"
      }
    }
  ],
  "buildPresets": [
    {
      "name": "debug",
      "configurePreset": "default"
    },
    {
      "name": "release",
      "configurePreset": "release"
    }
  ]
}
```

---

## Meson

### meson.build

```meson
project('myapp', 'c',
  version : '1.0.0',
  default_options : [
    'warning_level=2',
    'c_std=c17',
    'buildtype=debugoptimized',
  ]
)

# Dependencies
threads = dependency('threads')
openssl = dependency('openssl', version : '>=1.1')
zlib = dependency('zlib')

# Include directories
inc = include_directories('include')

# Library
utils_src = ['src/utils.c', 'src/parser.c']
utils_lib = library('utils', utils_src,
  include_directories : inc,
  dependencies : [zlib],
  install : true,
)

# Executable
main_exe = executable('myapp', 'src/main.c',
  include_directories : inc,
  dependencies : [utils_lib, threads, openssl],
  install : true,
)

# Tests
test('main_test', main_exe, args : ['--test'])

# Install
install_headers('include/*.h')
```

### Meson Commands

```bash
# Configure
meson setup build

# Build
meson compile -C build

# Test
meson test -C build

# Install
meson install -C build

# Cross compile
meson setup build --cross-file=meson-cross.ini
```

---

## SCons

### SConstruct

```python
Import('env')

# Build environments
env = Environment(
    CC='gcc',
    CXX='g++',
    CFLAGS=['-Wall', '-Wextra', '-std=c17'],
    CXXFLAGS=['-Wall', '-Wextra', '-std=c++20'],
    LIBS=['m', 'pthread'],
)

# Library
utils = env.StaticLibrary('utils', ['src/utils.c', 'src/parser.c'])
env.Install('lib', utils)

# Executable
app = env.Program('myapp', 'src/main.c')
env.Install('bin', app)

# Tests
test = env.Test('main_test', app, arguments=['--test'])
env.Alias('test', [], [test])

Default(app)
```

---

## Cross-Compilation

### Cross-Compilation Toolchain File

```cmake
# toolchains/arm64.cmake
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm64)

set(CROSS_COMPILE aarch64-linux-gnu-)
set(CMAKE_C_COMPILER ${CROSS_COMPILE}gcc)
set(CMAKE_CXX_COMPILER ${CROSS_COMPILE}g++)
set(CMAKE_AR ${CROSS_COMPILE}ar)
set(CMAKE_RANLIB ${CROSS_COMPILE}ranlib)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
```

### Cross-Compilation with Make

```makefile
# Makefile with cross-compilation support
CROSS ?=
CC := $(CROSS)gcc
AR := $(CROSS)ar
CROSS_PREFIX :=

# When CROSS is set (e.g., CROSS=aarch64-linux-gnu-)
# CC becomes aarch64-linux-gnu-gcc
# AR becomes aarch64-linux-gnu-ar
```

---

## Library Discovery

### pkg-config

```bash
# Find library paths and flags
pkg-config --cflags openssl
pkg-config --libs openssl

# Multiple libraries
pkg-config --cflags --libs openssl zlib

# Check version
pkg-config --modversion openssl

# Use in Makefile
PKG_CONFIG := pkg-config
OPENSSL_CFLAGS := $(shell pkg-config --cflags openssl)
OPENSSL_LIBS := $(shell pkg-config --libs openssl)

# Use in CMake
find_package(PkgConfig REQUIRED)
pkg_check_modules(OPENSSL REQUIRED openssl)
pkg_check_modules(ZLIB REQUIRED zlib)
```

### CMake find_package

```cmake
# Built-in modules
find_package(Threads REQUIRED)
find_package(ZLIB REQUIRED)
find_package(OpenSSL REQUIRED)
find_package(OpenMP REQUIRED)
find_package(Boost REQUIRED COMPONENTS system filesystem)

# Custom modules
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
find_package(MyLibrary REQUIRED CONFIG)

# Use found packages
target_include_directories(myapp PRIVATE ${OPENSSL_INCLUDE_DIRS})
target_link_libraries(myapp PRIVATE ${OPENSSL_LIBRARIES})
```

---

## Best Practices

### Makefile Best Practices

1. **Use variables for flags** — `CFLAGS`, `CXXFLAGS`, `LDFLAGS`, `LDLIBS`.
2. **Use `.PHONY`** for non-file targets (`all`, `clean`, `install`, `test`).
3. **Use automatic variables** — `$@` (target), `$<` (first dependency), `$^` (all dependencies).
4. **Use `:=`** for immediate assignment, `=` for deferred.
5. **Use `wildcard`** and `patsubst` for dynamic file discovery.
6. **Include dependency files** — `-include $(DEPS)` for auto-generated dependencies.
7. **Use `mkdir -p`** pattern rule to create directories automatically.

### CMake Best Practices

1. **Set minimum CMake version** — `cmake_minimum_required(VERSION 3.16)`.
2. **Use `find_package()`** for library discovery instead of hard-coding paths.
3. **Use `target_*` commands** instead of global `set()` where possible.
4. **Separate interface, public, and private** — `PUBLIC` vs `PRIVATE` vs `INTERFACE`.
5. **Use `cmake-presets.json`** for reproducible builds.
6. **Enable `CMAKE_EXPORT_COMPILE_COMMANDS`** for IDE support.
7. **Use `--parallel`** for faster builds.
8. **Use `cmake --install`** (CMake 3.15+) instead of `make install`.

### General Best Practices

1. **Set `CMAKE_BUILD_TYPE`** explicitly: `Debug`, `Release`, `RelWithDebInfo`, `MinSizeRel`.
2. **Keep build and source directories separate** — never build in the source tree for CMake.
3. **Use `-flto`** in release builds for link-time optimization.
4. **Use `-fPIC`** for shared libraries and position-independent executables.
5. **Set `CMAKE_POSITION_INDEPENDENT_CODE`** when building shared libraries.
6. **Use `pkg-config`** for system library discovery.
7. **Pin CMake version** to avoid breaking changes.
