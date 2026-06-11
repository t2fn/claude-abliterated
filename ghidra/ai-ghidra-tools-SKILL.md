---
name: ai-ghidra-tools
description: AI-enhanced Ghidra tools for precise, operation-by-operation binary analysis — prevents Claude from prematurely declaring "I understand" by requiring step-by-step verification before confident assertions
---

# AI-Ghidra-Tools Skills (claude-abliterated)

**Purpose**: Provide Claude with **operation-by-operation** Ghidra tools that produce verifiable, step-by-step binary analysis. Unlike inference-based analysis, these tools require Claude to observe actual operations (disassembly, decompilation, emulation) before declaring conclusions.

## The Problem This Solves

Claude Code tends to be **too zealous** in declaring "I understand" when:
- It sees a pattern of bytes and **assumes** it's a known hash algorithm (e.g., MD5, SHA256)
- It reads a decompiled function and **infers** the control flow without verifying
- It matches a function name and **claims** its purpose without checking the body
- It calculates a hash value and **reproduces it** using RFC-standard logic instead of reading the actual bytes from memory

**The fix**: Use **ai-ghidra-tools** to verify each operation individually — disassemble, decompile, read bytes, compare hashes — before making confident assertions.

---

## Quality Assessment Scale

Claude should calibrate its confidence level using this scale:

| Confidence | Language | When to Use |
|------------|----------|-------------|
| **CONFIRMED** | "I can confirm..." | All operations verified; byte-level match; decompiled body matches pattern |
| **VERIFIED** | "The data shows..." | Multiple tools corroborate; function name + disassembly + decompilation all agree |
| **LIKELY** | "It appears that..." / "It seems like..." | Pattern match found but not fully verified; may be close but needs deeper investigation |
| **INVESTIGATING** | "I am investigating..." | Initial observations suggest X, but Claude needs to check more before asserting |
| **PROVISIONAL** | "According to the pattern I found YYY, it may be XXX" | Pattern detected but unverified; Claude should investigate further by ZZZ |
| **SUSPECTED** | "I suspect this is XXX" | Strong indicators but not enough tools called yet to be certain |

---

## Core ai-ghidra-tools

### 1. AnalyzeBinary
**What it does**: Imports a binary, runs Ghidra's analysis, returns structured metadata (architecture, entry point, function count, memory blocks, MD5, format)

**Value**: The **first tool to call** for any binary. Provides the factual baseline — architecture, format, entry point, memory layout — before any inference.

**When Claude should use it**:
- Before **any** other analysis (it must be called first)
- When Claude needs to know the binary's architecture (x86, ARM, MIPS, etc.)
- When Claude needs to verify the executable format (ELF, PE, Mach-O)

**Quality hint**: Claude should report the actual values from `AnalyzeBinary` (not guess). Example: "The binary is an ELF x86-64 at entry point 0x400000 with 47 functions" — not "this looks like an ELF file."

### 2. DecompileFunction
**What it does**: Decompile a specific function to C pseudocode via Ghidra's decompiler

**Value**: Converts machine code to readable C. Claude should **not** infer function behavior from the name alone.

**When Claude should use it**:
- When the user asks "what does this function do?"
- When Claude sees a function and needs to confirm its purpose
- When Claude suspects a hash, encryption, or parsing function

**Quality hint**: If Claude sees a function named `crypt_func` and sees `AES_encrypt` in the disassembly, it should **CONFIRM** by also checking `GetXrefs` to see who calls it. If Claude only checks the name and disassembly without the decompiled body, it should say **LIKELY** ("it appears to be a crypto function") rather than **CONFIRMED**.

### 3. IdentifyAndRenameHashMatches
**What it does**: Identifies hash matches between binary functions and known hash algorithms. **This is the critical tool for the user's specific problem.**

**Value**: Computes function hashes from **normalized opcodes** (ignoring absolute addresses), allowing identical code at different memory locations to be matched across binary versions.

