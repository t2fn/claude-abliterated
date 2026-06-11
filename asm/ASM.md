# ASM.md — Cross-Architecture Assembly Development Reference

## Purpose

This file is the deep-dive reference for assembly development in the asm-claude container.
It complements SKILL.md with detailed tooling information, architecture specifics, and
practical examples for Claude-driven assembly development.

---

## Container Overview

| Component | Version | Location |
|-----------|---------|----------|
| **Base** | claude-abliterated:rocky10 | docker.io/t2fn |
| **GCC** | 14.x (via dnf) | /usr/bin/gcc |
| **Binutils** | 2.43 (via dnf) | /usr/bin (as, ld, objdump, nm, readelf, objcopy, strip, strings) |
| **GDB** | 16.3 (via dnf) | /usr/bin/gdb |
| **QEMU System** | 9.2 (via dnf) | /usr/bin/qemu-system-* |
| **QEMU User** | 9.2 (via dnf) | /usr/bin/qemu-*-static |
| **Make** | 4.4.1 (via dnf) | /usr/bin/make |
| **ndisasm** | 0.16.x (via dnf) | /usr/bin/ndisasm |

---

## Architecture Deep-Dive

### x86_64 (Native)

```bash
# Native compilation
gcc -masm=intel -o program file.s
gcc -c -O2 file.s -o file.o

# Assembly directives
.file   "file.s"
.globl  main
.type   main, @function
.align  16
```

**Register naming:** `%rax`, `%rbx`, `%rcx`, `%rdx`, `%rsi`, `%rdi`, `%rbp`, `%rsp`, `%r8`-`%r15`

**Syscall convention:** `%rax` = syscall number, `%rdi`-`%r8` = args 1-6

### ARM (AArch32)

```bash
# Cross-compile
arm-linux-gnu-gcc -o program.arm file.s
arm-linux-gnu-as -o file.o file.s

# Common instructions
# mov r0, #1       — move immediate
# str r0, [r1]     — store register
# ldr r0, [r1]     — load register
# bl function       — branch and link
```

**Register naming:** `r0`-`r15` (r13=sp, r14=lr, r15=pc)

**Calling convention:** args in r0-r3, result in r0

### ARM64 (AArch64)

```bash
# Cross-compile
aarch64-linux-gnu-gcc -o program.arm64 file.s
aarch64-linux-gnu-as -o file.o file.s

# Common instructions
# mov x0, #1       — move immediate (64-bit)
# str x0, [x1]     — store register (64-bit)
# ldr x0, [x1]     — load register (64-bit)
# bl function       — branch and link
```

**Register naming:** `x0`-`x30` (64-bit), `w0`-`w30` (32-bit)

**Calling convention:** args in x0-x7, result in x0

### RISC-V (RV64)

```bash
# Cross-compile
riscv64-linux-gnu-gcc -o program.riscv file.s
riscv64-linux-gnu-as -o file.o file.s

# Common instructions
# li a0, 1         — load immediate
# sw a0, 0(a1)     — store word
# lw a0, 0(a1)     — load word
# call function     — call function
```

**Register naming:** `a0`-`a7` (args/result), `t0`-`t6` (temporaries), `s0`-`s11` (saved)

**Calling convention:** args in a0-a7, result in a0

### MIPS (Big-Endian)

```bash
# Cross-compile
mips-linux-gnu-gcc -o program.mips file.s
mips-linux-gnu-as -o file.o file.s

# Common instructions
# li $v0, 1        — load immediate
# sw $t0, 0($a0)   — store word
# lw $t0, 0($a0)   — load word
# jal function      — jump and link
```

**Register naming:** `$v0`-`$v1` (results), `$a0`-`$a3` (args), `$t0`-`$t9` (temps)

**Calling convention:** args in $a0-$a3, result in $v0

### MIPS Little-Endian

Same as MIPS but with little-endian byte order.

```bash
mipsel-linux-gnu-gcc -o program.mipsel file.s
```

### PowerPC (PPC32)

