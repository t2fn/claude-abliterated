---
name: gcc-claude-abliterated
description: C/C++ dev stack with GCC 14, GDB 16, cross-compilers (ARM, MIPS, PPC, RISC-V, Tile, and more), valgrind, cmake, and full toolchain for Claude-driven C/C++ development
---

# GCC Dev Stack (claude-abliterated)

A complete C/C++ development environment on top of claude-abliterated:rocky10 with 30+ tools and cross-compilation support for 24 architectures.

## Tool Index

| Tool | Package | Role |
|------|---------|------|
| **gcc** | GCC 14 | C compiler (RECOMMENDED) |
| **g++** | GCC 14 | C++ compiler |
| **gfortran** | GCC 14 | Fortran compiler |
| **gdb** | GDB 16 | Debugger (breakpoints, step, inspect) |
| **valgrind** | Valgrind 3.22+ | Memory debugging (leaks, errors, profiling) |
| **cppcheck** | cppcheck 2.x | Static analysis (comprehensive checks) |
| **ar** | Binutils | Static library archiver |
| **as** | Binutils | Assembler |
| **ld** | Binutils | Linker |
| **nm** | Binutils | Symbol table viewer |
| **objcopy** | Binutils | Object file copier |
| **objdump** | Binutils | Disassembler |
| **ranlib** | Binutils | Archive index generator |
| **readelf** | Binutils | ELF file inspector |
| **size** | Binutils | Symbol size display |
| **strings** | Binutils | String extractor |
| **strip** | Binutils | Symbol stripper |
| **addr2line** | Binutils | Address to line converter |
| **make** | GNU Make | Build system |
| **cmake** | CMake 3.30+ | Modern build system |
| **ninja** | Ninja 1.12+ | Fast build system |
| **pkg-config** | pkg-config | Library discovery |
| **aarch64-gcc** | Cross-compiler | ARM 64-bit cross-compiler |
| **arm-gcc** | Cross-compiler | ARM 32-bit cross-compiler |
| **mips-gcc** | Cross-compiler | MIPS (big endian) cross-compiler |
| **mipsel-gcc** | Cross-compiler | MIPS (little endian) cross-compiler |
| **mips64-gcc** | Cross-compiler | MIPS64 cross-compiler |
| **mips64el-gcc** | Cross-compiler | MIPS64 little endian cross-compiler |
| **mips64be-gcc** | Cross-compiler | MIPS64 big endian cross-compiler |
| **mipsisa32r6-gcc** | Cross-compiler | MIPS R6 32-bit cross-compiler |
| **mipsisa64r6-gcc** | Cross-compiler | MIPS R6 64-bit cross-compiler |
| **mipsn32-gcc** | Cross-compiler | MIPS N32 ABI cross-compiler |
| **mipsn32el-gcc** | Cross-compiler | MIPS N32 little endian cross-compiler |
| **ppc-gcc** | Cross-compiler | PowerPC 32-bit cross-compiler |
| **ppc64-gcc** | Cross-compiler | PowerPC 64-bit cross-compiler |
| **ppc64le-gcc** | Cross-compiler | PowerPC 64-bit LE cross-compiler |
| **riscv64-gcc** | Cross-compiler | RISC-V 64-bit cross-compiler |
| **tilegx-gcc** | Cross-compiler | TileGX cross-compiler |
| **tilepro-gcc** | Cross-compiler | TilePro cross-compiler |
| **xtensa-gcc** | Cross-compiler | Xtensa cross-compiler |
| **microblaze-gcc** | Cross-compiler | MicroBlaze cross-compiler |
| **sh4-gcc** | Cross-compiler | SH4 cross-compiler |

---

## Linting Policy

**New files Claude writes** are auto-linted with `gcc -Wall -Wextra -pedantic` before being presented to the user. This is always done — no need to ask.

**Existing code** is NOT touched unless Claude is explicitly tasked with linting it. When Claude notices issues in existing code, Claude should **ask the user** before running any linting or auto-fix.

```
When writing NEW files:   auto-lint with gcc/g++ -Wall -Wextra -pedantic
When touching EXISTING:   ask first: "Lint the existing code? (yes/no)"
```

## Recommended Workflow for Claude-Driven C/C++ Development

