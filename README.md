# LC-3 in CMake

An LC-3 emulator implemented entirely in CMake.

## Usage

```bash
cmake -P lc3.cmake example.asm
```

## Implementation Naming

### Globals

- `R0`-`R7` - Registers
- `PC` - Program counter
- `CC_<N\|Z\|P>` - Condition codes
- `VM_HALT` - Execution state
- `MEM_<addr>` - Memory at `<addr>`
- `ASM_ORIGIN` - Value of `.ORIG`
- `ASM_PC` - Assembly PC to start at

### Macro prefixes

- `lc3_` - General public api
- `lc3_asm_` - Assembler public api
- `asm_` - Assembler general
- `asm_encode_` - Assembler encoding
- `lc3_vm_` - VM public api
- `vm_` - VM general
- `vm_exec_` - General runtime
- `vm_trap_` - Runtime traps