```bash
powerpc-linux-gnu-gcc -o program.ppc file.s
powerpc-linux-gnu-as -o file.o file.s

# Common instructions
# li r3, 1         — load immediate
# stw r3, 0(r4)    — store word
# lwz r3, 0(r4)    — load word
# bl function       — branch and link
```

**Register naming:** `r0`-`r31`, `cr0`-`cr7` (condition registers), `lr` (link register), `ctr` (count register)

### PowerPC 64LE

```bash
powerpc64le-linux-gnu-gcc -o program.ppc64le file.s
```

### Tile-GX

```bash
tile-linux-gnu-gcc -o program.tilegx file.s
tile-linux-gnu-as -o file.o file.s
```

### M68K (Motorola 68000)

```bash
m68k-linux-gnu-gcc -o program.m68k file.s
m68k-linux-gnu-as -o file.o file.s
```

### S390x (IBM System z)

```bash
s390x-linux-gnu-gcc -o program.s390x file.s
s390x-linux-gnu-as -o file.o file.s
```

### SH (SuperH)

```bash
sh4-linux-gnu-gcc -o program.sh file.s
sh4-linux-gnu-as -o file.o file.s
```

---

## Tool Reference

### GCC (C Compiler + Assembler Driver)

```bash
# Basic assembly compilation
gcc file.s -o program                    # assemble and link
gcc -c file.s -o file.o                  # assemble only
gcc -o program file.s utils.s            # multiple source files
gcc -O2 -o program file.s                # optimized

# Architecture specification
gcc -target x86_64-linux-gnu file.s -o program.x86_64
gcc -target aarch64-linux-gnu file.s -o program.arm64
gcc -target arm-linux-gnu file.s -o program.arm
gcc -target mips-linux-gnu file.s -o program.mips
gcc -target mipsel-linux-gnu file.s -o program.mipsel
gcc -target powerpc-linux-gnu file.s -o program.ppc

# Syntax control
gcc -masm=intel file.s -o program.intel  # Intel syntax
gcc -masm=att file.s -o program.att      # AT&T syntax (default)

# Debug and optimization
gcc -g -c file.s -o file.o               # with debug info
gcc -gdwarf-5 -c file.s -o file.o        # DWARF 5 debug
gcc -O0 -c file.s -o file.o              # no optimization
gcc -O2 -c file.s -o file.o              # standard optimization
gcc -Os -c file.s -o file.o              # optimize for size

# Linker control
gcc -static file.s -o program            # static linking
gcc -pie file.s -o program               # position-independent
gcc -nostdlib file.s -o program          # no standard libraries
gcc -shared file.s -o program.so         # shared library

# Show internal commands
gcc -v file.s                            # verbose
gcc -print-prog-name=as                  # show assembler path
gcc -print-prog-name=ld                  # show linker path
gcc -print-search-dirs                   # show library paths

# Generate assembly from C
gcc -S file.c                            # produce .s from .c
gcc -S -O2 file.c                        # optimized assembly
gcc -S -fverbose-asm file.c              # verbose comments in assembly
gcc -S -masm=intel file.c                # Intel syntax in generated assembly

# Inline assembly
gcc -c file.c -o file.o                  # compile C with inline asm
gcc -fno-asynchronous-unwind-tables file.c  # disable unwinding for raw asm
```

### GNU Assembler (gas)