```bash
# 1. Lint new files (auto — Claude does this automatically)
gcc -Wall -Wextra -pedantic -std=c17 -c file.c    # lint and compile
g++ -Wall -Wextra -pedantic -std=c++20 -c file.cpp # lint and compile

# 2. Full build stack (ask before running on existing code)
gcc -Wall -Wextra -pedantic -O2 -g -std=c17 -o app *.c -lm -lpthread
g++ -Wall -Wextra -pedantic -O2 -g -std=c++20 -o app *.cpp

# 3. Full lint stack (ask before modifying existing code)
gcc -Wall -Wextra -pedantic -Werror -std=c17 -fsyntax-only *.c
cppcheck --enable=all *.c

# 4. Memory check (read-only — safe)
valgrind --leak-check=full --show-leak-kinds=all ./app

# 5. Debug with gdb
gdb ./app

# 6. Cross-compile
aarch64-linux-gnu-gcc -o app-arm main.c -static
```

---

## Core Toolchain

### gcc (C Compiler)

The primary C compiler. Uses `-std=c17` by default.

```bash
# Compile and link
gcc -Wall -Wextra -pedantic -O2 -std=c17 -g -o app main.c

# Compile with multiple source files
gcc -Wall -Wextra -O2 -std=c17 -o app main.c utils.c parser.c -lm -lpthread

# Compile only (no linking)
gcc -c -Wall -Wextra -O2 -std=c17 -o main.o main.c

# Debug build
gcc -g -O0 -fno-omit-frame-pointer -DDEBUG -Wall -Wextra -std=c17 -o app-debug main.c

# Release build
gcc -O2 -flto -g -Wall -Wextra -std=c17 -o app-release main.c

# AddressSanitizer build
gcc -fsanitize=address -g -O1 -fno-omit-frame-pointer -o app-asan main.c

# UndefinedBehaviorSanitizer build
gcc -fsanitize=undefined -g -o app-ubsan main.c

# Static library
ar rcs libutils.a utils.o parser.o
gcc -o app main.c -L. -lutils -lm
# Or direct:
gcc -o app main.c libutils.a -lm

# Shared library
gcc -shared -fPIC -o libutils.so utils.c
gcc -o app main.c -L. -lutils -Wl,-rpath,.

# Check library linking order
gcc -v -o app main.c -lutils    # verbose linker output

# View symbols
nm app | grep undefined           # find undefined symbols
readelf -s app | head             # read ELF symbol table

# Code coverage
gcc --coverage -g -O0 -o app main.c
# After running: gcov main.c.cov; lcov --capture --directory . --output-file coverage.info
```

### g++ (C++ Compiler)

The primary C++ compiler. Uses `-std=c++20` by default.

```bash
# Compile and link
g++ -Wall -Wextra -pedantic -O2 -std=c++20 -g -o app main.cpp

# Compile with multiple source files
g++ -Wall -Wextra -O2 -std=c++20 -o app main.cpp utils.cpp parser.cpp -lm -lpthread

# Compile only (no linking)
g++ -c -Wall -Wextra -O2 -std=c++20 -o main.o main.cpp

# Debug build
g++ -g -O0 -fno-omit-frame-pointer -DDEBUG -Wall -Wextra -std=c++20 -o app-debug main.cpp

# Release build
g++ -O2 -flto -g -Wall -Wextra -std=c++20 -o app-release main.cpp

# AddressSanitizer build
g++ -fsanitize=address -g -O1 -fno-omit-frame-pointer -o app-asan main.cpp
```

---

## GDB Debugger

GDB 16 with pretty printing, core dump support, and Python integration.

```bash
# Launch GDB
gdb ./app                      # debug executable
gdb ./app arg1 arg2            # with arguments
gdb ./app core                 # with core dump
gdb -p <PID>                   # attach to running process

# Inside GDB — essential commands
(gdb) run                      # execute program
(gdb) break main               # set breakpoint
(gdb) break utils.c:42         # file:line breakpoint
(gdb) break if count > 100     # conditional breakpoint
(gdb) continue                 # resume execution
(gdb) next                     # step over
(gdb) step                     # step into
(gdb) print x                  # print variable
(gdb) print/x 0x1f            # hex output
(gdb) print *user              # dereference struct
(gdb) display count            # auto-display expression
(gdb) backtrace                # show call stack
(gdb) frame 3                  # select stack frame
(gdb) watch x                  # set watchpoint
(gdb) disassemble main         # disassemble function
(gdb) info registers           # show registers
(gdb) info threads             # list threads
(gdb) quit                     # exit GDB

# GDB configuration (~/.gdbinit)
set print pretty on
set print elements 0           # no limit on arrays
set width 0                    # auto-width
set pagination on
set disassembly-flavor intel
set breakpoint pending on
set breakpoint verbose on
```

