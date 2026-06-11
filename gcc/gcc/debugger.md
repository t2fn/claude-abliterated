# GCC — GDB Debugger

## Starting GDB

### Basic Launch

```bash
# Debug an existing executable
gdb ./myapp

# Debug with arguments
gdb ./myapp arg1 arg2

# Debug with core dump
gdb ./myapp core

# Debug a running process
gdb -p <PID>

# Start without executable (attach later)
gdb
```

### GDB Quick Start

```bash
# Start gdb
gdb ./myapp

# Run the program
(gdb) run

# Run with arguments
(gdb) run --verbose --config /etc/app.conf

# Run with environment variables
(gdb) set-env FOO=bar
(gdb) run

# Exit gdb
(gdb) quit
```

### GDB Configuration

```bash
# Create ~/.gdbinit for default settings
cat > ~/.gdbinit << 'EOF'
# Display settings
set print pretty on
set print elements 0          # No limit on array/vector display
set width 0                   # Auto-width for terminal
set pagination on

# Show source context
set context view size 10

# Enable auto-load Python pretty-printers
set python print-stack full

# Display mode
set disassembly-flavor intel

# Breakpoint display
set breakpoint pending on
set breakpoint verbose on
EOF
```

---

## Breakpoints

### Setting Breakpoints

```bash
# Break by line number
(gdb) break 42

# Break by function name
(gdb) break utils_init

# Break by file:line
(gdb) break utils.c:128

# Break with condition
(gdb) break utils_process if count > 100

# Break with command list
(gdb) break main
commands
    silent
    printf "main() entered, argc=%d\n", argc
    continue
end

# Conditional breakpoint
(gdb) break 100 if i == 42

# Temporary breakpoint (removed after first hit)
(gdb) tbreak utils_parse

# Break by pattern
(gdb) break *main
(gdb) break *utils_.*

# Set breakpoint in shared library
(gdb) break libutils.so:init_utils
```

### Breakpoint Management

```bash
# List all breakpoints
(gdb) info breakpoints

# Disable/enable breakpoints
(gdb) disable 2
(gdb) enable 2

# Delete breakpoints
(gdb) delete 2
(gdb) delete breakpoints     # Delete all

# Clear specific breakpoint
(gdb) clear 42
(gdb) clear utils.c:128

# Delete all breakpoints
(gdb) delete breakpoints
```

---

## Stepping and Navigation

### Execution Control

```bash
# Continue to next statement
(gdb) next          # n - step over function calls

# Step into function calls
(gdb) step          # s - step into function calls

# Continue to current line
(gdb) continue      # c - resume execution

# Step one instruction (assembly)
(gdb) stepi         # si - step one instruction
(gdb) nexti         # ni - step one instruction

# Jump to specific line (changes instruction pointer)
(gdb) jump 42
```

### Stepping in Loops

```bash
# Step over N iterations
(gdb) step 100      # Step 100 times (for loops)

# Continue until line number
(gdb) until 200     # Continue until line 200

# Continue until function returns
(gdb) finish          # Continue until current function returns
(gdb) return        # Same as finish, but can specify return value
```

### Navigation

```bash
# Backtrace (show call stack)
(gdb) backtrace     # bt - full stack trace
(gdb) backtrace 5   # bt 5 - show top 5 frames

# Select stack frame
(gdb) frame 3       # Select frame 3
(gdb) up            # Move up one frame
(gdb) down          # Move down one frame

# List source code
(gdb) list          # list - show current source
(gdb) list main     # list function main()
(gdb) list 40,50    # list lines 40-50
(gdb) list -          # repeat last list

# Display assembly
(gdb) disassemble   # dis - disassemble current function
(gdb) disassemble /m main   # disassemble with mixed source
(gdb) disassemble main, main+64   # disassemble specific range
```

---

## Variables and Expressions

### Inspecting Variables