```bash
# Basic assembly
as file.s -o file.o                      # assemble
as -o file.o file.S                      # with preprocessor (.S files)

# Architecture-specific assembly
as --32 file.s -o file.o                 # 32-bit output (x86)
as --64 file.s -o file.o                 # 64-bit output (x86)
as -m elf_x86_64 file.s -o file.o       # explicit format
as -m elf_i386 file.s -o file.o         # 32-bit ELF
as -m elf32lriscv file.s -o file.o      # RISC-V 32-bit
as -m elf64lriscv file.s -o file.o      # RISC-V 64-bit
as -m elf32lsmi file.s -o file.o        # MIPS little-endian
as -m elf32bms file.s -o file.o         # MIPS big-endian

# Debug information
as --gdwarf-2 file.s -o file.o           # DWARF 2
as --gdwarf-5 file.s -o file.o           # DWARF 5
as -g file.s -o file.o                   # all debug info

# Preprocessor control
as -x assembler-with-cpp file.S -o file.o  # preprocess .S files
as -DDEBUG=1 file.s -o file.o            # define macros
as -UDEBUG file.s -o file.o              # undefine macros
as -include file.h file.s -o file.o      # include header
as -I include/ file.s -o file.o          # include directory

# Listing output
as --listing-all --listing-linenos file.s -o file.o -l listing.lst  # full listing
as --listing-contaminated file.s -o file.o -l listing.lst           # contaminated lines

# Symbol naming
as --prefix _ file.s -o file.o           # Unix-style underscore prefix
as --64 --prefix _ file.s -o file.o      # 64-bit with prefix
```

### GNU Linker (ld)

```bash
# Basic linking
ld program.o -o program                  # link with defaults
ld program.o utils.o -o program          # multiple object files
ld program.o -o program                  # default entry point

# Entry point control
ld --entry=main program.o -o program     # set entry point
ld -e main program.o -o program          # short form

# Output control
ld -o program program.o                  # explicit output
ld -o program --oformat=elf64-x86-64 program.o  # explicit format

# Section control
ld --gc-sections program.o -o program    # garbage collect unused sections
ld -r program.o -o program.reloc         # relocatable output
ld -b binary program.bin -o program      # include binary blob
ld --build-id program.o -o program       # generate build ID

# Library paths
ld -L /usr/lib -l m program.o -o program  # link math library
ld -rpath /usr/lib program.o -o program   # runtime library path

# Map file
ld -Map program.map program.o -o program  # generate map file
ld --trace program.o -o program           # trace linking

# Strip symbols
ld -s program.o -o program               # strip all symbols
ld --strip-all program.o -o program      # same as -s
ld -S program.o -o program               # keep debug symbols

# Relocation and partial linking
ld -r program1.o program2.o -o combined.o  # partial link
ld -r --relocatable program.o -o program.reloc
```

### GDB (GNU Debugger)