---

## Cross-Compilation

### Architecture Quick Reference

| Arch | GCC Binary | Endian | ABI | Sysroot |
|------|-----------|--------|-----|---------|
| x86_64 | `gcc` | native | system | `/usr` |
| i686 | `gcc -m32` | native | system | `/usr` |
| i586 | `gcc -m32 -march=i586` | native | system | `/usr` |
| aarch64 | `aarch64-linux-gnu-gcc` | native | gnu | `/usr/aarch64-linux-gnu` |
| arm | `arm-linux-gnueabihf-gcc` | native | gnueabihf | `/usr/arm-linux-gnueabihf` |
| mips | `mips-linux-gnu-gcc` | big | o32 | `/usr/mips-linux-gnu` |
| mipsel | `mipsel-linux-gnu-gcc` | little | o32 | `/usr/mipsel-linux-gnu` |
| mips64 | `mips64-linux-gnu-gcc` | big | n32 | `/usr/mips64-linux-gnu` |
| mips64el | `mips64el-linux-gnuabi64-gcc` | little | abi64 | `/usr/mips64el-linux-gnu` |
| mips64be | `mips64be-linux-gnuabi64-gcc` | big | abi64 | `/usr/mips64be-linux-gnu` |
| mipsisa32r6 | `mipsisa32r6-linux-gnu-gcc` | big | n32 | `/usr/mipsisa32r6-linux-gnu` |
| mipsisa32r6el | `mipsisa32r6el-linux-gnu-gcc` | little | n32 | `/usr/mipsisa32r6el-linux-gnu` |
| mipsisa64r6 | `mipsisa64r6-linux-gnu-gcc` | big | abi64 | `/usr/mipsisa64r6-linux-gnu` |
| mipsisa64r6el | `mipsisa64r6el-linux-gnu-gcc` | little | abi64 | `/usr/mipsisa64r6el-linux-gnu` |
| mipsn32 | `mipsn32-linux-gnu-gcc` | big | n32 | `/usr/mipsn32-linux-gnu` |
| mipsn32el | `mipsn32el-linux-gnu-gcc` | little | n32 | `/usr/mipsn32el-linux-gnu` |
| ppc | `ppc-linux-gnu-gcc` | native | elf | `/usr/ppc-linux-gnu` |
| ppc64 | `ppc64-linux-gnu-gcc` | native | elfv1 | `/usr/ppc64-linux-gnu` |
| ppc64le | `ppc64le-linux-gnu-gcc` | native | elfv2 | `/usr/ppc64le-linux-gnu` |
| riscv64 | `riscv64-linux-gnu-gcc` | native | lp64d | `/usr/riscv64-linux-gnu` |
| tilegx | `tilegx-linux-gnu-gcc` | native | system | `/usr/tilegx-linux-gnu` |
| tilepro | `tilepro-linux-gnu-gcc` | native | system | `/usr/tilepro-linux-gnu` |
| xtensa | `xtensa-gcc` | custom | custom | `/usr/xtensa` |
| microblaze | `microblaze-gcc` | native | elf | `/usr/microblaze` |
| sh4 | `sh4-linux-gnu-gcc` | native | elf | `/usr/sh4-linux-gnu` |

### Cross-Compilation Examples

