---
name: asm-claude-abliterated
description: Cross-architecture assembly dev stack with GCC, binutils, GDB, QEMU, and multi-arch toolchains for Claude-driven assembly development
---

# Assembly Dev Stack (claude-abliterated)

A complete assembly development environment on top of claude-abliterated:rocky10 with 14 tools and multi-architecture cross-compilation support.

## Tool Index

| Tool | Package | Role |
|------|---------|------|
| **gcc** | GCC 14.x | C compiler + assembler driver (as, cc, ld via gcc) |
| **as** | binutils 2.43 | GNU Assembler (gas) — direct .S/.s assembly |
| **ld** | binutils 2.43 | GNU Linker — link object files into executables |
| **objdump** | binutils 2.43 | Disassemble objects, show symbols, sections |
| **nm** | binutils 2.43 | List symbol table entries |
| **readelf** | binutils 2.43 | Display ELF file information |
| **objcopy** | binutils 2.43 | Copy and translate object files (binary, hex, srec) |
| **strip** | binutils 2.43 | Remove symbol table and relocations |
| **gdb** | GDB 16.x | GNU Debugger (breakpoints, step, inspect, core dumps) |
| **qemu-system** | QEMU 9.x | Full system emulation (multi-arch virtual machines) |
| **qemu-user** | QEMU 9.x | User-mode emulation (run binaries for other arches) |
| **make** | Make 4.4.1 | Build automation (Makefiles for assembly projects) |
| **ndisasm** | ndisasm 0.16.x | Universal disassembler (Intel and AT&T syntaxes) |
| **strings** | binutils 2.43 | List printable strings from object/binary files |

## Supported Architectures

| Architecture | Cross-prefix | QEMU System | Notes |
|--------------|-------------|-------------|-------|
| **x86_64** | (native) | qemu-system-x86_64 | Native host architecture |
| **x86** | i686-linux-gnu | qemu-system-i386 | 32-bit x86 |
| **ARM** | arm-linux-gnu | qemu-system-arm | ARM 32-bit (AArch32) |
| **ARM64** | aarch64-linux-gnu | qemu-system-aarch64 | AArch64 (ARM 64-bit) |
| **RISC-V** | riscv64-linux-gnu | qemu-system-riscv64 | RISC-V 64-bit |
| **RISC-V 32** | riscv32-linux-gnu | qemu-system-riscv32 | RISC-V 32-bit |
| **MIPS (BE)** | mips-linux-gnu | qemu-system-mips | MIPS 32-bit big-endian |
| **MIPS (LE)** | mipsel-linux-gnu | qemu-system-mipsel | MIPS little-endian |
| **MicroMIPS** | mips64-linux-gnuabi64 | qemu-system-mips64 | MicroMIPS |
| **PowerPC** | powerpc-linux-gnu | qemu-system-ppc | PowerPC 32-bit |
| **PowerPC 64** | powerpc64le-linux-gnu | qemu-system-ppc64 | PowerPC 64-bit little-endian |
| **Tile** | tile-linux-gnu | qemu-system-tilegx | Tilera TILE-Gx |
| **M68K** | m68k-linux-gnu | qemu-system-m68k | Motorola 68000 |
| **S390** | s390x-linux-gnu | qemu-system-s390x | IBM System z |
| **SH** | sh4-linux-gnu | qemu-system-sh4 | SuperH |

---

## Linting & Code Quality Philosophy — No Silent File-Touching

**Pre-loaded configs:** All linting configs are pre-loaded with best-practice rules.
They guide behavior but do NOT auto-run. Rules are documented below.

**What Claude should do:**

**NEW files Claude writes:**
- Auto-lint with `make` (check targets) and objdump/diff before presenting.
- Auto-fix is always safe here — these are Claude's own files.

**EXISTING code:**
- Do NOT touch unless Claude is explicitly tasked with it.
- If Claude notices linting issues while doing a task, report them and ask:
  "Found some assembly issues in file.s, review it?"
- Only apply linting/auto-fix when the user confirms (yes/no).
- Run lint read-only (check-only) first if the user is unsure.

**Key rules:**
1. **Don't assume the user wants linting** — offer it, let them decide.
2. **Don't auto-lint on startup** — only report tool versions. Real linting
   happens when Claude is tasked with code quality work.
3. **Don't silently modify files** — ask before touching existing code.
   A file you didn't write is not yours to change without permission.
4. **Auto-lint what you write** — new files get auto-linted before presenting.