```bash
# Basic debugging
gdb program                              # interactive
gdb -q program                           # quiet mode
gdb -x commands.gdb program              # execute commands file
gdb -ex "break main" -ex run program     # one-line: break at main
gdb -batch -ex run -ex quit program      # non-interactive

# Architecture-specific
gdb -ex "set architecture i386:x86-64" program
gdb -ex "set architecture aarch64" program
gdb -ex "set architecture arm" program
gdb -ex "set architecture riscv:rv64" program
gdb -ex "set architecture mips" program
gdb -ex "set architecture powerpc:ppc64" program
gdb -ex "set architecture m68k" program
gdb -ex "set architecture tilegx" program

# Breakpoints and watches
gdb> break main                          # by symbol name
gdb> break *0x401000                     # by address
gdb> break 42                            # by source line
gdb> break _start                        # program entry point
gdb> watch variable_name                 # data watchpoint
gdb> awatch address                      # address watchpoint (read+write)
gdb> rwatch variable                     # read watchpoint
gdb> delete breakpoints                   # clear all breakpoints
gdb> clear main                          # clear breakpoint by name

# Stepping and execution
gdb> run                                  # run to next breakpoint
gdb> continue                             # continue after breakpoint
gdb> next                                 # step over (skip function calls)
gdb> step                                 # step into
gdb> nexti                               # step one instruction (over calls)
gdb> stepi                               # step one instruction (into calls)
gdb> finish                              # run until function return
gdb> quit                                # exit

# Assembly inspection
gdb> disassemble                          # disassemble current function
gdb> disassemble /m                       # mixed source and assembly
gdb> disassemble 0x401000, 0x401100       # disassemble address range
gdb> x/20i $pc                           # examine 20 instructions at PC
gdb> x/i $pc                             # examine instruction at PC
gdb> x/16bx $sp                          # examine 16 bytes (hex) at SP
gdb> x/8dw $sp                           # examine 8 words (decimal) at SP
gdb> x/s $rsi                            # examine string at RSI
gdb> x/4gx $sp                           # examine 4 double-words (hex) at SP

# Register operations
gdb> info registers                       # show all registers
gdb> info registers rax rbx rcx rdx       # show specific registers
gdb> print $rax                           # print register value
gdb> print/x $rax                         # hex
gdb> print/d $rax                         # decimal
gdb> print/b $rax                         # binary
gdb> set $pc = 0x401000                  # set register value
gdb> display/i $pc                        # auto-display instruction at PC
gdb> undisplay                            # stop auto-display

# Memory inspection
gdb> x 0x401000                          # examine memory at address
gdb> x/20xw 0x401000                     # 20 hex words
gdb> x/10ib 0x401000                     # 10 hex bytes
gdb> x/8s 0x401000                       # 8 strings
gdb> x/4gx 0x401000                      # 4 hex doubles (8-byte)
gdb> compare 0x401000 0x500000 1024       # compare two memory regions
gdb> search 0x401000, 0x500000 "hello"   # search for string

# Core dumps
gdb program core.pid                     # debug core dump
gdb -c core.pid program                   # load core dump

# Breakpoint control
gdb> ignore 1 5                          # ignore next 5 hits of breakpoint 1
gdb> condition 1 i > 10                  # conditional breakpoint
gdb> catch syscall                       # catch all syscalls
gdb> catch syscall read                  # catch specific syscall
gdb> tbreak main                         # temporary breakpoint

# Layout modes
gdb> layout asm                           # split: assembly view
gdb> layout regs                          # split: registers + assembly
gdb> layout src                           # split: source + assembly
gdb> layouts                              # show current layout

# Debug options
gdb -ex "set pagination off" program      # disable pagination
gdb -ex "set confirm off" program         # skip confirmations
gdb -ex "set history save on" program     # save command history
gdb -ex "set print pretty on" program     # pretty print
gdb -ex "set disassembly-flavor intel" program  # intel disassembly flavor
```

### QEMU (Multi-Arch Emulation)

```bash
# QEMU System (full VM per architecture)
qemu-system-x86_64 -kernel vmlinuz -hda rootfs.img -nographic
qemu-system-x86_64 -smp 2 -m 512 -nographic -serial mon:stdio
qemu-system-x86_64 -enable-kvm           # hardware virtualization
qemu-system-x86_64 -netdev user,id=n1 -device e1000,netdev=n1
qemu-system-arm -M virt -kernel zImage -append "console=ttyAMA0"
qemu-system-aarch64 -M virt -kernel zImage -append "console=ttyS0"
qemu-system-riscv64 -M virt -kernel kernel.img
qemu-system-mips -M mips32 -kernel vmlinuz -nographic
qemu-system-ppc -M powernv -kernel vmlinuz
qemu-system-ppc64 -M powernv -kernel vmlinuz
qemu-system-tilegx -M tilegx -kernel kernel.img
qemu-system-s390x -M s390-ccw-virtio -kernel vmlinuz
qemu-system-m68k -M mcfv4e -kernel kernel.img
qemu-system-sh4 -kernel kernel.img

# QEMU User (cross-arch binary execution)
qemu-x86_64-static program               # x86_64 binary
qemu-i386-static program                 # 32-bit x86 binary
qemu-arm-static program.arm              # ARM binary
qemu-aarch64-static program.arm64        # ARM64 binary
qemu-riscv64-static program.riscv        # RISC-V 64-bit
qemu-riscv32-static program.riscv32      # RISC-V 32-bit
qemu-mips-static program.mips            # MIPS big-endian
qemu-mipsel-static program.mipsel        # MIPS little-endian
qemu-ppc-static program.ppc              # PowerPC 32-bit
qemu-ppc64le-static program.ppc64le      # PowerPC 64-bit LE
qemu-tilegx-static program.tilegx        # Tile-GX
qemu-s390x-static program.s390x          # S390x
qemu-sh4-static program.sh               # SuperH
```