```bash
# ARM 64-bit
aarch64-linux-gnu-gcc -o app-arm64 main.c -static
aarch64-linux-gnu-g++ -o app-arm64 main.cpp -static

# ARM 32-bit
arm-linux-gnueabihf-gcc -o app-arm main.c -static
arm-linux-gnueabihf-g++ -o app-arm main.cpp -static

# MIPS (big endian)
mips-linux-gnu-gcc -o app-mips main.c -static -mabi=32
mips64-linux-gnu-gcc -o app-mips64 main.c -static -mabi=n32

# MIPS64 (little endian)
mips64el-linux-gnuabi64-gcc -o app-mips64el main.c -static
mips64el-linux-gnuabin32-gcc -o app-mipsn32el main.c -static -mabi=n32

# MIPS R6
mipsisa32r6el-linux-gnu-gcc -o app-mipsr6 main.c -static
mipsisa64r6el-linux-gnu-gcc -o app-mips64r6 main.c -static

# PowerPC
ppc-linux-gnu-gcc -o app-ppc main.c -static
ppc64-linux-gnu-gcc -o app-ppc64 main.c -static
ppc64le-linux-gnu-gcc -o app-ppc64le main.c -static

# RISC-V
riscv64-linux-gnu-gcc -o app-riscv main.c -static
riscv64-unknown-elf-gcc -o app-riscv-elf main.c -static

# Tile
tilegx-linux-gnu-gcc -o app-tilegx main.c -static
tilepro-linux-gnu-gcc -o app-tilepro main.c -static

# With environment variables
export CROSS_COMPILE=aarch64-linux-gnu-
export ARCH=arm64
$CROSS_COMPILE-gcc -o app-arm main.c

# CMake cross-compilation
cmake -B build \
    -DCMAKE_TOOLCHAIN_FILE=mips-toolchain.cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_SYSTEM_NAME=Linux \
    -DCMAKE_SYSTEM_PROCESSOR=mips

# Ninja cross-compilation
cmake -G Ninja -B build \
    -DCMAKE_C_COMPILER=mips-linux-gnu-gcc \
    -DCMAKE_CXX_COMPILER=mips-linux-gnu-g++
```

### Toolchain File

```cmake
# toolchains/mips64el.cmake
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR mips64el)

set(CROSS_COMPILE mips64el-linux-gnu-)
set(CMAKE_C_COMPILER ${CROSS_COMPILE}gcc)
set(CMAKE_CXX_COMPILER ${CROSS_COMPILE}g++)
set(CMAKE_AR ${CROSS_COMPILE}ar)
set(CMAKE_RANLIB ${CROSS_COMPILE}ranlib)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
```

---

## Memory Debugging

### Valgrind (RECOMMENDED)

```bash
# Full leak check (default)
valgrind --leak-check=full --show-leak-kinds=all ./app

# Detailed output
valgrind --leak-check=full --show-leak-kinds=all \
    --track-origins=yes --verbose ./app

# With arguments
valgrind --leak-check=full ./app arg1 arg2

# Profile with callgrind
valgrind --tool=callgrind ./app
callgrind_annotate callgrind.out.<PID>

# Cache simulation
valgrind --tool=cachegrind ./app
cg_annotate cg_profile.out
```

### Leak Kinds

| Kind | Meaning |
|------|---------|
| definite | Directly leaked — no pointer to it |
| indirect | Leaked because a definite leak owns it |
| possible | Some pointers to it, but not all |
| reachable | Not leaked — reachable from globals |

### Sanitizers

```bash
# AddressSanitizer (compile + run)
gcc -fsanitize=address -g -O1 -fno-omit-frame-pointer -o app-asan main.c
ASAN_OPTIONS=detect_leaks=1:print_stats=1 ./app-asan

# UndefinedBehaviorSanitizer
gcc -fsanitize=undefined -g -o app-ubsan main.c
UBSAN_OPTIONS=print_stacktrace=1 ./app-ubsan

# ThreadSanitizer
gcc -fsanitize=thread -g -o app-tsan main.c -pthread
TSAN_OPTIONS="history_size=7" ./app-tsan

# LeakSanitizer
gcc -fsanitize=leak -g -o app-lsan main.c
LSAN_OPTIONS=print_stats=1 ./app-lsan

# Thread Sanitizer
gcc -fsanitize=thread -g -o app-tsan main.c -pthread
TSAN_OPTIONS="history_size=7:exitcode=86" ./app-tsan
```

---

## Static Analysis

### cppcheck

