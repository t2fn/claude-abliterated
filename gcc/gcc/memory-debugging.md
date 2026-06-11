# GCC — Memory Debugging

## Valgrind

### Basic Usage

```bash
# Full leak check (default)
valgrind --leak-check=full --show-leak-kinds=all ./myapp

# Detailed output
valgrind --leak-check=full --show-leak-kinds=all \
    --track-origins=yes --verbose ./myapp

# With arguments
valgrind --leak-check=full ./myapp arg1 arg2

# With environment variables
valgrind --leak-check=full --trace-children=yes \
    ./myapp
```

### Valgrind Options

| Option | Purpose |
| ------ | ------- |
| `--leak-check=full` | Full leak detection |
| `--show-leak-kinds=all` | Show all leak kinds (definite, indirect, possible, reachable) |
| `--track-origins=yes` | Show where uninitialized values come from |
| `--verbose` | More detailed output |
| `--trace-children=yes` | Trace child processes (fork/exec) |
| `--num-callers=40` | Stack trace depth for leak reports |
| `--error-exitcode=1` | Exit code on errors |
| `--log-file=valgrind.log` | Write output to file |

### Leak Kinds

| Kind | Meaning |
| ---- | ------- |
| `definite` | Directly leaked — no pointer to it |
| `indirect` | Leaked because a definite leak owns it |
| `possible` | Some pointers to it, but not all |
| `reachable` | Not leaked — reachable from globals |

### Valgrind Suppressions

```bash
# Create suppression file for known issues
cat > myapp.supp << 'EOF'
{
   OpenSSL SSL_accept
   Memcheck:Leak
   matchLeak: yes
   ...
}
EOF

valgrind --suppressions=myapp.supp ./myapp
```

### Memcheck (Default Mode)

```bash
# Check for memory errors
valgrind --tool=memcheck ./myapp

# Check for invalid reads/writes
valgrind --tool=memcheck --error-exitcode=42 ./myapp

# Check for stack use
valgrind --tool=memcheck --track-stack=no ./myapp

# Custom log format
valgrind --tool=memcheck \
    --xml=yes \
    --xml-file=valgrind.xml \
    ./myapp
```

### Callgrind (Cache Profiling)

```bash
# Profile with callgrind
valgrind --tool=callgrind ./myapp

# Analyze output
callgrind_annotate callgrind.out.<PID>

# Generate visual report
callgrind_annotate --auto=yes callgrind.out.<PID>
```

### Cachegrind (Cache Simulation)

```bash
# Profile cache behavior
valgrind --tool=cachegrind ./myapp

# Analyze results
cg_annotate cg_profile.out
```

---

## AddressSanitizer (ASan)

### Compilation

```bash
# Compile with AddressSanitizer
gcc -fsanitize=address -g -O1 -fno-omit-frame-pointer \
    -o myapp-asan main.c

# With specific checks
gcc -fsanitize=address \
    -fsanitize-address-use-after-scope \
    -g -o myapp-asan main.c
```

### Running

```bash
# Run the ASan-instrumented binary
./myapp-asan

# Set ASan options via environment
ASAN_OPTIONS=detect_leaks=1:print_stats=1 ./myapp-asan

# Specific checks
ASAN_OPTIONS=detect_stack_use_after_return=1 \
             check_initialization_order=1 \
             ./myapp-asan
```

### ASan Options

| Option | Purpose |
| ------ | ------- |
| `detect_leaks=1` | Enable leak detection |
| `print_stats=1` | Print summary statistics |
| `print_summary=1` | Print a summary report |
| `symbolize=1` | Symbolize addresses |
| `halt_on_error=1` | Stop on first error |
| `verbosity=1` | Verbose output |
| `detect_stack_use_after_return=1` | Check use-after-return |
| `check_initialization_order=1` | Check global init order |
| `use_after_scope=1` | Detect use after scope |

### ASan Error Messages

```
==12345==ERROR: AddressSanitizer: heap-buffer-overflow on address 0x602000001050
WRITE of size 4 at 0x602000001050 thread T0
    #0 0x4a1234 in utils_process src/utils.c:42
    #1 0x4b5678 in main src/main.c:100
    #2 0x7f1234567890 in __libc_start_main
    #3 0x4c9abc in _start
```

---

## UndefinedBehaviorSanitizer (UBSan)

### Compilation

```bash
# Compile with UBSan
gcc -fsanitize=undefined -g -o myapp-ubsan main.c

# With specific checks
gcc -fsanitize=undefined \
    -fsanitize=float-divide-by-zero \
    -fsanitize=integer \
    -g -o myapp-ubsan main.c
```

### Running

```bash
./myapp-ubsan

# UBSan options
UBSAN_OPTIONS=print_stacktrace=1:halt_on_error=1 ./myapp-ubsan
```

### Checked Behaviors