### Binutils (Object File Analysis)

```bash
# objdump — disassemble and inspect
objdump -d program                       # disassemble code
objdump -d -j .text program              # specific section
objdump -d program > program.dis         # dump to file
objdump -d -S program                    # disasm + source (if available)
objdump -t program                       # symbol table
objdump -h program                       # section headers
objdump -x program                       # all above combined
objdump -s program                       # raw section dump
objdump --start-address=0x400000 -d program  # start from address
objdump --stop-address=0x401000 -d program   # stop at address
objdump -M intel -d program              # Intel syntax
objdump -b i386 -m i386 -d program       # explicit 32-bit x86
objdump -b x86 -m i386:x86-64 -d program  # explicit 64-bit x86
objdump -b arm -m arm -d program.arm     # ARM disassembly
objdump -b mips -m mips -d program.mips  # MIPS disassembly

# nm — symbol table
nm program                               # all symbols
nm -n program                            # sorted by address
nm -u program                            # undefined symbols
nm -C program                            # demangle C++
nm -g program                            # global symbols only
nm -D program                            # dynamic symbols
nm --numeric-sort program                # numeric sort
nm program | grep " T "                  # text (code) symbols
nm program | grep " D "                # data (initialized) symbols
nm program | grep " B "                # BSS (uninitialized) symbols

# readelf — ELF file inspection
readelf -a program                       # all information
readelf -h program                       # ELF header
readelf -S program                       # sections
readelf -s program                       # symbol table
readelf -l program                       # program headers
readelf -d program                       # dynamic section
readelf -p .text program                 # raw section dump
readelf -p .rodata program               # raw section dump
readelf -W program                       # wide output (no wrapping)
readelf -p program                       # display contents
readelf -h program | grep Machine        # target architecture
readelf -h program | grep Type           # file type (EXEC, DYN)
readelf -d program                       # dynamic dependencies

# objcopy — object file conversion
objcopy -O binary program program.bin     # raw binary
objcopy -O ihex program program.hex       # Intel HEX
objcopy -O srec program program.srec      # Motorola S-record
objcopy -O elf64-x86-64 program program.elf  # ELF output
objcopy --strip-debug program             # remove debug info
objcopy --strip-unneeded program          # remove unneeded symbols
objcopy --only-keep-debug program         # keep only debug
objcopy --remove-section=.note program    # remove section
objcopy --redefine_SYM old=new program    # redefine symbol
objcopy --add-symbol new=.text:0x100 program  # add symbol

# strip — remove symbols
strip program                            # remove all symbols
strip --strip-unneeded program           # remove unneeded
strip --only-keep-debug program          # keep debug symbols
strip -g program                         # remove local symbols
strip -s program                         # silent

# strings — extract strings
strings program                          # all strings
strings -n 4 program                     # minimum 4 chars
strings -t d program                     # decimal offsets
strings -t x program                     # hex offsets
strings -e S program                     # UTF-16 strings
strings -f program                       # with filename prefix
strings program | grep hello             # search strings

# addr2line — address to source line
addr2line -e program 0x401000            # address to line
addr2line -e program -f 0x401000         # with function name
addr2line -e program -C -f 0x401000      # demangle names
addr2line -e program -f -j .text 0x401000  # specific section

# ndisasm — universal disassembler
ndisasm -b 64 program.bin                # 64-bit disassembly
ndisasm -b 32 program.bin                # 32-bit disassembly
ndisasm -b 16 program.bin                # 16-bit real mode
ndisasm -u program.bin                   # auto-detect format
ndisasm -e program.bin                   # ELF-style addresses
ndisasm -o 0x7c00 program.bin            # origin (boot sector)
ndisasm -m intel program.bin             # Intel syntax
ndisasm -m att program.bin               # AT&T syntax
ndisasm -x program.bin                   # hex dump

# make — build automation
make                                     # build all
make clean                               # remove build artifacts
make check                               # run checks
make disasm                              # generate disassembly
make CFLAGS=-O2                          # pass extra flags
```

