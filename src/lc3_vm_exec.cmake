#[[
	ADD (0001)
	DR = SR1 + SR2 or DR = SR1 + SEXT(imm5)
	0001 DR1 SR1 0 00 SR2
	0001 DR1 SR1 1 imm5_
]]
macro(vm_exec_add instruction)
	# read DR and SR1
	lc3_bits(${instruction} 9 ${LC3_REGISTER_BITS} dest_reg) # DR = [9, 11]
	lc3_bits(${instruction} 6 ${LC3_REGISTER_BITS} src1_reg) # SR1 = [6, 8]

	# read mode bit
	lc3_bits(${instruction} 5 1 imm_mode)

	if(imm_mode)
		# sign extend imm5
		lc3_sign_extend("${instruction}" 5 val2)
	else()
		# read SR2
		lc3_bits(${instruction} 0 ${LC3_REGISTER_BITS} src2_reg) # SR2 = [0, 2]
		vm_getreg(${src2_reg} val2)
	endif()

	# add SR1 and value
	vm_getreg(${src1_reg} val1)
	math(EXPR result "${val1} + ${val2}")

	# store result in DR
	lc3_mask(${result} ${LC3_WORD_MASK} result)
	vm_setreg(${dest_reg} ${result})

	# update cc
	vm_update_condition_codes(${result})
endmacro()

#[[
	AND (0101)
	DR = SR1 & SR2 or DR = SR1 & SEXT(imm5)
	0101 DR1 SR1 0 00 SR2
	0101 DR1 SR1 1 imm5_
]]
macro(vm_exec_and instruction)
	# read DR and SR1
	lc3_bits(${instruction} 9 ${LC3_REGISTER_BITS} dest_reg)
	lc3_bits(${instruction} 6 ${LC3_REGISTER_BITS} src1_reg)

	# read mode bit
	lc3_bits(${instruction} 5 1 imm_mode)

	vm_getreg(${src1_reg} val1)
	if(imm_mode)
		# sign extend imm5
		lc3_sign_extend("${instruction}" 5 val2)
	else()
		# read SR2
		lc3_bits(${instruction} 0 ${LC3_REGISTER_BITS} src2_reg)
		vm_getreg(${src2_reg} val2)
	endif()

	# and SR1 and value
	vm_getreg(${src1_reg} val1)
	math(EXPR result "${val1} & ${val2}")

	# store result in DR
	lc3_mask(${result} ${LC3_WORD_MASK} result)
	vm_setreg(${dest_reg} ${result})

	# update cc
	vm_update_condition_codes(${result})
endmacro()

#[[
	BR (0000)
	Branch if condition codes match nzpc bits
	0000 N Z P pcoffset9
]]
macro(vm_exec_br instruction)
	# read pcoffset9
	lc3_sign_extend("${instruction}" 9 offset)

	# read cc bits
	lc3_bits(${instruction} 9 3 nzpc)
	lc3_bits(${nzpc} 2 1 test_n)
	lc3_bits(${nzpc} 1 1 test_z)
	lc3_bits(${nzpc} 0 1 test_p)

	# check against cc state
	if((test_n AND CC_N) OR (test_z AND CC_Z) OR (test_p AND CC_P))
		# jump pc offset
		math(EXPR PC "${PC} + ${offset}")
	endif()
endmacro()

#[[
	JMP (1100)
	PC = BaseR
	1100 000 BR1 000000
]]
macro(vm_exec_jmp instruction)
	# read BR
	lc3_bits(${instruction} 6 ${LC3_REGISTER_BITS} base_reg)
	vm_getreg(${base_reg} base_val)
	# jump PC to BR
	lc3_mask(${base_val} ${LC3_WORD_MASK} PC)
endmacro()

#[[
	JSR/JSRR (0100)
	Save return address, then jump
	0100 1 pcoffset11_
	0100 0 00 BR1 000000
]]
macro(vm_exec_jsr instruction)
	# read jsrr flag
	lc3_bits(${instruction} 11 1 jsrr_flag)

	# save base in case BaseR is R7
	if(NOT jsrr_flag)
		lc3_bits(${instruction} 6 ${LC3_REGISTER_BITS} base_reg)
		vm_getreg(${base_reg} saved_base_val)
	endif()

	# save return address in R7
	vm_setreg(7 ${PC})

	if(jsrr_flag)
		# sign extend pcoffset11
		lc3_sign_extend("${instruction}" 11 offset)

		# jump pc offset
		math(EXPR PC "${PC} + ${offset}")
		lc3_mask(${PC} ${LC3_WORD_MASK} PC)
	else()
		# jump pc to base
		lc3_mask(${saved_base_val} ${LC3_WORD_MASK} PC)
	endif()
endmacro()

#[[
	LD (0010)
	DR = MEM[PC + SEXT(PCoffset9)]
	0010 DR1 PCoffset9
]]
macro(vm_exec_ld instruction)
	# read DR
	lc3_bits(${instruction} 9 ${LC3_REGISTER_BITS} dest_reg)

	# sign extend pcoffset9
	lc3_sign_extend("${instruction}" 9 offset)

	# add pc offset
	math(EXPR effective_addr "${PC} + ${offset}")
	lc3_mask(${effective_addr} ${LC3_WORD_MASK} effective_addr)

	# load from memory into DR
	vm_memread(${effective_addr} val)
	vm_setreg(${dest_reg} ${val})

	# update cc
	vm_update_condition_codes(${val})
endmacro()