```bash
# Comprehensive check
cppcheck --enable=all --std=c17 --output-file=cppcheck.txt *.c

# Check with specific standards
cppcheck --std=c11 *.c
cppcheck --std=c++20 *.cpp

# Enable additional checks
cppcheck --enable=warning,style,performance,portability *.c

# Output as XML
cppcheck --xml --output-file=cppcheck.xml *.c

# Exclude directories
cppcheck --exclude=build --exclude=vendor *.c
```

---

## Build Systems

### make

```bash
# Build all targets
make all

# Build specific target
make app

# Clean
make clean

# Build with verbose output
make V=1

# Parallel build
make -j$(nproc)

# Cross-compile
make CROSS=aarch64-linux-gnu- ARCH=arm64
```

### CMake

```bash
# Configure with debug build type
cmake -B build -DCMAKE_BUILD_TYPE=Debug

# Configure with release build type
cmake -B build -DCMAKE_BUILD_TYPE=Release

# Build
cmake --build build

# Run tests
ctest --test-dir build --output-on-failure

# Install
cmake --install build --prefix /usr/local

# Generate compile database (IDE support)
cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
```

---

## Header File Best Practices

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

## Linting Philosophy

### Pre-loaded configs
All linting configs are pre-loaded in the container with best-practice rules.
They guide behavior but do NOT auto-run. Rules are documented in SKILL.md.

### What Claude should do:

**NEW files Claude writes:**
- Auto-lint with `gcc/g++ -Wall -Wextra -pedantic` before presenting to the user.
- Auto-fix is always safe here — these are Claude's own files.

**EXISTING code:**
- Do NOT touch unless Claude is explicitly tasked with it.
- If Claude notices linting issues while doing a task, report them and ask:
  "Found some linting issues in file.c, lint it?"
- Only apply linting/auto-fix when the user confirms (yes/no).
- Run lint read-only (check-only) first if the user is unsure.

### Key rules:
1. **Don't assume the user wants linting** — offer it, let them decide.
2. **Don't auto-lint on startup** — only report tool versions. Real linting
   happens when Claude is tasked with code quality work.
3. **Don't silently modify files** — ask before touching existing code.
   A file you didn't write is not yours to change without permission.
4. **Auto-lint what you write** — new files get auto-linted before presenting.

### Tool status:
```bash
# Linting tools are available and versions are reported on startup.
# They will NOT run automatically — they wait for Claude to be tasked.

[gcc] C/C++ dev tools ready:
  gcc: OK
  g++: OK
  gdb: OK
  valgrind: OK
  cppcheck: OK
  cmake: OK
  ninja: OK
  make: OK
  ... (and all other tools)

[gcc] Cross-compilation config: ~/gcc_cross.json (pre-loaded, best practices)
[gcc] Auto-lint: OFF at startup — will ask before linting code tasks
```

---

## Common Pitfalls

- **Missing headers**: Always check `-I` flags when `#include` fails. Relative and absolute include paths matter.
- **Linker errors**: Library order matters — put libraries after the object files that use them. `-l` flags must come after `-o` and object files.
- **Missing debug symbols**: `-g` flag is required for gdb to show source lines. Without it, gdb shows only addresses.
- **Undefined references**: Ensure the library is in the search path (`-L`) and linked by name (`-l`).
- **C vs C++ linkage**: Use `extern "C"` for C headers in C++ code. Check `nm` output with `-C` for demangled names.
- **Static vs dynamic linking**: `-static` forces static linking. Default is dynamic unless `-static` is specified or static `.a` files are used.
- **Include path precedence**: `-I` paths are searched before system paths. `-isystem` suppresses warnings for system headers.
- **Don't ignore warnings**: Use `-Wall -Wextra -Werror` in development. Warnings often indicate real bugs.
- **Don't over-optimize debug builds**: Use `-O0 -g` for debugging, `-O2 -g` for release with debug info.
- **Cross-compile sysroot**: Ensure the correct sysroot is set when cross-compiling. Use `-Bsysroot` flag.

---

## Anti-Patterns

