# GCC — C/C++ Compiler

## Compilation

### Single File Compilation

Compile a C source file to an executable:

```bash
gcc -o main main.c
```

Compile with common flags:

```bash
gcc -Wall -Wextra -pedantic -O2 -std=c17 -g -o main main.c
```

Compile a C++ source file:

```bash
g++ -Wall -Wextra -pedantic -O2 -std=c++20 -g -o main main.cpp
```

### Multi-File Projects

Compile each file separately, then link:

```bash
gcc -c -Wall -Wextra -O2 -std=c17 -o main.o main.c
gcc -c -Wall -Wextra -O2 -std=c17 -o utils.o utils.c
gcc -c -Wall -Wextra -O2 -std=c17 -o parser.o parser.c
gcc -o app main.o utils.o parser.o -lm -lpthread
```

Or compile and link in one step:

```bash
gcc -Wall -Wextra -O2 -std=c17 -o app main.c utils.c parser.c -lm -lpthread
```

### Object Files

```bash
# Compile to object file only
gcc -c -O2 -std=c17 -o main.o main.c

# List symbols in object file
nm main.o

# View assembly output
gcc -S -O2 -std=c17 -o main.s main.c

# View preprocessor output
gcc -E -std=c17 main.c > main.i
```

---

## Compiler Flags Reference

### Standard Selection

| Flag | Purpose |
| ---- | ------- |
| `-std=c89` | C89/ANSI C |
| `-std=c99` | C99 |
| `-std=c11` | C11 |
| `-std=c17` | C17 (default for gcc 8+) |
| `-std=c2x` | C23 (draft) |
| `-std=c++17` | C++17 |
| `-std=c++20` | C++20 (default for g++ 12+) |
| `-std=c++23` | C++23 (draft) |
| `-std=gnu17` | C17 with GNU extensions |
| `-std=gnu++20` | C++20 with GNU extensions |

### Warning Flags

| Flag | Purpose |
| ---- | ------- |
| `-Wall` | Most recommended warnings |
| `-Wextra` | Extra warnings (unused params, sign comparison) |
| `-Werror` | Treat warnings as errors |
| `-pedantic` | Strict ISO C conformance |
| `-pedantic-errors` | Pedantic warnings as errors |
| `-Wconversion` | Implicit conversion warnings |
| `-Wshadow` | Variable shadowing |
| `-Wdouble-promotion` | float to double promotion |
| `-Wformat` | Format string warnings |
| `-Wformat-overflow` | Buffer overflow in format strings |
| `-Wnull-dereference` | NULL pointer dereference |
| `-Wuninitialized` | Uninitialized variable use |
| `-Wunused` | Unused variables and functions |
| `-Wpragmas` | Invalid pragma warnings |

### Optimization Flags

| Flag | Purpose |
| ---- | ------- |
| `-O0` | No optimization (default for debug) |
| `-O1` | Basic optimization |
| `-O2` | Standard optimization (recommended) |
| `-O3` | Aggressive optimization |
| `-Os` | Optimize for size |
| `-Ofast` | Aggressive + strict floating-point |
| `-flto` | Link-time optimization |
| `-march=native` | Optimize for host CPU architecture |
| `-mtune=native` | Tune for host CPU |

### Debug Flags

| Flag | Purpose |
| ---- | ------- |
| `-g` | Standard debug symbols (DWARF) |
| `-g3` | Debug + macro definitions |
| `-gdwarf-4` | DWARF version 4 debug format |
| `-fno-omit-frame-pointer` | Keep frame pointers for better backtraces |
| `-fstack-protector` | Stack buffer overflow detection |
| `-fstack-protector-strong` | Stronger stack protector |
| `-fno-stack-delay` | No stack delay |

### Sanitizer Flags

| Flag | Purpose |
| ---- | ------- |
| `-fsanitize=address` | AddressSanitizer (buffer overflows, use-after-free) |
| `-fsanitize=undefined` | UndefinedBehaviorSanitizer |
| `-fsanitize=thread` | ThreadSanitizer (data race detection) |
| `-fsanitize=memory` | MemorySanitizer (uninitialized reads) |
| `-fsanitize=leak` | LeakSanitizer |
| `-fsanitize=control-flow` | Control-flow integrity |

### Include and Library Flags

| Flag | Purpose |
| ---- | ------- |
| `-I dir` | Add include directory |
| `-isystem dir` | System include (suppress warnings) |
| `-idirafter dir` | Append to system includes |
| `-L dir` | Add library search path |
| `-l lib` | Link library (libname.so or libname.a) |
| `-pthread` | POSIX threads support |
| `-lm` | Math library (libc) |
| `-ldl` | Dynamic linking library |
| `-lrt` | Real-time library |
| `-static` | Static linking (prefer .a over .so) |
| `-shared` | Build shared library (.so) |

---

## Linking Libraries

### Static Library

```bash
# Create static library
ar rcs libutils.a utils.o parser.o

# Link against static library
gcc -o app main.c -L. -lutils -lm
# Or link directly:
gcc -o app main.c libutils.a -lm
```

### Shared Library

```bash
# Create shared library
gcc -shared -fPIC -o libutils.so utils.c

# Link against shared library
gcc -o app main.c -L. -lutils

# Set rpath at build time
gcc -o app main.c -L. -lutils -Wl,-rpath,.

# Or set RPATH at runtime
LD_LIBRARY_PATH=. ./app
```

### Library Linking Order

Library order matters in GCC. Libraries must come **after** the object files that reference them:

```bash
# Correct: libraries after object files
gcc -o app main.o utils.o -lmath -lpthread

# Incorrect: libraries before object files may miss symbols
gcc -o app -lmath -lpthread main.o utils.o
```

---

## Header Files

### Writing Headers

