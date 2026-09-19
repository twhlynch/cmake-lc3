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

# MARK: per instruction encoding

#[[
	Encode a BR instruction with the given condition bits base value.
]]
macro(asm_encode_branch base_value)
	# TODO: encode branch
endmacro()

#[[
	ADD
	0001 DR SR1 000 SR2
	0001 DR SR1 1 imm5
]]
macro(asm_encode_add)
	# TODO: encode add
endmacro()

#[[
	AND
	0101 DR SR1 000 SR2
	0101 DR SR1 1 imm5
]]
macro(asm_encode_and)
	# TODO: encode and
endmacro()

#[[
	NOT
	1001 DR SR 111111
]]
macro(asm_encode_not)
	# TODO: encode not
endmacro()

#[[
	LDR
	0110 DR BaseR offset6
]]
macro(asm_encode_ldr)
	# TODO: encode ldr
endmacro()

#[[
	JMP
	1100 000 BaseR 000000
]]
macro(asm_encode_jmp)
	# TODO: encode jmp
endmacro()

#[[
	JSR
	0100 1 PCoffset11
]]
macro(asm_encode_jsr)
	# TODO: encode jsr
endmacro()

#[[
	JSRR
	0100 0 00 BaseR 000000
]]
macro(asm_encode_jsrr)
	# TODO: encode jsrr
endmacro()

#[[
	STR
	0111 SR BaseR offset6
]]
macro(asm_encode_str)
	# TODO: encode str
endmacro()

#[[
	TRAP
	1111 0000 vector8
]]
macro(asm_encode_trap)
	# TODO: encode trap
endmacro()

#[[
	RTI
	1000 000000000000
]]
macro(asm_encode_rti)
	# TODO: encode rti (maybe)
endmacro()