---

## Cross-Compilation Reference

### Available Cross-Compilers

```bash
# Check which cross-compilers are installed
which arm-linux-gnu-gcc
which aarch64-linux-gnu-gcc
which riscv64-linux-gnu-gcc
which riscv32-linux-gnu-gcc
which mips-linux-gnu-gcc
which mipsel-linux-gnu-gcc
which powerpc-linux-gnu-gcc
which powerpc64le-linux-gnu-gcc
which tile-linux-gnu-gcc
which s390x-linux-gnu-gcc
which m68k-linux-gnu-gcc
which sh4-linux-gnu-gcc
```

### Cross-Compilation Workflow

```bash
# 1. Write architecture-independent assembly
# Use .macro, .equ, and conditional assembly where possible

# 2. Cross-assemble
arm-linux-gnu-as    -o file.arm.o   file.s
aarch64-linux-gnu-as  -o file.arm64.o file.s
riscv64-linux-gnu-as -o file.riscv.o file.s
mips-linux-gnu-as   -o file.mips.o  file.s
powerpc-linux-gnu-gcc -c -o file.ppc.o file.s

# 3. Cross-link
arm-linux-gnu-gcc   -o program.arm   file.arm.o
aarch64-linux-gnu-gcc  -o program.arm64 file.arm64.o
riscv64-linux-gnu-gcc -o program.riscv file.riscv.o
mips-linux-gnu-gcc -o program.mips   file.mips.o

# 4. Verify
file program.arm          # check binary type
readelf -h program.arm    # check ELF header
objdump -d -b arm -m arm program.arm  # ARM disassembly
readelf -h program.arm | grep Machine  # check target machine

# 5. Test with QEMU
qemu-arm-static program.arm
qemu-aarch64-static program.arm64
qemu-riscv64-static program.riscv
qemu-mips-static program.mips
qemu-ppc-static program.ppc

# 6. Run natively (if on target architecture)
./program.arm             # runs natively on ARM
```

### Cross-Compiler Flags

```bash
# Architecture-specific flags
arm-linux-gnu-gcc   -march=armv7-a -mfloat-abi=hard   file.s -o program.arm
aarch64-linux-gnu-gcc -march=armv8-a                   file.s -o program.arm64
riscv64-linux-gnu-gcc -march=rv64imafdc                file.s -o program.riscv
mips-linux-gnu-gcc   -mips32 -EB                         file.s -o program.mips
mipsel-linux-gnu-gcc -mips32 -EL                         file.s -o program.mipsel
powerpc-linux-gnu-gcc -mcpu=powerpc                      file.s -o program.ppc
powerpc64le-linux-gnu-gcc -mcpu=powerpc64le              file.s -o program.ppc64le
```

---

## Assembly Development Best Practices

### File Organization

```
.project/
├── Makefile              # Build rules
├── linker.ld             # Linker script
├── src/
│   ├── start.s           # Entry point
│   ├── main.s            # Main logic
│   └── utils.s           # Utility functions
├── include/
│   └── constants.inc     # Macro definitions
├── program               # Output executable
├── program.dis           # Disassembly
├── program.map           # Link map
└── listing.lst           # Assembler listing
```

### Calling Convention (System V AMD64 ABI)

| Register | Purpose | Preserved? |
|----------|---------|------------|
| `%rax` | Return value / syscall # | Caller-saved |
| `%rcx` | 4th arg | Caller-saved |
| `%rdx` | 3rd arg | Caller-saved |
| `%rsi` | 2nd arg | Caller-saved |
| `%rdi` | 1st arg | Caller-saved |
| `%r8` | 5th arg | Caller-saved |
| `%r9` | 6th arg | Caller-saved |
| `%rbx` | Local | Callee-saved |
| `%rbp` | Frame pointer | Callee-saved |
| `%rsp` | Stack pointer | Callee-saved |
| `%r10-%r11` | Temp | Caller-saved |
| `%r12-%r15` | Local | Callee-saved |