**Tool status:**
```bash
# Linting tools are available and versions are reported on startup.
# They will NOT run automatically — they wait for Claude to be tasked.
```

---

## Core Toolchain

### gcc (C compiler + assembler driver)

```bash
# Compile assembly
gcc file.s                          # assemble and link
gcc -c file.s                       # assemble only (produce .o)
gcc -o program file.s               # assemble and link to executable

# Cross-architecture compilation
gcc -target x86_64-linux-gnu file.s -o program.x86_64
gcc -target aarch64-linux-gnu file.s -o program.aarch64
gcc -target arm-linux-gnu file.s -o program.arm
gcc -target riscv64-linux-gnu file.s -o program.riscv
gcc -target mips-linux-gnu file.s -o program.mips
gcc -target mipsel-linux-gnu file.s -o program.mipsel
gcc -target powerpc-linux-gnu file.s -o program.ppc
gcc -target s390x-linux-gnu file.s -o program.s390x

# Show commands without running
gcc -v file.s
gcc -print-prog-name=as             # show assembler path
gcc -print-prog-name=ld             # show linker path

# Options
gcc -O0 file.s  -o program          # no optimization
gcc -O2 file.s  -o program          # optimize
gcc -static file.s  -o program      # static linking
gcc -pie file.s   -o program        # position-independent executable
gcc -fno-pic file.s -o program      # non-position-independent

# Generate assembly from C
gcc -S file.c                        # produce .s from .c
gcc -S -O2 file.c                    # optimized assembly
gcc -fverbose-asm file.c             # verbose assembly output
gcc -masm=intel file.c               # Intel syntax (default: AT&T)

# Inline assembly
gcc -masm=intel -o program file.c    # Intel syntax for inline asm
gcc -Wa,-adhln -o program file.c     # show assembler listing
```

### as (GNU Assembler — gas)

```bash
# Assemble .s or .S files
as -o program.o file.s              # assemble to object file
as -o program.o file.S              # assemble with preprocessor

# Assembler options
as --gdwarf-5 file.s -o program.o   # debug info (DWARF 5)
as --64 file.s -o program.o         # 64-bit output (x86)
as -32   file.s -o program.o         # 32-bit output (x86)
as --fatal-warnings file.s           # treat warnings as errors
as --gdwarf-2 file.S                 # DWARF 2 debug info

# Cross-assembler
arm-linux-gnu-as   -o program.arm.o file.s
aarch64-linux-gnu-as  -o program.arm64.o file.s
riscv64-linux-gnu-as -o program.riscv.o file.s
mips-linux-gnu-as   -o program.mips.o file.s

# Listing file output
as --listing-all --listing-linenos file.s -o program.o -l listing.lst

# Macro definitions
as -DDEFINE_NAME file.s -o program.o
as -D"DEBUG=1" file.s -o program.o
as -UDEFINE_NAME file.s -o program.o  # undefine macro

# Preprocessing
as -x assembler-with-cpp file.S -o program.o
```

### ld (GNU Linker)

```bash
# Link object files
ld program.o utils.o -o program
ld program.o -o program

# Linking options
ld -o program program.o -lc          # link C library
ld --gc-sections program.o           # garbage collect unused sections
ld -s program.o -o program           # strip symbols
ld --trace program.o                 # show linking trace
ld -Map program.map program.o        # generate map file

# Linker scripts
ld -T linker.ld program.o -o program
ld --verbose                         # show default linker script

# Relocation
ld -r program.o -o program.reloc     # partial link (relocatable)
ld -r -o program.reloc program.o     # combine object files
```

---

## Debugging & Inspection

### gdb (GNU Debugger)

