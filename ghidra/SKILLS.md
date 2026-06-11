---
name: ghidra-mcp
description: Ghidra reverse engineering suite with 200+ MCP tools for binary analysis, decompilation, malware detection, function emulation, and collaborative analysis via /mcp endpoint
---

# Ghidra MCP Skills (claude-abliterated)

A complete Ghidra reverse engineering environment with **200+ tools** + **5 resources** accessible via the `/mcp` endpoint (streamable-HTTP transport) on port 48080.

## What the 200+ Means

The `200+` count comes from **all** Ghidra tooling available to Claude Code, organized across four layers:

| Layer | Count | What It Is |
|-------|-------|------------|
| **Static Registry** | 32 | Tools with full descriptions and parameters (decompile, rename, emulate, etc.) |
| **Code Mode** | +2 | `search` + `execute` — generic dispatch for all registry tools |
| **Script Mode** | +3 | `search_api` + `get_class_info` + `execute_script` — Java API introspection |
| **Resources** | +5 | `ghidra://binaries`, `ghidra://binary/{name}/{info,functions,strings,imports}` |
| **Ghidra Java API** | ~160 | Classes across 12 packages (analysis, decompilation, symbols, memory, datatypes, P-code) accessible via dynamic bridge registration |

---

## Tool Index by Category

### Binary Management (Core)

Tools for importing, uploading, listing, and removing binaries.

| Tool | What It Does | Value |
|------|-------------|-------|
| **import_binary** | Import a file into the Ghidra project with optional auto-analysis | Primary entry point; load PE/ELF/Mach-O for analysis |
| **upload_binary** | Upload a binary via base64-encoded data | Useful for Claude reading files inline |
| **list_binaries** | List all binaries in the project | Quick overview before analysis; always call first |
| **delete_binary** | Remove a binary from the project | Cleanup after analysis or switching binaries |

### Disassembly & Functions (Core)

The heart of Ghidra reverse engineering — decompilation, function inspection, and renaming.

| Tool | What It Does | Value |
|------|-------------|-------|
| **decompile_function** | Decompile a function to C pseudocode | **Most-used tool**; converts machine code to readable C for analysis |
| **list_functions** | List functions with pagination and name filtering | Discovery tool; always call before decompilation to find the right function |
| **get_function_summary** | Get rich metadata: parameters, callees, callers, strings, complexity | Fast metadata without full decompilation; ideal for reconnaissance |
| **get_basic_blocks** | Get control-flow graph basic blocks with successor/predecessor edges | Essential for CFG reconstruction and understanding function structure |
| **get_call_graph** | Get function call graph with BFS depth control | Maps function relationships; critical for understanding program flow |
| **rename_function** | Rename a function by name or hex address | Direct editing of Ghidra project; Claude can annotate findings |
| **rename_variable** | Rename a parameter or local variable within a function | Precision editing; Claude can rename after analyzing code semantics |
| **rename_label** | Rename a symbol/label in the program | Global symbol editing; useful for API/constant renaming |

### Strings & Bytes (Core)

String analysis and raw byte inspection — essential for identifying strings, signatures, and packed content.

| Tool | What It Does | Value |
|------|-------------|-------|
| **list_strings** | List defined strings with min_length, pagination | String analysis; identifies text, URLs, paths, error messages |
| **search_strings** | Search strings by pattern (substring or regex) | Find specific strings across a binary; powerful for pattern matching |
| **search_bytes** | Search byte patterns with `??` wildcards | Signature scanning; find magic numbers, headers, embedded content |
| **get_memory_bytes** | Read raw bytes from a specific address (up to 4096 bytes) | Direct memory inspection; useful for verifying binary layout |

### Imports, Exports & Cross-References (Core)

Tool for understanding what a binary depends on, what it provides, and how pieces connect.

| Tool | What It Does | Value |
|------|-------------|-------|
| **list_imports** | List imported symbols/functions | Dependency analysis; identifies what the binary needs |
| **list_exports** | List exported symbols/functions | API surface; identifies what the binary provides to callers |
| **get_xrefs** | Get cross-references to/from an address (to, from, or both) | Traceability; connects callers to callees, declarations to definitions |