- **Cognitive complexity > 50** — function should be split into smaller helpers.
- **Function length > 100 lines** — consider extracting helper functions.
- **Missing `-g` for debugging** — gdb cannot map addresses to source lines.
- **Wrong library order** — libraries must come after object files that use them.
- **Implicit conversions** — use `-Wconversion` to catch implicit conversions.
- **Shadowed variables** — use `-Wshadow` to catch variable shadowing.
- **Unchecked malloc returns** — always check for NULL after `malloc`/`calloc`/`realloc`.
- **Memory leaks** — use valgrind to detect leaks early.
- **Cross-compilation path issues** — ensure correct sysroot and include paths.
- **Missing `extern "C"`** — C headers in C++ code require `extern "C"` wrappers.

---

## Recommended Workflow for Claude-Driven C/C++ Development

```bash
# 1. Code: gcc/g++ provides real-time diagnostics
gcc -Wall -Wextra -pedantic -std=c17 -fsyntax-only file.c    # quick lint
g++ -Wall -Wextra -pedantic -std=c++20 -fsyntax-only file.cpp # quick lint

# 2. Before committing: run full lint stack (ask first for existing code)
gcc -Wall -Wextra -pedantic -Werror -std=c17 -fsyntax-only *.c
cppcheck --enable=all *.c
valgrind --leak-check=full ./app

# 3. Quick compile with debug
gcc -g -O0 -fno-omit-frame-pointer -DDEBUG -Wall -Wextra -std=c17 -o app *.c -lm -lpthread

# 4. Debug with gdb
gdb ./app
(gdb) run
(gdb) break main
(gdb) continue

# 5. Cross-compile
aarch64-linux-gnu-gcc -o app-arm64 main.c -static
mips64el-linux-gnuabi64-gcc -o app-mips64el main.c -static

# 6. Full CI-like check
gcc -Wall -Wextra -pedantic -Werror -std=c17 -fsyntax-only *.c && \
g++ -Wall -Wextra -pedantic -Werror -std=c++20 -fsyntax-only *.cpp && \
cppcheck --enable=all *.c *.h && \
valgrind --leak-check=full ./app
```

---

## Quick Reference

```bash
# === Compilation ===
gcc -Wall -Wextra -pedantic -O2 -std=c17 -g -o app main.c      # C compile
g++ -Wall -Wextra -pedantic -O2 -std=c++20 -g -o app main.cpp  # C++ compile
gcc -c -O2 -std=c17 main.c    # compile only
gcc -E main.c                  # preprocess only

# === Libraries ===
ar rcs lib.a obj1.o obj2.o   # create static library
gcc -shared -fPIC -o lib.so src.c  # create shared library
gcc -o app main.c -L. -lmylib -lm  # link libraries
LD_LIBRARY_PATH=. ./app      # set library path at runtime

# === Debugging ===
gdb ./app                    # start GDB
gdb -p <PID>                 # attach to process
gdb ./app core               # debug core dump
valgrind --leak-check=full ./app  # memory check

# === Cross-compile ===
aarch64-linux-gnu-gcc -o app-arm main.c
mips64el-linux-gnu-gcc -o app-mips main.c
riscv64-linux-gnu-gcc -o app-riscv main.c
tilegx-linux-gnu-gcc -o app-tilegx main.c

# === Static analysis ===
cppcheck --enable=all *.c    # comprehensive check
cppcheck --xml *.c           # XML output

# === Build systems ===
make all                     # build with make
make clean                   # clean build
cmake -B build -DCMAKE_BUILD_TYPE=Release  # configure CMake
cmake --build build          # build with CMake
ctest --test-dir build       # run tests

# === Inspection ===
nm app | grep undefined      # symbol inspection
readelf -s app | head        # ELF inspection
objdump -d app               # disassemble
size app                     # symbol sizes
strings app                  # extract strings
addr2line -e app 0x1234      # address to line

# === Config files ===
gcc_cross.json              # cross-compilation config (pre-loaded)
SKILL.md                    # this file (pre-loaded in superpowers)
gcc/gcdoc/                  # compiler, debugger, builds (pre-loaded)
gcc/shared/                 # libraries, errors, sources (pre-loaded)

# === Auto-Lint (opt-in) ===
gcc -Wall -Wextra -pedantic -Werror *.c          # lint C
g++ -Wall -Wextra -pedantic -Werror *.cpp        # lint C++
cppcheck *.c *.h                                   # static analysis
valgrind --leak-check=full ./app                  # memory check
```