```bash
# Interactive debugging
gdb program                          # debug executable
gdb program core                     # debug with core dump
gdb -q program                       # quiet mode (skip banner)

# Debug with command-line options
gdb -ex "break main" -ex run program   # break at main, then run
gdb -ex "set architecture x86-64" program  # set target architecture
gdb -ex "display/i $pc" -ex run program  # disassemble at PC

# Assembly-level debugging
gdb> disassemble                      # show current function assembly
gdb> disassemble /m                   # mixed source + assembly
gdb> x/i $pc                          # examine instruction at PC
gdb> x/20i $pc                        # examine 20 instructions
gdb> info registers                   # show all registers
gdb> info registers rax rbx rcx rdx   # show specific registers
gdb> print $rsp                       # print register value
gdb> print/x $rax                     # print hex
gdb> print/d $rax                     # print decimal
gdb> print/b $rax                     # print binary

# Breakpoints and stepping
gdb> break start                      # breakpoint by symbol
gdb> break 42                         # breakpoint by line
gdb> break *0x401000                  # breakpoint by address
gdb> run                              # run to breakpoint
gdb> stepi                            # step one instruction
gdb> nexti                            # step one instruction (skip calls)
gdb> continue                         # continue
gdb> finish                           # run until return
gdb> quit                             # exit debugger

# Memory examination
gdb> x/16bx $rsp                     # examine 16 bytes (hex)
gdb> x/16iw $rsp                     # examine 16 instructions
gdb> x/8dw $rsp                      # examine 8 words (decimal)
gdb> x/s $rsi                        # examine string

# Core dumps
gdb program core.pid                 # debug core dump
gdb -c core.pid program               # load core dump

# Debugging options
gdb -ex "set pagination off" program  # disable pagination
gdb -ex "set confirm off" program     # disable confirmations
gdb -ex "set history save on" program  # save history
```

### gdb (advanced debugging)

```bash
# Architecture-specific debugging
gdb -ex "set architecture i386:x86-64" program
gdb -ex "set architecture aarch64" program
gdb -ex "set architecture riscv:rv64" program
gdb -ex "set architecture mips" program
gdb -ex "set architecture powerpc:ppc64" program

# Watchpoints (stop when memory changes)
gdb> watch variable_name
gdb> awatch *address                  # watch read or write

# Conditional breakpoints
gdb> break func if i > 10
gdb> ignore break_point 5             # ignore next 5 hits

# Debugging inline assembly
gdb> display/i $pc                     # auto-disassemble
gdb> layout asm                        # split terminal: assembly + source
gdb> layout regs                       # split terminal: registers + assembly
```

### addr2line (address to source line mapping)

```bash
# Convert addresses to source lines
addr2line -e program 0x401000          # find source for address
addr2line -e program -f 0x401000       # include function name
addr2line -e program -f -a 0x401000    # function + address

# Debugging symbol resolution
addr2line -e program -C -f 0x401000    # demangle C++ names
addr2line -e program -f -j .text 0x401000  # search specific section
```

### readelf (ELF file inspector)

```bash
# Full ELF file information
readelf -a program                      # all information
readelf -h program                      # header
readelf -S program                      # sections
readelf -s program                      # symbol table
readelf -l program                      # program headers
readelf -d program                      # dynamic section (DT_* entries)
readelf -p .text program                # raw section dump
readelf -p .rodata program              # raw section dump

# Architecture and properties
readelf -p program                      # display contents
readelf -W program                      # wide output (no wrapping)
readelf -p .note program program        # note section
```

---

## Disassembly & Object File Analysis

### objdump (disassemble and dump)

```bash
# Disassemble object file or executable
objdump -d program                      # disassemble code sections
objdump -d -j .text program             # disassemble specific section
objdump -d program > program.dis        # dump to file

# Detailed disassembly
objdump -d -S program                   # disassemble + source (if available)
objdump -t program                      # symbol table
objdump -h program                      # section headers
objdump -s program                      # dump all sections
objdump -x program                      # all of the above combined

# Architecture-specific disassembly
objdump -d -b i386 -m i386 program     # 32-bit x86
objdump -d -b x86 -m i386:x86-64 program  # 64-bit x86
objdump -d -b arm -m arm program        # ARM
objdump -d -b aarch64 -m aarch64 program  # AArch64
objdump -d -b mips -m mips program      # MIPS

# Disassembly for specific addresses
objdump -d --start-address=0x400000 program
objdump -d --stop-address=0x401000 program

# Instruction disassembly format
objdump -M intel -d program             # Intel syntax (default: AT&T)
objdump -M arm:v8 -d program            # ARM v8 specific
```

### nm (symbol table viewer)

```bash
# List symbols
nm program                              # all symbols
nm -n program                           # sorted by address
nm -u program                           # undefined symbols
nm -U program                           # defined symbols only

# Symbol types
nm -C program                           # demangle C++ names
nm -g program                           # external (global) symbols
nm -D program                           # dynamic symbols
nm --numeric-sort program               # sort by address

# Symbol filtering
nm program | grep main                  # search for symbol
nm program | grep -E "^[0-9a-f]+ T "   # text (code) symbols only
nm program | grep -E "^[0-9a-f]+ D "   # data (initialized) symbols
nm program | grep -E "^[0-9a-f]+ B "   # bss (uninitialized) symbols
```