```c
#ifndef UTILS_H
#define UTILS_H

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Initialize the utility subsystem.
 * @return 0 on success, non-zero on failure.
 */
int utils_init(void);

/**
 * Process data from the given buffer.
 * @param data Buffer pointer (may be NULL if length is 0).
 * @param length Number of elements in the buffer.
 * @return Number of items processed.
 */
size_t utils_process(const void *data, size_t length);

#ifdef __cplusplus
}
#endif

#endif /* UTILS_H */
```

### Include Strategy

```c
/* Standard library first */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* External headers */
#include <openssl/ssl.h>
#include <zlib.h>

/* Project headers (relative paths) */
#include "utils.h"
#include "config.h"
#include "parser/parser.h"
```

---

## Makefile Patterns

### Simple Makefile

```makefile
CC := gcc
CFLAGS := -Wall -Wextra -pedantic -O2 -std=c17 -g
LDFLAGS :=
LDLIBS := -lm -lpthread

SRCDIR := src
BUILDDIR := build
TARGET := myapp

SOURCES := $(wildcard $(SRCDIR)/*.c)
OBJECTS := $(patsubst $(SRCDIR)/%.c,$(BUILDDIR)/%.o,$(SOURCES))

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CC) $(OBJECTS) -o $@ $(LDFLAGS) $(LDLIBS)

$(BUILDDIR)/%.o: $(SRCDIR)/%.c | $(BUILDDIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

clean:
	rm -rf $(BUILDDIR) $(TARGET)
```

### Dependency Generation

```makefile
# Auto-generate dependencies with -MMD
CFLAGS += -MMD -MP

# Include generated dependencies
DEPS := $(SOURCES:.c=.d)
-include $(DEPS)
```

---

## CMake Patterns

### CMakeLists.txt

```cmake
cmake_minimum_required(VERSION 3.16)
project(myapp C)

# Set standards
set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Find packages
find_package(Threads REQUIRED)
find_package(OpenSSL REQUIRED)
find_package(ZLIB REQUIRED)

# Source files
set(SOURCES
    src/main.c
    src/utils.c
    src/parser.c
)

# Executable target
add_executable(${PROJECT_NAME} ${SOURCES})

# Link libraries
target_link_libraries(${PROJECT_NAME}
    PRIVATE
        OpenSSL::SSL
        OpenSSL::Crypto
        ZLIB::ZLIB
        Threads::Threads
        m
)

# Compiler options
target_compile_options(${PROJECT_NAME} PRIVATE
    -Wall -Wextra -pedantic -O2
    $<$<CONFIG:Debug>:-g -O0>
    $<$<CONFIG:Release>:-flto>
)

# Install rules
install(TARGETS ${PROJECT_NAME} DESTINATION bin)
```

### CMake Build Commands

```bash
# Configure
cmake -B build -DCMAKE_BUILD_TYPE=Release

# Build
cmake --build build

# Run tests
ctest --test-dir build

# Install
cmake --install build --prefix /usr/local
```

---

## Debugging Compilation

### Common Issues

```bash
# Debug include path issues
gcc -H -o app main.c    # Print include paths (verbose)

# Debug macro definitions
gcc -dM -E main.c > macros.txt   # Dump all macros

# Debug symbol table
nm app | grep undefined   # Find undefined symbols
readelf -s app | head     # Read ELF symbol table

# Debug library search
gcc -v -o app main.c -lutils    # Verbose linker output

# View generated assembly
gcc -S -O2 -std=c17 -fverbose-asm -o main.s main.c
```

### Preprocessor Debugging

```bash
# Show preprocessor output
gcc -E main.c | head -50

# Show only warnings
gcc -Wall -Wextra main.c 2>&1 | grep warning

# Treat warnings as errors
gcc -Werror main.c
```

---

## Code Coverage

```bash
# Compile with coverage flags
gcc --coverage -g -O0 -o app main.c

# Run the program
./app

# Generate coverage report
gcov main.c.cov
lcov --capture --directory . --output-file coverage.info
genhtml coverage.info --output-directory coverage_html
```

---

## Cross-Compilation

### Toolchain Setup

```bash
# ARM cross-compile
aarch64-linux-gnu-gcc -o app-arm main.c -static

# Set cross-compilation environment
export CROSS_COMPILE=aarch64-linux-gnu-
export ARCH=arm64

# Cross-compile with CMake
cmake -B build \
    -DCMAKE_TOOLCHAIN_FILE=arm64-toolchain.cmake \
    -DCMAKE_BUILD_TYPE=Release
```

### Platform-Specific Builds

```bash
# Build for multiple architectures
gcc -m32 -o app32 main.c     # 32-bit x86
gcc -m64 -o app64 main.c     # 64-bit x86_64
gcc -march=x86-64 -o app-x64 main.c
gcc -mcpu=cortex-a72 -o app-arm main.c   # ARM Cortex-A72
```

---

## Best Practices

1. **Always use `-Wall -Wextra`** in development builds to catch common issues.
2. **Use `-Werror`** in CI/CD to prevent warnings from being ignored.
3. **Always include `-g`** when debugging — without it, gdb cannot map addresses to source lines.
4. **Set the C standard explicitly** (`-std=c17` or `-std=gnu17`) rather than relying on defaults.
5. **Keep `-lm` at the end** of the link line — it must come after object files that reference math functions.
6. **Use `-fPIC` for shared libraries** — Position Independent Code is required for position-independent executables.
7. **Prefer `-flto` in release builds** — Link-time optimization can improve performance by 10-20%.
8. **Use `-MMD -MP`** for automatic dependency tracking in Makefiles.
9. **Prefer `find_package()` in CMake** over manual library paths for better portability.
10. **Set `CMAKE_BUILD_TYPE`** explicitly when configuring CMake projects.