| Check | Flag | Description |
| ----- | ---- | ----------- |
| Integer overflow | `-fsanitize=integer` | Integer overflow/underflow |
| Shift overflow | `-fsanitize=shift` | Shift overflow |
| Return value | `-fsanitize=return` | Return value check |
| Function cast | `-fsanitize=function` | Function cast check |
| Alignment | `-fsanitize=alignment` | Pointer alignment |
| Bool | `-fsanitize=bool` | Boolean value check |
| Integer | `-fsanitize=integer` | Integer overflow |
| Pointer overflow | `-fsanitize=pointer-overflow` | Pointer arithmetic overflow |
| Float divide by zero | `-fsanitize=float-divide-by-zero` | Division by zero |
| Unreachable | `-fsanitize=unreachable` | Unreachable code reached |
| Vitality | `-fsanitize=vla-bound` | VLA bound check |

---

## ThreadSanitizer (TSan)

### Compilation

```bash
# Compile with TSan
gcc -fsanitize=thread -g -o myapp-tsan main.c -pthread

# Run
./myapp-tsan
```

### Detected Issues

| Issue | Description |
| ----- | ----------- |
| Data race | Concurrent access without synchronization |
| Lock order inversion | Lock acquired in different order |
| Thread leak | Thread created but not joined |

### TSan Options

```bash
TSAN_OPTIONS="history_size=7:exitcode=86 ./myapp-tsan
```

---

## Memory Profiling

### glibc malloc Debug

```bash
# Enable malloc debugging
export MALLOC_ARENA_MAX=2
export MALLOC_MMAP_THRESHOLD_=131072
export MALLOC_TRIM_THRESHOLD_=1048576

# Track malloc/free
export MALLOC_CHECK_=3

# Debug
export MALLOC_PERTURB_=0x55

./myapp
```

### heaptrack (Heap Tracking)

```bash
# Install: apt install heaptrack (Debian/Ubuntu)

# Profile
heaptrack ./myapp

# Analyze
heaptrack_print heaptrack.myapp.* > heaptrack.txt
cat heaptrack.txt
```

### dmalloc (Debug malloc)

```bash
# Compile with dmalloc
gcc -g -o myapp-dm main.c -ldmalloc

# Set options
export DMALLOC_OPTIONS=debug=0x44,log=dmalloc.log,stats,trace

./myapp-dm

# View log
cat dmalloc.log
```

---

## Core Dump Debugging

### Core Dump Configuration

```bash
# Check current core dump settings
ulimit -c         # Should show unlimited or a number
cat /proc/sys/kernel/core_pattern

# Enable core dumps
ulimit -c unlimited

# Set core dump pattern
echo "/tmp/core.%p.%e" > /proc/sys/kernel/core_pattern
```

### Analyzing Core Dumps

```bash
# Generate and debug
./myapp &
PID=$!
kill -SIGABRT $PID
# Wait for core file to be generated
gdb ./myapp core
(gdb) bt full
(gdb) info registers
(gdb) info threads
(gdb) thread apply all bt

# Debug with specific core file
gdb -c core.myapp.12345 ./myapp
```

### GDB Core Analysis

```bash
(gdb) # After core is loaded:
(gdb) info proc mappings           # Memory layout
(gdb) info mem                     # Memory regions
(gdb) bt full                      # Full backtrace
(gdb) info registers               # Register state
(gdb) x/16xw $sp                   # Stack contents
(gdb) x/32gx 0x7fffffffe000       # Heap contents
(gdb) info breakpoints             # Current breakpoints
(gdb) info threads                 # Thread state
```

---

## Memory Error Categories

### Common Memory Errors

| Error | Description | Detection |
| ----- | ----------- | --------- |
| **Heap overflow** | Write past allocated heap buffer | ASan, valgrind |
| **Stack overflow** | Write past stack buffer | UBSan, ASan |
| **Use-after-free** | Access memory after freeing | ASan, valgrind |
| **Use-after-return** | Access stack memory after function returns | ASan |
| **Memory leak** | Allocated but never freed | valgrind, heaptrack |
| **Double free** | Free same memory twice | ASan, valgrind |
| **Uninitialized read** | Read memory before writing | valgrind, ASan |
| **Invalid pointer** | Free or access invalid pointer | ASan, valgrind |
| **Data race** | Concurrent access without sync | TSan |
| **Buffer overflow** | Read/write past buffer bounds | ASan, valgrind |

### Prevention Checklist

1. **Always check malloc return** — NULL check after `malloc`/`calloc`/`realloc`.
2. **Free all allocations** — ensure every `malloc` has a corresponding `free`.
3. **Set pointers to NULL** after `free` to detect use-after-free.
4. **Use `calloc`** when you need zero-initialized memory.
5. **Use `strdup`** instead of `malloc` + `strcpy` for strings.
6. **Check array bounds** before accessing.
7. **Use `sizeof`** instead of hard-coded sizes in `malloc`.
8. **Close file descriptors** after use.
9. **Initialize all variables** before use.
10. **Use `extern "C"`** for C libraries in C++ code.
