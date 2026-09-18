#[[
	ADD (0001)
	DR = SR1 + SR2 or DR = SR1 + SEXT(imm5)
	0001 DR1 SR1 0 00 SR2
	0001 DR1 SR1 1 imm5_
]]
macro(vm_exec_add instruction)
	# read DR and SR1
	lc3_bits(${instruction} 9 3 dest_reg) # DR = [9, 11]
	lc3_bits(${instruction} 6 3 src1_reg) # SR1 = [6, 8]

	# read mode bit
	lc3_bits(${instruction} 5 1 imm_mode)

	if(imm_mode)
		# sign extend imm5
		lc3_sign_extend("${instruction}" 5 val2)
	else()
		# read SR2
		lc3_bits(${instruction} 0 3 src2_reg) # SR2 = [0, 2]
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
]]
macro(vm_exec_and instruction)
	# TODO: Execute and instruction
endmacro()

#[[
	BR (0000)
	Branch if condition codes match nzpc bits
]]
macro(vm_exec_br instruction)
	# TODO: Execute br instruction
endmacro()

#[[
	JMP (1100)
	PC = BaseR
]]
macro(vm_exec_jmp instruction)
	# TODO: Execute JMP instruction
endmacro()

#[[
	JSR/JSRR (0100)
	Save return address, then jump
]]
macro(vm_exec_jsr instruction)
	# TODO: Execute jsr/jsrr instructions
endmacro()

#[[
	LD (0010)
	DR = MEM[PC + SEXT(PCoffset9)]
]]
macro(vm_exec_ld instruction)
	# TODO: Execute ld instruction
endmacro()

#[[
	LDR (0110)
	DR = MEM[BaseR + SEXT(offset6)]
]]
macro(vm_exec_ldr instruction)
	# TODO: Execute ldr instruction
endmacro()

#[[
	LDI (1010)
	DR = MEM[ MEM[PC + SEXT(PCoffset9)] ]
]]
macro(vm_exec_ldi instruction)
	# TODO: Execute ldi instruction
endmacro()

#[[
	LEA (1110)
	DR = PC + SEXT(PCoffset9)
]]
macro(vm_exec_lea instruction)
	# TODO: Execute lea instruction
endmacro()

#[[
	NOT (1001)
	DR = NOT(SR)
]]
macro(vm_exec_not instruction)
	# TODO: Execute not instruction
endmacro()

#[[
	ST (0011)
	MEM[PC + SEXT(PCoffset9)] = SR
]]
macro(vm_exec_st instruction)
	# TODO: Execute st instruction
endmacro()

#[[
	STI (1011)
	MEM[ MEM[PC + SEXT(PCoffset9)] ] = SR
]]
macro(vm_exec_sti instruction)
	# TODO: Execute sti instruction
endmacro()

#[[
	STR (0111)
	MEM[BaseR + SEXT(offset6)] = SR
]]
macro(vm_exec_str instruction)
	# TODO: Execute str instruction
endmacro()

#[[
	RTI (1000)
	Return from interrupt
]]
macro(vm_exec_rti instruction)
	# TODO: Execute rti instruction (maybe)
endmacro()

#[[
	TRAP handler
	Dispatches to the appropriate trap service routine.
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