### Common Assembly Patterns

```nasm
# Function prologue
fn_name:
    push    %rbp
    mov     %rsp, %rbp
    push    %rbx                # save callee-saved
    sub     $16, %rsp           # allocate stack space

    # function body
    movl    $1, %edi            # arg 1
    call    helper

    # epilogue
    add     $16, %rsp
    pop     %rbx                # restore callee-saved
    pop     %rbp
    ret

# Loop pattern
loop_start:
    cmp     $10, %edi
    jge     loop_end
    # body
    inc     %edi
    jmp     loop_start
loop_end:

# Syscall (x86_64 Linux)
    movl    $1, %rax            # sys_write
    movl    $1, %rdi            # stdout
    lea     msg(%rip), %rsi     # pointer
    movl    $len, %edx          # length
    syscall
```

### Stack Alignment

- 16-byte alignment before `call` (required by ABI)
- `sub $8, %rsp` if called function pushes an extra 8 bytes
- SSE/AVX require 16-byte / 32-byte alignment for data

### Common ELF Sections

| Section | Purpose |
|---------|---------|
| `.text` | Code |
| `.data` | Initialized data |
| `.bss` | Uninitialized data |
| `.rodata` | Read-only data |
| `.note` | Build information |
| `.got` | Global offset table |
| `.plt` | Procedure linkage table |
| `.rela` | Relocations |
| `.debug_*` | Debug information |

---

## Anti-Patterns and Common Issues

### Assembly-Specific Anti-Patterns

| Anti-Pattern | Symptom | Fix |
|-------------|---------|-----|
| Stack misalignment | SSE/AVX faults | Align stack to 16 bytes before call |
| Wrong calling convention | Wrong args/returns | Follow System V ABI |
| Missing cfi directives | Broken backtraces | Add `.cfi_*` or use `.cfi_startproc` |
| Mixed syntax | Confusing code | Pick AT&T or Intel, be consistent |
| Unaligned data | Performance hits or faults | Use `.align` or `.p2align` |
| Wrong operand size | Wrong values | `movl` vs `movw` vs `movb` |
| Missing `.globl` | Undefined symbols | Add `.globl` for exported symbols |
| Stale registers | Wrong values after call | Save/restore clobbered registers |
| Missing `.type`/`.size` | Bad backtraces | Add function metadata |
| Label conflicts | Duplicate symbols | Use `.L` prefix for local labels |

---

## Quick Reference

### Architecture Detection

```bash
gcc -dumpmachine                  # report target architecture
gcc -target x86_64-linux-gnu -dumpmachine
file program                      # check binary format
readelf -h program | grep Machine # ELF machine type
```

### Build Commands

```bash
# One-line compile and link
gcc -o program file.s

# Build with optimization and debug
gcc -O2 -g -o program file.s

# Cross-compile for ARM64
aarch64-linux-gnu-gcc -o program.arm64 file.s

# Generate disassembly
objdump -d -S program > program.dis

# Debug
gdb -ex run -ex "display/i \$pc" program

# Run with QEMU
qemu-aarch64-static program.arm64
```

### Architecture-Specific Commands

```bash
# ARM
arm-linux-gnu-as   -march=armv7-a file.s -o file.o
arm-linux-gnu-gcc  -o program.arm file.o
qemu-arm-static    program.arm

# ARM64
aarch64-linux-gnu-as -march=armv8-a file.s -o file.o
qemu-aarch64-static  program.arm64

# RISC-V
riscv64-linux-gnu-as -march=rv64imafdc file.s -o file.o
qemu-riscv64-static  program.riscv

# MIPS
mips-linux-gnu-as -mips32 -EB file.s -o file.o
qemu-mips-static   program.mips

# PowerPC
powerpc-linux-gnu-gcc -mcpu=powerpc file.s -o program.ppc
qemu-ppc-static     program.ppc
```

---

## Development Workflow