```bash
# Print variable value
(gdb) print x
(gdb) p count

# Print with format
(gdb) print/x 0x1f          # hex
(gdb) print/d 42            # decimal
(gdb) print/c 65            # character
(gdb) print/t 42            # binary
(gdb) print/s str            # string

# Print variable type
(gdb) print &x

# Print structure members
(gdb) print *user           # dereference struct
(gdb) print user->name

# Print array elements
(gdb) print arr[0]@10       # 10 elements starting at index 0

# Evaluate expression
(gdb) print x + y * 2
(gdb) print (double)x / count

# Update variable value
(gdb) set x = 10
(gdb) set count = count + 1
(gdb) set str = "hello"
(gdb) set *ptr = 42
```

### Display Automatically

```bash
# Add display expression (shown after every command)
(gdb) display count
(gdb) display/i               # display next instruction

# Remove display expressions
(gdb) undisplay 1

# Delete all display expressions
(gdb) delete display

# Show display expressions
(gdb) info display
```

---

## Watches and Observations

### Watchpoints

```bash
# Watch a variable for any access
(gdb) watch x

# Watch a variable for write only
(gdb) rwatch x

# Watch expression
(gdb) watch count > 100

# Watch structure member
(gdb) watch header->magic

# List all watchpoints
(gdb) info watchpoints
```

### Hardware Observations

```bash
# Set hardware watchpoint
(gdb) hwatch x

# Set hardware breakpoint
(gdb) hbreak main
(gdb) info breakpoints    # shows which are hardware vs software
```

---

## Core Dumps

### Generating Core Files

```bash
# Enable core dumps
ulimit -c unlimited

# Run program (core dumped on crash)
./myapp

# Debug core dump
gdb ./myapp core
```

### Working with Core Dumps

```bash
# Load core file in gdb
gdb
(gdb) core-file core
(gdb) bt                  # Backtrace at crash

# Generate core from running process
(gdb) generate-core-file core.myapp

# Debug with core dump
gdb -c core ./myapp
```

### Core Dump Analysis

```bash
(gdb) # After core is loaded:
(gdb) bt full             # Full backtrace with local variables
(gdb) info registers      # Register state
(gdb) info threads        # Thread list
(gdb) thread apply all bt # Backtrace all threads
```

---

## Thread Debugging

### Thread Management

```bash
# List threads
(gdb) info threads

# Select thread
(gdb) thread 1

# Set breakpoint in specific thread
(gdb) break utils.c:42 thread 2

# Run all threads
(gdb) set scheduler- locking off

# Schedule all threads
(gdb) set scheduler- locking on

# Create breakpoint for all threads
(gdb) break utils_init all

# Show thread-specific variables
(gdb) info locals           # Local variables in current scope
(gdb) info args             # Function arguments
```

### Thread-Specific Commands

```bash
# Continue with thread stop
(gdb) set non-stop on      # Non-stop mode (one thread stops at a time)
(gdb) set target-async on  # Asynchronous output

# Thread groups
(gdb) info thread-groups
(gdb) thread apply 1-3 print $pc
```

---

## Memory Inspection

### Memory Commands

```bash
# Print memory contents
(gdb) x/10xw 0x7fffffffe000   # 10 words in hex
(gdb) x/20b addr               # 20 bytes
(gdb) x/4gx 0x7fffffffe000     # 4 double-words in hex
(gdb) x/s str                   # Print string at address
(gdb) x/f addr                 # Print as float
(gdb) x/d addr                 # Print as decimal

# Memory format specifiers
#   x - hex, d - decimal, u - unsigned, o - octal
#   t - binary, f - float, a - address, c - char
#   w - word (4 bytes), h - half-word (2 bytes)
#   b - byte, g - giant (8 bytes)

# Print count/size/format
#   x/NFU  where:
#     N = number of items
#     F = format (x,d,u,o,t,c,a,...)
#     U = unit size (b,h,w,g,...)

# Set memory
(gdb) set *(int*)0x7fffffffe000 = 42

# Clear memory
(gdb) clear 0x7fffffffe000, 1024

# Memory ranges
(gdb) info mem          # Show memory mappings
(gdb) info proc mappings  # Process memory mappings
```

