# GCC — Tool Use Concepts

## Compilation Tool Chain

The GCC tool chain consists of several tools that work together:

```
Source Code (.c/.cpp) → Preprocessor → Compiler → Assembler → Linker → Executable
                              │              │           │           │
                            Macros,      Object      .o        Linked
                            Includes     files       .o       library (.a/.so)
```

### Tool Flow

| Stage | Tool | Input | Output |
| ----- | ---- | ----- | ------ |
| **Preprocessing** | `gcc -E` | `.c` | `.i` (preprocessed) |
| **Compilation** | `gcc -S` | `.i` | `.s` (assembly) |
| **Assembly** | `gcc -c` | `.s` | `.o` (object) |
| **Linking** | `gcc` | `.o` | executable (ELF) |

---

## Tool Definitions for C/C++ Development

### gcc/g++ Compilation

**Input schema:**

```json
{
  "name": "gcc_compile",
  "description": "Compile C or C++ source files with GCC compiler",
  "input_schema": {
    "type": "object",
    "properties": {
      "files": {
        "type": "array",
        "items": { "type": "string" },
        "description": "Source files to compile"
      },
      "output": {
        "type": "string",
        "description": "Output file name"
      },
      "std": {
        "type": "string",
        "enum": ["c89", "c99", "c11", "c17", "c2x", "c++11", "c++14", "c++17", "c++20", "c++23"],
        "description": "Language standard"
      },
      "optimization": {
        "type": "string",
        "enum": ["O0", "O1", "O2", "O3", "Os", "Ofast"],
        "description": "Optimization level"
      },
      "warnings": {
        "type": "boolean",
        "description": "Enable -Wall -Wextra"
      },
      "debug": {
        "type": "boolean",
        "description": "Include debug symbols (-g)"
      },
      "includes": {
        "type": "array",
        "items": { "type": "string" },
        "description": "Include directories (-I)"
      },
      "libraries": {
        "type": "array",
        "items": { "type": "string" },
        "description": "Libraries to link (-l)"
      },
      "flags": {
        "type": "array",
        "items": { "type": "string" },
        "description": "Additional flags"
      }
    },
    "required": ["files"]
  }
}
```

### gdb Debugging

**Input schema:**

```json
{
  "name": "gdb_debug",
  "description": "Run GDB debugger on a compiled executable",
  "input_schema": {
    "type": "object",
    "properties": {
      "executable": {
        "type": "string",
        "description": "Path to executable to debug"
      },
      "breakpoints": {
        "type": "array",
        "items": { "type": "string" },
        "description": "Breakpoints to set (file:line, function name, or address)"
      },
      "arguments": {
        "type": "array",
        "items": { "type": "string" },
        "description": "Arguments to pass to the program"
      },
      "commands": {
        "type": "array",
        "items": { "type": "string" },
        "description": "GDB commands to run (e.g., 'run', 'next', 'print x')"
      },
      "watch_variables": {
        "type": "array",
        "items": { "type": "string" },
        "description": "Variables to watch"
      },
      "core_dump": {
        "type": "string",
        "description": "Core dump file path"
      }
    },
    "required": ["executable"]
  }
}
```

### make Build

**Input schema:**

```json
{
  "name": "make_build",
  "description": "Run make to build C/C++ project",
  "input_schema": {
    "type": "object",
    "properties": {
      "target": {
        "type": "string",
        "description": "Make target to build (e.g., 'all', 'clean', 'install')"
      },
      "jobs": {
        "type": "integer",
        "description": "Number of parallel jobs"
      },
      "verbose": {
        "type": "boolean",
        "description": "Verbose output"
      },
      "flags": {
        "type": "array",
        "items": { "type": "string" },
        "description": "Additional make flags"
      }
    },
    "required": []
  }
}
```

### cmake Build

**Input schema:**

```json
{
  "name": "cmake_build",
  "description": "Run CMake to configure and build C/C++ project",
  "input_schema": {
    "type": "object",
    "properties": {
      "build_type": {
        "type": "string",
        "enum": ["Debug", "Release", "RelWithDebInfo", "MinSizeRel"],
        "description": "CMake build type"
      },
      "target": {
        "type": "string",
        "description": "CMake target to build"
      },
      "prefix": {
        "type": "string",
        "description": "Install prefix"
      },
      "flags": {
        "type": "array",
        "items": { "type": "string" },
        "description": "Additional cmake flags"
      }
    },
    "required": []
  }
}
```

### valgrind Memory Check

**Input schema:**

```json
{
  "name": "valgrind_check",
  "description": "Run Valgrind to check for memory errors and leaks",
  "input_schema": {
    "type": "object",
    "properties": {
      "executable": {
        "type": "string",
        "description": "Executable to check"
      },
      "leak_check": {
        "type": "string",
        "enum": ["no", "summar", "full"],
        "description": "Leak checking level"
      },
      "show_leak_kinds": {
        "type": "array",
        "items": { "type": "string", "enum": ["definite", "indirect", "possible", "reachable"] },
        "description": "Which leak kinds to show"
      },
      "track_origins": {
        "type": "boolean",
        "description": "Track uninitialized value origins"
      },
      "arguments": {
        "type": "array",
        "items": { "type": "string" },
        "description": "Arguments to pass to the program"
      }
    },
    "required": ["executable"]
  }
}
```

---

## Tool Choice Options

Control which GCC tool to use:

| Value | Behavior |
| ------ | ------- |
| `{"type": "auto"}` | Claude decides which tool to use (default) |
| `{"type": "any"}` | Claude must use at least one tool |
| `{"type": "tool", "name": "gcc_compile"}` | Claude must use gcc_compile |
| `{"type": "none"}` | Claude cannot use tools |

---

## Best Practices for C/C++ Tool Use

1. **Always use `-g` for debugging** — Without debug symbols, gdb cannot show source lines.
2. **Set the C standard explicitly** — Don't rely on compiler defaults.
3. **Use `-Wall -Wextra`** — Catches common bugs that might otherwise be silent.
4. **Prefer `pkg-config`** for library flags — More portable than hard-coded paths.
5. **Use CMake presets** for reproducible builds — Avoids configuration drift.
6. **Check valgrind output** after each change — Catches memory errors early.
7. **Use AddressSanitizer** in development — Catches buffer overflows at runtime.
8. **Generate compile_commands.json** — IDE support and clang-tidy integration.
9. **Use `-flto` in release** — Link-time optimization improves performance.
10. **Always specify `-std=`** — Avoids surprises when compiler versions change.

---

## Tool Use Examples

### Example: Compile and Debug

```json
{
  "tool_use": "gcc_compile",
  "input": {
    "files": ["src/main.c", "src/utils.c", "src/parser.c"],
    "output": "myapp",
    "std": "c17",
    "optimization": "O2",
    "warnings": true,
    "debug": true,
    "includes": ["include", "/usr/include"],
    "libraries": ["m", "pthread"]
  }
}

{
  "tool_use": "gdb_debug",
  "input": {
    "executable": "myapp",
    "breakpoints": ["main", "utils.c:42"],
    "arguments": ["--verbose"],
    "commands": ["run", "print count", "next"],
    "watch_variables": ["count", "data"]
  }
}
```

### Example: Build with CMake

```json
{
  "tool_use": "cmake_build",
  "input": {
    "build_type": "Debug",
    "target": "all",
    "prefix": "/usr/local",
    "flags": ["-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"]
  }
}
```
