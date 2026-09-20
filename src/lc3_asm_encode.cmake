#[[
	Write an encoded word to memory and advance the address counter.
]]
macro(asm_write_word addr_var word)
	# check privilege
	lc3_check_privileged(${${addr_var}})

	# store word in memory
	set(MEM_${${addr_var}} ${word})

	# advance address
	lc3_increment(${addr_var})
endmacro()

# pseudoops are aliases for other instructions
set(ASM_PSEUDO_NAMES "HALT;PUTS;PUTSP;GETC;OUT;IN;PUTN;REG;RET")
set(
	ASM_PSEUDO_WORDS
	"0xF025;0xF022;0xF024;0xF020;0xF021;0xF023;0xF030;0xF031;0xC1C0"
)

# br variants with different condition bits
set(ASM_BR_NAMES "BR;BRNZP;BRN;BRZ;BRP;BRNZ;BRNP;BRZP")
set(ASM_BR_BASES "0x0E00;0x0E00;0x0800;0x0400;0x0200;0x0C00;0x0A00;0x0600")


# MARK: per instruction encoding

#[[
	Encode a BR instruction with the given condition bits base value.
]]
macro(asm_encode_branch tokens opcode_index addr_var labels)
	# TODO: encode branch
endmacro()

#[[
	ADD
	0001 DR SR1 000 SR2
	0001 DR SR1 1 imm5
]]
macro(asm_encode_add tokens opcode_index addr_var labels)
	# TODO: encode add
endmacro()

#[[
	AND
	0101 DR SR1 000 SR2
	0101 DR SR1 1 imm5
]]
macro(asm_encode_and tokens opcode_index addr_var labels)
	# TODO: encode and
endmacro()

#[[
	NOT
	1001 DR SR 111111
]]
macro(asm_encode_not tokens opcode_index addr_var labels)
	# TODO: encode not
endmacro()

#[[
	LDR
	0110 DR BaseR offset6
]]
macro(asm_encode_ldr tokens opcode_index addr_var labels)
	# TODO: encode ldr
endmacro()

#[[
	JMP
	1100 000 BaseR 000000
]]
macro(asm_encode_jmp tokens opcode_index addr_var labels)
	# TODO: encode jmp
endmacro()

#[[
	JSR
	0100 1 PCoffset11
]]
macro(asm_encode_jsr tokens opcode_index addr_var labels)
	# TODO: encode jsr
endmacro()

#[[
	JSRR
	0100 0 00 BaseR 000000
]]
macro(asm_encode_jsrr tokens opcode_index addr_var labels)
	# TODO: encode jsrr
endmacro()

#[[
	STR
	0111 SR BaseR offset6
]]
macro(asm_encode_str tokens opcode_index addr_var labels)
	# TODO: encode str
endmacro()

#[[
	LD
	0010 DR1 PCoffset9
]]
macro(asm_encode_ld tokens opcode_index addr_var labels)
endmacro()

#[[
	LDI
	1010 DR1 PCoffset9
]]
macro(asm_encode_ldi tokens opcode_index addr_var labels)
endmacro()

#[[
	LEA
	1110 DR1 PCoffset9
]]
macro(asm_encode_lea tokens opcode_index addr_var labels)
endmacro()

#[[
	ST
	0011 SR1 PCoffset9
]]
macro(asm_encode_st tokens opcode_index addr_var labels)
endmacro()

#[[
	STI
	1011 SR1 PCoffset9
]]
macro(asm_encode_sti tokens opcode_index addr_var labels)
endmacro()

#[[
	TRAP
	1111 0000 vector8
]]
macro(asm_encode_trap tokens opcode_index addr_var labels)
	# TODO: encode trap
endmacro()

#[[
	RTI
	1000 000000000000
]]
macro(asm_encode_rti tokens opcode_index addr_var labels)
	# TODO: encode rti (maybe)
endmacro()