### Memory Mapping

```bash
# View process memory map
(gdb) info proc mappings

# Read/write memory files
(gdb) dump binmem /tmp/data.bin 0x1000 0x2000
(gdb) load /tmp/data.bin 0x1000
```

---

## GDB Commands Reference

### Essential Commands

| Command | Alias | Purpose |
| ------- | ----- | ------- |
| `run` | `r` | Run the program |
| `continue` | `c` | Continue from breakpoint |
| `next` | `n` | Step over |
| `step` | `s` | Step into |
| `finish` | | Step out of function |
| `quit` | `q` | Exit gdb |
| `bt` | `backtrace` | Show call stack |
| `frame` | `f` | Select stack frame |
| `print` | `p` | Print expression |
| `set` | | Set variable |
| `watch` | | Set watchpoint |
| `break` | `b` | Set breakpoint |
| `info` | `i` | Show info |
| `disassemble` | `disas` | Disassemble function |
| `list` | `l` | List source code |
| `display` | | Add display expression |
| `undisplay` | | Remove display expression |

### GDB Scripting

```bash
# Source a GDB script
(gdb) source ~/.gdb/hooks.gdb

# Write commands to a script file
cat > debug_commands.gdb << 'EOF'
break main
run
continue
# Log output
set logging on
continue
set logging off
EOF

# Execute script file
gdb -x debug_commands.gdb ./myapp
```

### GDB Python Integration

```bash
# Python pretty printers (automatic for STL containers, etc.)
# Enable in .gdbinit:
# python
# import sys
# sys.path.insert(0, '/usr/share/gdb/python')
# from gdbpp import *
# gdbpp.register()
# end

# Python expression evaluation
(gdb) python
import os
print(os.environ.get("HOME"))
end
```

---

## Debugging Strategies

### Debug Build Checklist

1. **Compile with debug symbols**: `-g -O0`
2. **Preserve frame pointers**: `-fno-omit-frame-pointer`
3. **Don't optimize**: `-O0` (no `-O2` or `-O3`)
4. **Enable debugging mode**: `-DDEBUG`
5. **Generate source maps**: `-gdwarf-4` or `-gdwarf-5`

### Debug Build Example

```bash
gcc -g -O0 -fno-omit-frame-pointer -DDEBUG -Wall -Wextra \
    -std=c17 -o myapp-debug main.c utils.c parser.c \
    -lm -lpthread
```

### Debug Workflow

```bash
# 1. Compile with debug symbols
gcc -g -O0 -Wall -Wextra -std=c17 -o myapp main.c

# 2. Start gdb
gdb ./myapp

# 3. Set breakpoints
(gdb) break main
(gdb) break utils_process if count > 0

# 4. Run and observe
(gdb) run arg1 arg2
(gdb) next
(gdb) print count
(gdb) step
(gdb) backtrace
(gdb) continue
```

---

## GDB Pretty Printers

### STL Containers (C++)

```bash
# Enable STL pretty printing
(gdb) python
import sys
sys.path.insert(0, '/usr/share/gdb/python')
from libstdcxx.v6.printers import register_libstdcxx_printers
register_libstdcxx_printers(gdb.current_objfile())
end
```

### Custom Pretty Printers

```bash
# Python pretty printer example
cat > my_pp.py << 'EOF'
class MyStructPrinter:
    """Pretty printer for my custom struct."""

    def __init__(self, val):
        self.val = val

    def to_string(self):
        return "MyStruct {{ name='{}', value={} }}".format(
            str(self.val['name']), int(self.val['value']))

    def children(self):
        yield 'name', self.val['name']
        yield 'value', self.val['value']

    def display_hint(self):
        return 'dict'
EOF

(gdb) source my_pp.py
```
