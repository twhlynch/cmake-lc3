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

#[[
	Encode a pseudo-instruction (TRAP alias or RET).
]]
macro(asm_encode_pseudo opcode handled addr_var)
	set(${handled} FALSE)

	# is it a pseudoop
	list(FIND ASM_PSEUDO_NAMES "${opcode}" pseudo_idx)
	if(NOT pseudo_idx EQUAL -1)
		set(${handled} TRUE)

		# get word value
		list(GET ASM_PSEUDO_WORDS ${pseudo_idx} pseudo_word)

		# write
		asm_write_word(${addr_var} ${pseudo_word})
	endif()
endmacro()

# MARK: per instruction encoding

#[[
	Encode a PC-relative load/store instruction (ld, ldi, lea, st, sti).
]]
macro(
	asm_encode_pc_offset
	tokens
	opcode_index
	addr_var
	labels
	base_value
)
	# read reg and label
	asm_operand("${tokens}" "${opcode_index}" 1 apo_reg_str)
	asm_operand("${tokens}" "${opcode_index}" 2 apo_label)

	# resolve label to pcoffset9
	asm_resolve_pc_offset("${apo_label}" "${labels}" "${addr}" 9 apo_offset)
	lc3_reg("${apo_reg_str}" apo_reg)

	# build and write word
	lc3_mask(${apo_offset} 0x1FF apo_offset)
	math(EXPR apo_word "${base_value} | (${apo_reg} << 9) | ${apo_offset}")
	asm_write_word(${addr_var} ${apo_word})
endmacro()

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
	asm_encode_pc_offset("${tokens}" "${opcode_index}" ${addr_var} "${labels}" 0x2000)
endmacro()

#[[
	LDI
	1010 DR1 PCoffset9
]]
macro(asm_encode_ldi tokens opcode_index addr_var labels)
	asm_encode_pc_offset("${tokens}" "${opcode_index}" ${addr_var} "${labels}" 0xA000)
endmacro()

#[[
	LEA
	1110 DR1 PCoffset9
]]
macro(asm_encode_lea tokens opcode_index addr_var labels)
	asm_encode_pc_offset("${tokens}" "${opcode_index}" ${addr_var} "${labels}" 0xE000)
endmacro()

#[[
	ST
	0011 SR1 PCoffset9
]]
macro(asm_encode_st tokens opcode_index addr_var labels)
	asm_encode_pc_offset("${tokens}" "${opcode_index}" ${addr_var} "${labels}" 0x3000)
endmacro()

#[[
	STI
	1011 SR1 PCoffset9
]]
macro(asm_encode_sti tokens opcode_index addr_var labels)
	asm_encode_pc_offset("${tokens}" "${opcode_index}" ${addr_var} "${labels}" 0xB000)
endmacro()

#[[
	TRAP
	1111 0000 vector8
]]
macro(asm_encode_trap tokens opcode_index addr_var labels)
	# read vector
	asm_operand("${tokens}" "${opcode_index}" 1 trap_vector)

	# resolve and check vector8
	lc3_num("${trap_vector}" trap_num)
	lc3_assert(
		${trap_num} GREATER_EQUAL 0 AND ${trap_num} LESS_EQUAL ${LC3_TRAP_MAX}
		"TRAP vector ${trap_num} out of range"
	)

	# build and store word
	lc3_mask(${trap_num} ${LC3_BYTE_MASK} trap_num)
	math(EXPR encoded_word "0xF000 | ${trap_num}")
	asm_write_word(${addr_var} ${encoded_word})
endmacro()

#[[
	RTI
	1000 000000000000
]]
macro(asm_encode_rti tokens opcode_index addr_var labels)
	asm_write_word(${addr_var} 0x8000)
endmacro()