### ndisasm (universal disassembler)

```bash
# Disassemble raw binary
ndisasm -b 64 program.bin               # 64-bit disassembly
ndisasm -b 32 program.bin               # 32-bit disassembly
ndisasm -b 16 program.bin               # 16-bit (real mode)
ndisasm -u program.bin                  # automatic format detection

# Disassembly output formats
ndisasm -e program.bin                  # with ELF-style addresses
ndisasm -s 0x100 program.bin            # set start address
ndisasm -o 0x7c00 program.bin           # set origin (boot sector)

# Syntax options
ndisasm -m intel program.bin            # Intel syntax
ndisasm -m att program.bin              # AT&T syntax

# Hex dump
ndisasm -x program.bin                  # hex dump
```

### strings (extract printable strings)

```bash
# List strings from object/binary files
strings program                         # all strings
strings -n 4 program                    # minimum 4 characters
strings -t d program                    # with decimal offsets
strings -t x program                    # with hex offsets
strings -e S program                    # UTF-16 strings only

# Filter by type
strings -f program                      # with filename prefix
strings program | grep -i "hello"       # search for string
```

### objcopy (object file converter)

```bash
# Convert to raw binary
objcopy -O binary program program.bin    # raw binary
objcopy -O ihex program program.hex      # Intel HEX format
objcopy -O srec program program.srec     # Motorola S-record

# Remove sections
objcopy --remove-section=.note program   # remove .note section
objcopy --only-keep-debug program        # keep only debug info
objcopy --strip-debug program            # remove debug info
objcopy --strip-unneeded program         # remove unneeded symbols

# Modify symbols
objcopy --redefine_SYM old_name=new_name program
objcopy --add-symbol new_name=.text:0x100 program
```

### strip (remove symbols)

```bash
# Strip symbols from executable
strip program                           # remove all symbols
strip --strip-unneeded program          # remove unneeded symbols
strip --only-keep-debug program         # keep only debug symbols
strip -g program                        # remove local symbols
strip -s program                        # silent (no output)
```

---

## Multi-Architecture Cross-Compilation

### Setting up cross-compilation

```bash
# Detect available cross-compilers
which arm-linux-gnu-gcc
which aarch64-linux-gnu-gcc
which riscv64-linux-gnu-gcc
which mips-linux-gnu-gcc
which mipsel-linux-gnu-gcc
which powerpc-linux-gnu-gcc
which powerpc64le-linux-gnu-gcc
which tile-linux-gnu-gcc
which s390x-linux-gnu-gcc
which m68k-linux-gnu-gcc
which sh4-linux-gnu-gcc

# Cross-assemble with prefix
arm-linux-gnu-as   -o program.arm.o   file.s
aarch64-linux-gnu-as  -o program.arm64.o file.s
riscv64-linux-gnu-as -o program.riscv.o file.s
mips-linux-gnu-as   -o program.mips.o file.s
powerpc-linux-gnu-gcc -o program.ppc file.s
s390x-linux-gnu-gcc -o program.s390x file.s

# Cross-link
arm-linux-gnu-gcc  -o program.arm program.arm.o
aarch64-linux-gnu-gcc  -o program.arm64 program.arm64.o
riscv64-linux-gnu-gcc -o program.riscv program.riscv.o
mips-linux-gnu-gcc -o program.mips program.mips.o
```

### QEMU user-mode emulation (run cross-architecture binaries)

```bash
# Install QEMU user static binaries
apt-get install qemu-user-static          # Debian/Ubuntu
dnf install qemu-user-static              # Rocky/RHEL

# Run ARM binary on x86_64 host
qemu-aarch64-static program.arm64
qemu-arm-static program.arm

# Run RISC-V binary
qemu-riscv64-static program.riscv

# Run MIPS binary
qemu-mips-static program.mips
qemu-mipsel-static program.mipsel

# Run PowerPC binary
qemu-ppc-static program.ppc
qemu-ppc64le-static program.ppc64le

# Run TileGX binary
qemu-tilegx-static program.tilegx

# Run S390 binary
qemu-s390x-static program.s390x
```

### QEMU system emulation (full VM)