### Code Analysis (Core)

Deep analysis tools — entropy calculation, section inspection, suspicious API detection, instruction search.

| Tool | What It Does | Value |
|------|-------------|-------|
| **get_entropy** | Calculate per-section Shannon entropy (>7.0 = packed/encrypted) | Packing detection; identifies compressed/encrypted sections |
| **detect_suspicious_apis** | Detect suspicious API imports by behavior category | **Malware's best tool**; categorizes API calls (injection, persistence, crypto, network, etc.) |
| **get_sections** | Get sections with permissions, entropy, and anomaly flags | Binary layout; identifies W+X anomalies, high-entropy sections |
| **search_instructions** | Search disassembly for instructions matching regex patterns | Instruction-level analysis; find specific opcode patterns |

### Emulation (Core)

Runtime behavior analysis — run code without executing it, trace registers and memory.

| Tool | What It Does | Value |
|------|-------------|-------|
| **emulate_function** | Emulate a function with optional arguments; returns result | Behavioral analysis; run code in isolation to see what it does |
| **emulate_step** | Single-step an emulator session; read registers and memory | Step-through debugging; ideal for tracing specific code paths |
| **emulate_session_destroy** | Destroy an emulator session and free resources | Cleanup; prevent memory leaks in long sessions |

### Server Collaboration (Core)

Tools for collaborative analysis — connecting to Ghidra servers, managing repositories, and saving changes.

| Tool | What It Does | Value |
|------|-------------|-------|
| **connect_server** | Connect to a Ghidra server for collaborative analysis | Multi-user analysis; opens remote repositories |
| **disconnect_server** | Disconnect and release all server-opened programs | Clean exit; release resources |
| **list_repositories** | List available repositories on the connected server | Repository browsing; find and select programs |
| **list_server_files** | List files/subfolders in a repository | File system navigation; explore server content |
| **open_from_server** | Open a program from the server for analysis | Loading remote programs; checkout for editing |
| **checkin_file** | Check in changes back to the Ghidra server | Saving work; persists Claude's edits |

### Code Mode Tools (dispatch)

Two tools that dispatch to any registered Ghidra method dynamically.

| Tool | What It Does | Value |
|------|-------------|-------|
| **search** | Search the Ghidra tool catalog; returns tool names, descriptions, parameters | Claude's gateway to discovering available tools |
| **execute** | Execute any Ghidra analysis method by name with parameters | Universal dispatcher; calls any tool without needing its specific registration |

### Script Mode Tools (API)

Tools for Java API introspection and script execution.

| Tool | What It Does | Value |
|------|-------------|-------|
| **search_api** | Search Ghidra Java API classes/methods by keyword | API exploration; find the right Java class for advanced tasks |
| **get_class_info** | Get detailed Java class info via live reflection | API documentation; understand class structure and methods |
| **execute_script** | Execute a Python code snippet with full Ghidra Java API access | Advanced analysis; write custom Ghidra scripts in Python |

### Ghidra Java API Classes (~160)

Ghidra exposes **~160 Java API classes** accessible through the bridge's dynamic registration, organized across 12 packages:

#### Program Analysis
| Class | What It Does |
|-------|-------------|
| Function | Core function representation; contains name, signature, body, parameters |
| FunctionSignature | Function signature (return type, parameter types, calling convention) |
| Program | The main Ghidra program object; top-level container for all analysis |
| Listing | Provides access to functions, symbols, memory, and data |
| CodeUnit | Base class for all code units (instructions, comments, labels) |
| Memory | Binary memory access; read/write bytes, integers, arrays |
| MemoryBlock | Memory segments (sections); identifies text, data, bss, etc. |

#### Decompilation
| Class | What It Does |
|-------|-------------|
| DecompileFunction | Decompiles a function; returns C-like pseudocode |
| CFunction | Decomposed function representation |
| CParam | Function parameters in decompiled output |
| CVar | Variables in decompiled output (locals, parameters) |
| CExpr | Expressions in decompiled code (literals, references, operations) |
| CBlock | Basic blocks in decompiled pseudocode |
| DecompilerComponent | The decompiler UI component; provides decompilation access |