**When Claude should use it**:
- When Claude suspects a function is implementing a hash algorithm (MD5, SHA, CRC, etc.)
- When Claude needs to verify if a "custom hash" is actually a standard one
- When Claude is doing cross-version comparison of binaries

**Quality hint**: This tool distinguishes **actual hashes** (computed from normalized opcodes) from **RFC-standard hashes** (theoretical, based on the algorithm specification). Claude should use the actual function hash (not the RFC hash) when determining what a function does.

### 4. GetDisassembly
**What it does**: Returns raw assembly instructions for a function or address range, including bytes, mnemonics, operands, and flows.

**Value**: Shows the **exact** bytes and instructions. Claude should read the actual bytes (e.g., `48 89 e5` = `mov rbp, rsp`) rather than inferring from the mnemonic alone.

**When Claude should use it**:
- When Claude needs to verify a specific instruction sequence
- When Claude needs the raw bytes (for byte-level analysis)
- When Claude suspects a function but wants to verify the opcode pattern

**Quality hint**: Claude should **not** say "this is a function prologue" based on `mov rbp, rsp` alone. It should verify by checking: (1) the bytes are `55 48 89 e5`, (2) the next instructions follow the expected pattern, and (3) the stack frame is set up correctly.

### 5. GetDataAtAddress
**What it does**: Reads and interprets data at a specific address — bytes, integers, pointers, strings, with type-specific interpretation.

**Value**: Claude can **read actual data** from the binary instead of calculating hashes or interpreting values theoretically.

**When Claude should use it**:
- When Claude needs to verify a specific byte or multi-byte value
- When Claude needs to read a pointer and see what it points to
- When Claude needs to check if a value is a string, integer, or pointer

**Quality hint**: Claude should read the **actual bytes** at the address, not the calculated value. If Claude says "this value is 0x1234," it should show the bytes at that address are `34 12` (little-endian), not just report the computed value.

### 6. GetSymbols
**What it does**: Gets imported and exported symbols, external dependencies, and entry points.

**Value**: Claude can see the **actual** imports/exports rather than inferring from function names.

**When Claude should use it**:
- Before deep analysis to understand external dependencies
- When Claude needs to verify a function is imported (not local)
- When Claude needs to see what the binary provides to callers