```bash
# Boot virtual machine for specific architecture
qemu-system-x86_64 -kernel vmlinuz -hda rootfs.img
qemu-system-arm -M virt -kernel zImage -append "console=ttyAMA0"
qemu-system-aarch64 -M virt -kernel zImage -append "console=ttyS0"
qemu-system-riscv64 -M virt -kernel kernel.img
qemu-system-mips -M mips32 -kernel vmlinuz
qemu-system-ppc -M powernv -kernel vmlinuz
qemu-system-s390x -M s390-ccw-virtio -kernel vmlinuz
qemu-system-tilegx -M tilegx -kernel kernel.img

# Common options
qemu-system-x86_64 -smp 2 -m 512 -nographic -serial mon:stdio
qemu-system-x86_64 -netdev user,id=n1 -device e1000,netdev=n1
qemu-system-x86_64 -enable-kvm          # hardware virtualization
```

---

## Linting & Code Quality for Assembly

### Linting Philosophy — No Silent File-Touching

**Pre-loaded configs:** All linting configs are pre-loaded with best-practice rules.
They guide behavior but do NOT auto-run.

**What Claude should do:**

**NEW files Claude writes:**
- Auto-lint with `make` (check targets) and objdump/diff before presenting.
- Auto-fix is always safe here — these are Claude's own files.
- Check architecture-specific details (instruction encoding, alignment).

**EXISTING code:**
- Do NOT touch unless Claude is explicitly tasked with it.
- If Claude notices linting issues while doing a task, report them and ask:
  "Found some assembly issues in file.s, lint it?"
- Only apply linting/auto-fix when the user confirms (yes/no).
- Run lint read-only (check-only) first if the user is unsure.

**Key rules:**
1. **Don't assume the user wants linting** — offer it, let them decide.
2. **Don't auto-lint on startup** — only report tool versions.
3. **Don't silently modify files** — ask before touching existing code.
4. **Auto-lint what you write** — new files get auto-linted before presenting.

### Assembly-Specific Quality Checks

```bash
# Assemble with warnings
gcc -c -Wall file.s

# Check alignment (8-byte for SSE, 16-byte for AVX)
objdump -d program | grep -E "nop|align|\.align"

# Verify section layout
readelf -S program

# Check symbol table
nm -n program

# Disassemble and verify
objdump -d program > disassembly.txt

# Check for common issues
# - Unaligned loads/stores
# - Missing .align directives
# - Register clobbers in function calls
# - Stack frame setup/teardown
# - Correct calling convention (System V ABI)

# ELF verification
readelf -h program | grep Type           # check ELF type (EXEC, DYN)
readelf -h program | grep Machine        # check target machine
readelf -d program                       # check dynamic dependencies
```

### Assembly Code Quality Checklist

Before presenting assembly code:

- [ ] `.file`, `.text`, `.data`, `.bss` directives present
- [ ] `.globl` / `.global` for exported symbols
- [ ] `.align` directives for data alignment
- [ ] `.L` labels for local labels (avoid name conflicts)
- [ ] `.type` / `.size` for function metadata
- [ ] Stack frame: `%rsp`/`%rbp` push/pop or direct manipulation
- [ ] Calling convention compliance (System V AMD64 ABI)
- [ ] Register clobbers documented in comments
- [ ] No stale or unused registers
- [ ] `.cfi_*` directives for unwinding (if needed)
- [ ] Section ordering: `.text`, `.data`, `.bss`, `.rodata`

---

## Development Workflow

### Recommended Workflow for Claude-Driven Assembly Development

```bash
# 1. Assemble and check
gcc -c file.s                             # assemble
gcc -c file.s -o file.o                  # to specific output
objdump -d file.o                         # disassemble to verify

# 2. Link and run
gcc file.s -o program                     # assemble + link
./program                                 # run

# 3. Debug
gdb program                               # interactive debugging
gdb -ex run -ex "display/i $pc" program   # run + disassemble

# 4. Multi-architecture cross-compile
gcc -target x86_64-linux-gnu file.s -o program.x86_64
gcc -target aarch64-linux-gnu file.s -o program.aarch64
gcc -target arm-linux-gnu file.s -o program.arm
gcc -target riscv64-linux-gnu file.s -o program.riscv

# 5. Analyze output
readelf -a program                        # ELF inspection
nm program                                # symbols
objdump -d program                        # disassembly
strings program                           # embedded strings

# 6. Full check
make check                                # run full lint/build
```

### Recommended Makefile Patterns