### Recommended Workflow for Claude-Driven Assembly Development

```bash
# 1. Write or edit assembly source
# Use AT&T or Intel syntax consistently
# Include .file, .text, .data, .bss, .globl, .align, .type, .size

# 2. Assemble and link
gcc -O2 -g -o program file.s

# 3. Verify the output
file program
readelf -h program
nm program
objdump -d program

# 4. Debug if needed
gdb program

# 5. Cross-compile for other architectures
aarch64-linux-gnu-gcc -o program.arm64 file.s
riscv64-linux-gnu-gcc -o program.riscv file.s

# 6. Test with QEMU
qemu-aarch64-static program.arm64
qemu-riscv64-static program.riscv
```

### Makefile Pattern

```makefile
# Standard assembly Makefile with cross-arch support

CC = gcc
AS = as
CROSS = aarch64-linux-gnu-gcc

CFLAGS = -O2 -g -masm=intel
ASFLAGS = --gdwarf-5
LDFLAGS =

TARGET = program
SRCS = start.s main.s utils.s
OBJS = $(SRCS:.s=.o)

.PHONY: all clean check disasm cross test

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $^

%.o: %.s
	$(AS) $(ASFLAGS) -c $< -o $@

cross: $(TARGET)
	$(CROSS) -o $(TARGET).arm64 $(OBJS)
	arm-linux-gnu-gcc -o $(TARGET).arm $(OBJS)
	riscv64-linux-gnu-gcc -o $(TARGET).riscv $(OBJS)

check: $(TARGET)
	file $(TARGET)
	readelf -h $(TARGET)
	nm $(TARGET)
	objdump -d $(TARGET)

disasm: $(TARGET)
	objdump -d -S $(TARGET) > $(TARGET).dis

test: $(TARGET)
	./$(TARGET)
	qemu-aarch64-static $(TARGET).arm64
	qemu-riscv64-static $(TARGET).riscv

clean:
	rm -f $(OBJS) $(TARGET) $(TARGET).dis $(TARGET).arm64 $(TARGET).arm $(TARGET).riscv
```

---

## Binary Formats

| Format | Extension | Tool | Use Case |
|--------|-----------|------|----------|
| **ELF** | (.elf) | gcc, ld | Executables and shared libraries |
| **Raw Binary** | .bin | objcopy -O binary | Firmware, boot sectors |
| **Intel HEX** | .hex | objcopy -O ihex | Flash programming |
| **Motorola S-Record** | .srec | objcopy -O srec | Microcontroller programming |
| **COFF** | .obj | as --format=coff | Windows/PE |
| **Mach-O** | .o | as --format=macho | macOS |
| **DWARF** | debug info | gdb | Debug information |

---

## Inline Assembly Examples (C + ASM)

```c
// x86_64 inline assembly
static inline uint64_t rdtsc(void) {
    uint32_t lo, hi;
    __asm__ __volatile__("rdtsc" : "=a"(lo), "=d"(hi));
    return ((uint64_t)hi << 32) | lo;
}

// ARM64 inline assembly
static inline uint64_t get_tb(void) {
    uint64_t val;
    __asm__ __volatile__("mrs %0, cntvct_el0" : "=r"(val));
    return val;
}

// Cross-platform syscall
static inline long syscall(long n, long a1, long a2, long a3) {
    long result;
#if defined(__x86_64__)
    __asm__ __volatile__("syscall" : "=a"(result)
        : "a"(n), "D"(a1), "S"(a2), "d"(a3) : "rcx", "r11", "memory");
#elif defined(__aarch64__)
    __asm__ __volatile__("svc 0" : "=r"(result)
        : "r"(a1), "r"(a2), "r"(a3), "1"(n) : "memory");
#endif
    return result;
}
```

---

## Related Documentation

- **SKILL.md** — Main skill reference (tool index, architecture matrix, debugging, linting)
- **DOCKER_HUB.md** — Docker image documentation (tags, layers, usage)
- **CLAUDE.md** — Project-wide configuration and conventions