**Quality hint**: Claude should distinguish between **imported** functions (called from outside) and **exported** functions (called from the binary's callers). Claude should not assume all `printf` calls mean "printf is imported" — it should check the symbol table.

### 7. GetXrefs
**What it does**: Gets cross-references to/from an address — callers, callees, data references.

**Value**: Claude can trace the **actual** flow of control and data, not just infer from function names.

**When Claude should use it**:
- When Claude needs to understand who calls a function
- When Claude needs to trace call chains
- When Claude sees a function and wants to verify its role in the program

**Quality hint**: Claude should use `GetXrefs` to verify that a function is actually called by the caller it suspects, not just assume based on the function name.

### 8. GetCallGraph
**What it does**: Returns the function call graph with BFS depth control.

**Value**: Claude can see the complete call hierarchy, not just individual functions.

**When Claude should use it**:
- When Claude needs to understand function relationships
- When Claude is tracing complex control flow
- When Claude needs to see the full call tree

**Quality hint**: Claude should use the call graph to verify its understanding of control flow, especially when the decompiled function body is complex.

### 9. PatchBytes
**What it does**: Modifies bytes at an address in the Ghidra project, with verification.

**Value**: Claude can **apply** hypotheses and verify them by re-reading the modified bytes.

**When Claude should use it**:
- When Claude wants to test a hypothesis by patching bytes
- When Claude wants to modify the binary and persist the change
- When Claude needs to verify a write by reading back

**Quality hint**: Claude should **read the old bytes, apply the patch, then read the new bytes** to confirm the write was successful. This is the "operation-by-operation" verification.

### 10. GetBasicBlocks
**What it does**: Returns control-flow graph basic blocks with successor/predecessor edges.

**Value**: Claude can see the exact basic block structure, not just infer from the decompiled C.

**When Claude should use it**:
- When Claude needs to verify the control flow structure
- When Claude suspects a function has complex branching
- When Claude needs to trace execution paths

**Quality hint**: Claude should compare the **actual basic blocks** from Ghidra with the decompiled C pseudocode to ensure they match.

### 11. GetMemoryMap
**What it does**: Returns memory sections with permissions (read, write, execute), addresses, and sizes.

**Value**: Claude can see the binary layout and identify W+X sections (suspicious for packing or code injection).

**When Claude should use it**:
- When Claude needs to understand memory layout
- When Claude suspects packed or encrypted sections
- When Claude needs to find writable memory for patching

### 12. SearchBytes
**What it does**: Searches for byte patterns with wildcard support (`??` = any byte).

**Value**: Claude can find **exact** byte patterns in the binary.

**When Claude should use it**:
- When Claude suspects a specific opcode pattern (e.g., `48 89 e5` = `mov rbp, rsp`)
- When Claude needs to find instances of a specific algorithm
- When Claude needs to compare byte patterns across sections

### 13. SearchStrings
**What it does**: Finds strings in the binary with minimum length and pattern filtering.

**Value**: Claude can find text, URLs, paths, error messages, and crypto keys.

**When Claude should use it**:
- During initial reconnaissance
- When Claude suspects the binary has specific strings (crypto keywords, URLs, etc.)
- When Claude needs to verify a string is embedded in the binary (not computed at runtime)

### 14. SetFunctionSignature
**What it does**: Updates a function's return type and parameters in the Ghidra project.

**Value**: Claude can **correct** Ghidra's analysis by setting the right signature.

**When Claude should use it**:
- When Claude sees a function that Ghidra analyzed with the wrong signature
- When Claude wants to update the analysis based on decompiled body
- When Claude is annotating the binary as it analyzes

### 15. RenameSymbol
**What it does**: Renames a function or symbol, persisting changes in the Ghidra project.

**Value**: Claude can annotate the binary with its findings.

**When Claude should use it**:
- When Claude identifies a function and wants to name it
- When Claude is documenting the binary
- When Claude wants to annotate findings for later reference

### 16. AddComment
**What it does**: Adds comments at addresses (EOL, pre, post, plate, repeatable).

**Value**: Claude can annotate specific addresses with its analysis.

**When Claude should use it**:
- When Claude wants to add context to specific instructions
- When Claude is documenting its analysis
- When Claude needs to leave notes for later review

### 17. EmulateFunction
**What it does**: Executes code using Ghidra's P-code emulator with custom register/memory inputs.

**Value**: Claude can **observe** execution rather than **inferring** behavior from the decompiled C.

**When Claude should use it**:
- When Claude needs to verify a function's behavior at runtime
- When Claude suspects a function computes a hash or transforms data
- When Claude wants to trace actual execution

**Quality hint**: Claude should use emulation to **verify** its hypothesis, not just to "run" the function. If Claude suspects `process_data` computes a CRC, it should: (1) set up the input, (2) emulate, (3) read the result, and (4) compare to the expected CRC value.

### 18. ListClasses
**What it does**: Lists C++/Objective-C classes, vtables, and methods.

**Value**: Claude can see the OOP structure of C++ binaries.

**When Claude should use it**:
- When Claude needs to understand class hierarchies
- When Claude is analyzing C++ binaries
- When Claude needs to find polymorphic functions

### 19. SetAnalysisOptions
**What it does**: Sets Ghidra's analysis options (e.g., decompiler settings).

**Value**: Claude can control the analysis quality.

**When Claude should use it**:
- Before decompilation when Claude wants optimal settings
- When Claude is preparing for deep analysis
- When Claude wants to control analysis scope

---

## The Hash/Pattern Problem — Detailed

Claude's tendency to prematurely declare "I understand" is most visible in two areas:

### 1. Hash Algorithm Detection

| Scenario | Claude's Zealous Answer | Correct Answer | Tool Needed |
|----------|----------------------|---------------|------------|
| Sees `0x5D8881D0` in code | "This is MD5!" | "This could be MD5, but I need to check the function's normalized hash" | `IdentifyAndRenameHashMatches` |
| Reads a CRC value | "This must be CRC32" | "The value matches CRC32 but the function's opcode pattern differs" | `GetDataAtAddress` + `GetDisassembly` |
| Sees AES S-box | "This is AES encryption" | "The S-box is present but the key schedule and rounds need verification" | `DecompileFunction` + `GetXrefs` |

**Rule**: If Claude has only seen the **name** or **value**, say **LIKELY** or **PROVISIONAL**. If Claude has **read the actual bytes** or **emulated the function**, say **CONFIRMED** or **VERIFIED**.

### 2. Control Flow Interpretation

| Scenario | Claude's Zealous Answer | Correct Answer | Tool Needed |
|----------|----------------------|---------------|------------|
| Sees `if (x == 5)` | "This function validates input" | "This function may validate input, but the full condition chain needs checking" | `GetBasicBlocks` + `GetCallGraph` |
| Reads a loop | "This is a while loop" | "This appears to be a while loop based on the disassembly pattern" | `GetDisassembly` |
| Sees a call to `malloc` | "This function allocates memory" | "Yes, this calls malloc at address 0x401234" | `GetXrefs` |

**Rule**: If Claude has only read the **decompiled C**, say **LIKELY**. If Claude has checked the **disassembly bytes** too, say **VERIFIED**.

---

## Claude's Assessment Workflow

When Claude analyzes a binary, use this workflow to ensure quality:

### Phase 1: Reconnaissance (Low Confidence)

```
Claude: "I am investigating this binary. It appears to be an ELF executable 
        based on the magic bytes. I'm searching for interesting functions 
        and strings to understand its purpose."
```

**Tools used**: `AnalyzeBinary`, `ListFunctions`, `SearchStrings`

**Confidence**: **INVESTIGATING**

### Phase 2: Function Discovery (Moderate Confidence)

```
Claude: "I found a function at 0x401000 that looks like it may implement 
        a hash algorithm. The function name is `hash_process` and it is 
        called by `main`. The decompiled body shows a loop with XOR operations, 
        which is consistent with CRC or hash processing."
```

**Tools used**: `DecompileFunction`, `GetSymbols`, `GetXrefs`

**Confidence**: **LIKELY** / **PROVISIONAL**
**Do NOT claim**: "This is CRC32!" (Claude hasn't verified the bytes yet.)

### Phase 3: Verification (High Confidence)

```
Claude: "I have verified that the function at 0x401000 implements CRC32. 
        The normalized opcode hash matches the known CRC32 pattern (0x5D8881D0), 
        and the actual bytes at the address read `34 12 00 00` (CRC value). 
        The function also matches another instance at 0x402000 via the hash index."
```

**Tools used**: `IdentifyAndRenameHashMatches`, `GetDataAtAddress`, `GetDisassembly`, `GetXrefs`

**Confidence**: **VERIFIED** / **CONFIRMED**
**Do claim**: "This IS CRC32, verified by multiple tools."

### Phase 4: Cross-Reference (Full Closure)

```
Claude: "The hash function at 0x401000 is called by `main` at 0x400500, 
        which receives its input from `read_input` (0x400300). The input is 
        a 256-byte buffer from the file at offset 0x1000. I can confirm this 
        is CRC32 processing because: (1) the function hash matches, (2) the 
        bytes are verified, (3) the caller passes a buffer, and (4) the result 
        is stored at 0x403000."
```

**Tools used**: `GetCallGraph`, `GetDataAtAddress`, `GetMemoryMap`

**Confidence**: **CONFIRMED** (full closure — Claude has traced the full path)

---

## When Claude Should NOT Be Confident

Claude should **tone down** its assertions when:

| Condition | Claude Should Say | Claude Should NOT Say |
|-----------|-----------------|---------------------|
| Only function name checked | "It seems like it may be X" | "This is X" |
| Only decompiled C checked | "It appears that X" | "X is the answer" |
| Only one tool used | "I am investigating X" | "I understand X" |
| Hash value seen but not bytes | "This is likely X" | "X matches perfectly" |
| Emulation result not compared | "The function may be X" | "X is confirmed" |
| Pattern found but not normalized | "This resembles X" | "X is verified" |
| Single byte at address | "This could be X" | "X is the value" |
| Multiple binaries present | "I am checking the correct binary" | "This binary has X" |

---

## When Claude Should BE Confident

Claude can **escalate** to CONFIRMED when:

| Condition | Evidence |
|-----------|---------|
| Function name + decompiled body + disassembly bytes agree | Triple verification |
| Hash index match + actual bytes match + xrefs confirm | Full chain of evidence |
| Emulation result matches expected + bytes verified | Runtime + static verification |
| Multiple functions match the pattern (cross-version) | Robust pattern |
| Claude has read the actual bytes from memory (not calculated) | Ground truth |
| Claude has checked the function's callers and callees | Context verification |

---

## Claude's Response Templates

### For Incomplete Analysis (tone down)

> "I am investigating the function at `0x401000`. It **seems like it may be** a CRC32 implementation based on the pattern I found in the decompiled body — the XOR operations and loop structure are consistent. However, I have not yet **verified the actual bytes** at the CRC storage location, nor have I checked if the function's normalized hash matches the CRC32 pattern. **Do you want me to investigate further by** reading the bytes at `0x403000` and calling `IdentifyAndRenameHashMatches`?"

### For Partial Analysis (moderate confidence)

> "The data **shows that** the function at `0x401000` likely implements CRC32. The decompiled pseudocode contains the expected XOR and shift operations, and the function is called by `main`. However, I have only checked the decompiled C — I have not yet read the raw bytes from memory or compared the normalized hash. My confidence is **LIKELY** (not CONFIRMED)."

### For Full Analysis (high confidence)

> "I can **confirm** that the function at `0x401000` implements CRC32. The normalized opcode hash is `0x5D8881D0` (matching CRC32), the actual bytes at the storage location are `34 12 00 00` (little-endian CRC32), and the function's callers and callees are verified via `GetXrefs`. The result **is** CRC32, not just resembling it."

---

## Tools Emphasis Order (For AI Assessment)

Ranked by how much they help Claude avoid premature confidence:

| Rank | Tool | Why It Matters for Quality |
|------|------|-------------------------|
| 1 | **IdentifyAndRenameHashMatches** | Distinguishes actual hashes from RFC-standard hashes |
| 2 | **GetDataAtAddress** | Reads actual bytes (not calculated values) |
| 3 | **GetDisassembly** | Shows actual instructions and bytes |
| 4 | **GetXrefs** | Verifies caller/callee relationships |
| 5 | **DecompileFunction** | Decompiled C pseudocode (but Claude must not rely on it alone) |
| 6 | **EmulateFunction** | Runtime verification of behavior |
| 7 | **GetBasicBlocks** | Control flow structure verification |
| 8 | **GetCallGraph** | Full call hierarchy verification |
| 9 | **GetSymbols** | Actual imports/exports, not inferred |
| 10 | **PatchBytes** | Write + read-back verification |
| 11 | **GetMemoryMap** | Memory layout verification |
| 12 | **AnalyzeBinary** | Baseline facts (architecture, entry point, function count) |
| 13 | **SetFunctionSignature** | Corrects Ghidra's analysis |
| 14 | **SearchBytes** | Exact byte pattern matching |
| 15 | **ListClasses** | OOP structure verification |
| 16 | **AddComment** | Annotation for documentation |
| 17 | **RenameSymbol** | Annotation for documentation |
| 18 | **SetAnalysisOptions** | Controls analysis quality |
| 19 | **SearchStrings** | String-based evidence |

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
| **Plus**: ai-ghidra-tools (19 specialized tools) |
| **Mode** | full (all 32 tools), code (search + execute), script (search_api + get_class_info + execute_script) |
| **Session** | Automatic session management via `Mcp-Session-Id` header |