```makefile
# Standard assembly Makefile

CC = gcc
AS = as
LD = ld
AR = ar

# Architecture-specific flags
ARCH_FLAGS = -masm=intel                  # Intel syntax
DEBUG_FLAGS = -gdwarf-5 -g                # debug info
OPT_FLAGS = -O2                           # optimization

# Object files
SRCS = start.s main.s utils.s
OBJS = $(SRCS:.s=.o)
TARGET = program

# Phony targets
.PHONY: all clean check disasm

# Default target
all: $(TARGET)

# Link
$(TARGET): $(OBJS)
	$(CC) $(OPT_FLAGS) -o $@ $^

# Assemble
%.o: %.s
	$(AS) $(ARCH_FLAGS) $(DEBUG_FLAGS) -c $< -o $@

# Check (lint)
check: $(TARGET)
	readelf -h $(TARGET)
	nm $(TARGET)
	objdump -d $(TARGET) | head -50

# Disassemble to file
disasm: $(TARGET)
	objdump -d -S $(TARGET) > $(TARGET).dis

# Clean
clean:
	rm -f $(OBJS) $(TARGET) $(TARGET).dis

# Install (copy to /usr/local/bin)
install: $(TARGET)
	install -m 755 $(TARGET) /usr/local/bin/

# Test (if QEMU available)
test: $(TARGET)
	./$(TARGET)
	which qemu-x86_64-static && qemu-x86_64-static ./$@ || true
```

---

## Assembly Syntax Reference

### AT&T vs Intel Syntax

```bash
# AT&T (default):   movl $1, %rax    — immediate to register
# Intel:             mov rax, 1         — register to immediate

# Toggle syntax with gcc
gcc -masm=intel file.s -o program       # Intel syntax
gcc -masm=att file.s -o program          # AT&T syntax

# Toggle with as
as --prefix _ file.s -o program.o        # underscore prefix (Unix)
as --prefix _file file.s -o program.o    # prefixed symbol names
```

### Common Assembly Conventions

| Convention | Details |
|-----------|---------|
| **File extension** | `.s` = preprocessed, `.S` = needs preprocessor |
| **Comments** | `#` or `;` (both work in gas) |
| **Immediate** | `$value` (AT&T), `value` (Intel) |
| **Register** | `%reg` (AT&T), `reg` (Intel) |
| **Memory** | `disp(base, index, scale)` (AT&T), `[base+index*scale+disp]` (Intel) |
| **Labels** | `label:` (AT&T), `label:` (Intel) |
| **Directives** | `.globl`, `.align`, `.word`, `.long`, `.quad` |
| **Calle-saved** | `%rbx, %rbp, %r12-%r15` (x86_64 System V) |
| **Callee-saved** | `%rax, %rcx, %rdx, %rsi, %rdi, %r8-%r11` (x86_64 System V) |
| **Stack args** | `%rdi, %rsi, %rdx, %rcx, %r8, %r9` (first 6 args) |

---

## Anti-Patterns

- **Stack misalignment** — 16-byte alignment required for SSE/AVX before call
- **Wrong calling convention** — follow System V ABI for x86_64/Linux
- **Unoptimized register allocation** — don't spill registers unnecessarily
- **Missing `.cfi_*` directives** — needed for proper unwinding and backtraces
- **Inconsistent label scoping** — use `.L` prefix for local labels
- **Missing section directives** — always use `.text`, `.data`, `.bss`
- **Unaligned data** — use `.align` before data declarations
- **Wrong operand size** — `movl` vs `movw` vs `movb` — ensure correct size
- **Not checking return values** — functions should check syscall return in `%rax`/`%eax`
- **Not preserving clobbered registers** — push/pop or save/restore across calls
- **Mixed syntax** — keep AT&T and Intel consistent within a file

---

## Linting Commands Quick Reference

```bash
# === Assembly quality ===
gcc -c file.s                              # assemble with checks
objdump -d file.o                          # disassemble to verify
readelf -a program                         # ELF inspection
nm program                                 # symbols

# === Architecture-specific ===
objdump -d -b arm -m arm program.arm       # ARM disassembly
objdump -d -b mips -m mips program.mips    # MIPS disassembly
readelf -h program | grep Machine           # check target

# === Cross-compilation ===
which arm-linux-gnu-gcc                    # find cross-compiler
qemu-aarch64-static program.arm64          # run cross-arch binary

# === Debugging ===
gdb program                                 # interactive
gdb -ex run -ex "display/i $pc" program    # run + disassemble
addr2line -e program 0x401000              # resolve address

# === Analysis ===
objdump -d program > program.dis            # disassemble to file
strings -n 4 program                        # extract strings
objcopy -O binary program program.bin        # raw binary
ndisasm -b 64 program.bin                   # universal disasm
```