#### Symbols & Names
| Class | What It Does |
|-------|-------------|
| SymbolTable | Symbol management; find symbols by name, address, scope |
| Symbol | A single symbol (name, address, namespace, type) |
| SymbolNamespace | Symbol scope/namespaces in Ghidra |
| ExternalManager | External references and imports |
| ExternalLocation | An external reference (imported address) |

#### Data Types
| Class | What It Does |
|-------|-------------|
| DataTypeManager | Manages data types (structs, arrays, pointers, enums) |
| DataType | A type definition (primitive, composite, derived) |
| Structure | A struct type; ordered fields with offsets |
| Array | Array type definition |
| Pointer | Pointer type definition |
| Enumerator | Enum type with named integer constants |
| DataTypeCategory | Type hierarchy/category |

#### P-code
| Class | What It Does |
|-------|-------------|
| PcodeEmit | Emits P-code instructions |
| PcodeOp | A single P-code operation (LOAD, STORE, ADD, SUB, etc.) |
| PcodeFunction | The P-code representation of a function |
| PcodeAddress | Memory address in P-code space |
| PcodeBlock | A P-code basic block |
| PcodeSpace | Address space identifier (absolute, code, data, etc.) |

#### Emulation
| Class | What It Does |
|-------|-------------|
| Emulator | Emulates execution; runs code and tracks state |
| EmulatorCallback | Callback for emulator events |
| RegisterMap | Register value mapping during emulation |
| EmulatedInstruction | A single emulated instruction |

#### Program Model
| Class | What It Does |
|-------|-------------|
| Address | Represents a memory address |
| AddressSet | A set of addresses (ranges, individual addresses) |
| Instruction | A single instruction in the program |
| InstructionIterator | Iterates through instructions |
| ObjFile | Object file representation (ELF, PE, Mach-O) |
| Language | Ghidra language definition (architecture, byte order) |
| DataType | Data type representation |

#### Analysis
| Class | What It Does |
|-------|-------------|
| Analyzer | Base class for analyzers |
| AnalysisConfiguration | Analyzer settings and parameters |
| ProgressMonitor | Tracks analysis progress |
| TaskMonitor | Task progress and cancellation |
| AnalyzerTask | A single analysis task |
| AnalysisHistory | History of performed analyses |

#### Miscellaneous
| Class | What It Does |
|-------|-------------|
| TaskMonitor | Monitors task progress |
| Console | Console output for Ghidra |
| Options | Ghidra configuration options |
| Plugin | Ghidra plugin management |
| ProgramDB | Program database I/O |
| ProgramManager | Program lifecycle management |

---

### Resources (ghidra:// URIs)

Pre-built Ghidra resources accessible via URI for automatic content discovery.

| Resource URI | What It Returns |
|-------------|-----------------|
| **ghidra://binaries** | List of all binaries in the project |
| **ghidra://binary/{name}/info** | Binary metadata (architecture, format, hashes, entry point) |
| **ghidra://binary/{name}/functions** | All functions in the binary |
| **ghidra://binary/{name}/strings** | All defined strings |
| **ghidra://binary/{name}/imports** | All imported symbols |

---

## Skills Emphasis Order (Top 15)

Prioritized by usage frequency, task criticality, and Claude assessment quality.