#[[
	LDR (0110)
	DR = MEM[BaseR + SEXT(offset6)]
	0110 DR1 BR1 offst6
]]
macro(vm_exec_ldr instruction)
	# read DR and BR
	lc3_bits(${instruction} 9 ${LC3_REGISTER_BITS} dest_reg)
	lc3_bits(${instruction} 6 ${LC3_REGISTER_BITS} base_reg)

	# sign extend offset6
	lc3_sign_extend("${instruction}" 6 offset)

	# add base offset
	vm_getreg(${base_reg} base_val)
	math(EXPR effective_addr "${base_val} + ${offset}")
	lc3_mask(${effective_addr} ${LC3_WORD_MASK} effective_addr)

	# load from memory into DR
	vm_memread(${effective_addr} val)
	vm_setreg(${dest_reg} ${val})

	# update cc
	vm_update_condition_codes(${val})
endmacro()

#[[
	LDI (1010)
	DR = MEM[ MEM[PC + SEXT(PCoffset9)] ]
	1010 DR1 PCoffset9
]]
macro(vm_exec_ldi instruction)
	# read DR
	lc3_bits(${instruction} 9 ${LC3_REGISTER_BITS} dest_reg)

	# sign extend pcoffset9
	lc3_sign_extend("${instruction}" 9 offset)

	# add pc offset
	math(EXPR effective_addr "${PC} + ${offset}")
	lc3_mask(${effective_addr} ${LC3_WORD_MASK} effective_addr)

	# load pointer then value into DR
	vm_memread(${effective_addr} pointer)
	vm_memread(${pointer} val)
	vm_setreg(${dest_reg} ${val})

	# update cc
	vm_update_condition_codes(${val})
endmacro()

#[[
	LEA (1110)
	DR = PC + SEXT(PCoffset9)
	1110 DR1 PCoffset9
]]
macro(vm_exec_lea instruction)
	# read DR
	lc3_bits(${instruction} 9 ${LC3_REGISTER_BITS} dest_reg)

	# sign extend pcoffset9
	lc3_sign_extend("${instruction}" 9 offset)

	# add pc offset
	math(EXPR effective_addr "${PC} + ${offset}")
	lc3_mask(${effective_addr} ${LC3_WORD_MASK} effective_addr)

	# store address in DR
	vm_setreg(${dest_reg} ${effective_addr})
endmacro()

#[[
	NOT (1001)
	DR = NOT(SR)
	1001 DR1 SR1 111111
]]
macro(vm_exec_not instruction)
	# read DR and SR
	lc3_bits(${instruction} 9 ${LC3_REGISTER_BITS} dest_reg)
	lc3_bits(${instruction} 6 ${LC3_REGISTER_BITS} src_reg)

	# not SR
	vm_getreg(${src_reg} val)
	math(EXPR result "~${val}")

	# store result in DR
	lc3_mask(${result} ${LC3_WORD_MASK} result)
	vm_setreg(${dest_reg} ${result})

	# update cc
	vm_update_condition_codes(${result})
endmacro()

#[[
	ST (0011)
	MEM[PC + SEXT(PCoffset9)] = SR
	0011 SR1 PCoffset9
]]
macro(vm_exec_st instruction)
	# read SR
	lc3_bits(${instruction} 9 ${LC3_REGISTER_BITS} src_reg)

	# sign extend pcoffset9
	lc3_sign_extend("${instruction}" 9 offset)

	# add pc offset
	vm_getreg(${src_reg} val)
	math(EXPR effective_addr "${PC} + ${offset}")
	lc3_mask(${effective_addr} ${LC3_WORD_MASK} effective_addr)

	# store SR in memory
	vm_memwrite(${effective_addr} ${val})
endmacro()

#[[
	STI (1011)
	MEM[ MEM[PC + SEXT(PCoffset9)] ] = SR
	1011 SR1 PCoffset9
]]
macro(vm_exec_sti instruction)
	# TODO: Execute sti instruction
endmacro()

#[[
	STR (0111)
	MEM[BaseR + SEXT(offset6)] = SR
	0111 SR1 BR1 offst6
]]
macro(vm_exec_str instruction)
	# TODO: Execute str instruction
endmacro()

#[[
	RTI (1000)
	Return from interrupt
	1000 000000000000
]]
macro(vm_exec_rti instruction)
	# NOP for now
endmacro()

#[[
	TRAP handler
	Dispatches to the appropriate trap service routine.
	1111 0000 trapvec8
]]
macro(vm_exec_trap instruction)
	# decode the trap vector from bits [7, 0]
	lc3_bits(${instruction} 0 8 trap_vector)

	# dispatch to the trap
	if(trap_vector EQUAL 0x20)
		vm_trap_getc()
	elseif(trap_vector EQUAL 0x21)
		vm_trap_out()
	elseif(trap_vector EQUAL 0x22)
		vm_trap_puts()
	elseif(trap_vector EQUAL 0x23)
		vm_trap_in()
	elseif(trap_vector EQUAL 0x24)
		vm_trap_putsp()
	elseif(trap_vector EQUAL 0x25)
		vm_trap_halt()
	elseif(trap_vector EQUAL 0x30)
		vm_trap_putn()
	elseif(trap_vector EQUAL 0x31)
		vm_trap_reg()
	else()
		lc3_hex(${PC} pc_hex)
		message(WARNING "Unknown TRAP vector x${trap_vector} at PC ${pc_hex}")
	endif()
endmacro()