| Rank | Tool | Emphasis Trigger | Why Claude Should Pick It |
|------|------|-----------------|---------------------------|
| 1 | **decompile_function** | Any code inspection task | The gold standard for understanding binary code |
| 2 | **list_functions** | Discovery, overview, pre-analysis | Fast, reliable, always-call-first |
| 3 | **detect_suspicious_apis** | Malware, security, anomaly detection | Primary malware detection; categorizes APIs |
| 4 | **emulate_function** | Behavioral analysis, runtime questions | Run code in isolation; observe behavior |
| 5 | **get_function_summary** | Quick metadata, lightweight analysis | No full decompilation needed; fast |
| 6 | **get_xrefs** | Dependency, traceability, call-chain analysis | Connects callers, callees, declarations |
| 7 | **get_entropy** | Packing, encryption, compressed binaries | Entropy >7.0 = packed/encrypted |
| 8 | **search_instructions** | Instruction-level, opcode patterns | Regex matching on disassembly |
| 9 | **get_call_graph** | Function relationships, control flow | BFS depth control; visualizable output |
| 10 | **list_strings** | Reconnaissance, string analysis | Identifies text, URLs, paths, error messages |
| 11 | **get_sections** | Binary layout, anomaly detection | Permissions, entropy, section boundaries |
| 12 | **search_bytes** | Signature scanning, magic numbers | Wildcard support (`??`) |
| 13 | **get_memory_bytes** | Memory inspection, byte reading | Direct memory access |
| 14 | **search_api** | Java API exploration | Find the right Ghidra Java class |
| 15 | **get_basic_blocks** | CFG reconstruction, block analysis | Successor/predecessor edges |

---

## When to Use Which Skill

### Binary Inspection (Code Review)
- **Start**: `list_functions` + `list_strings` for quick overview
- **Deep analysis**: `decompile_function` for C pseudocode
- **Lightweight**: `get_function_summary` for metadata without decompilation

### Malware Analysis (Security)
- **Primary**: `detect_suspicious_apis` (categorized: injection, persistence, crypto, network, anti-debug, etc.)
- **Supporting**: `get_entropy` (packed), `search_bytes` (signatures), `get_sections` (W+X anomalies)
- **Behavioral**: `emulate_function` (run suspicious code)

### Reverse Engineering (Deep Dive)
- **Structure**: `get_call_graph` + `get_basic_blocks` (CFG)
- **Traceability**: `get_xrefs` (callers, callees, definitions)
- **Instruction-level**: `search_instructions` (regex on disassembly)
- **Editing**: `rename_function`, `rename_variable`, `rename_label`

### Collaborative Analysis
- **Connect**: `connect_server` / `open_from_server`
- **Browse**: `list_repositories` / `list_server_files`
- **Save**: `checkin_file` (persist Claude's edits)

### API Exploration
- **Find**: `search_api` (by keyword)
- **Inspect**: `get_class_info` (detailed Java class info)
- **Execute**: `execute_script` (custom Python scripts with full Java API)

---

## Claude Assessment Guide

When Claude Code assesses binary analysis tasks, use this priority map to pick the right skill:

| Task Type | Claude Should Use | Fallback |
|-----------|-----------------|----------|
| "What does this function do?" | **decompile_function** | get_function_summary |
| "Is this binary packed?" | **get_entropy** | get_sections |
| "Is this malware?" | **detect_suspicious_apis** | emulate_function |
| "What's the call structure?" | **get_call_graph** | list_functions |
| "What APIs does it use?" | **list_imports** | detect_suspicious_apis |
| "Show me the code" | **decompile_function** | search_instructions |
| "How do these functions connect?" | **get_xrefs** | get_call_graph |
| "What's in this binary?" | **list_functions + list_strings** | list_binaries |
| "What's at this address?" | **get_memory_bytes** | decompile_function |
| "Find a specific pattern" | **search_bytes** | search_strings |
| "Analyze behavior" | **emulate_function** | emulate_step |
| "Run a custom analysis" | **execute_script** | search_api |

---

## MCP Endpoint Details

| Property | Value |
|----------|-------|
| **URI** | `/mcp` |
| **Port** | 48080 |
| **Transport** | streamable-HTTP (POST and SSE supported) |
| **Protocol** | MCP 2024-11-05 |
| **Content-Type** | `application/json` |
| **Accept** | `application/json, text/event-stream` |
| **Tools** | 200+ (32 static + 2 code + 3 script + 5 resources + ~160 Ghidra Java API) |
| **Mode** | full (all 32 tools), code (search + execute), script (search_api + get_class_info + execute_script) |
| **Session** | Automatic session management via `Mcp-Session-Id` header |
