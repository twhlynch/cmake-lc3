#[[
	Verify an address is in user memory or crash.
]]
macro(vm_check_privileged addr)
	lc3_mask(${addr} ${LC3_WORD_MASK} check_addr)
	lc3_assert(
		check_addr GREATER_EQUAL ${LC3_USER_MIN} AND check_addr LESS ${LC3_USER_MAX}
		"Access Control Violation at x${check_addr}"
	)
endmacro()

#[[
	Read the value of a register by number (0-7).
]]
macro(vm_getreg reg_num result)
	lc3_assert(
		${reg_num} GREATER_EQUAL 0 AND ${reg_num} LESS_EQUAL 7
		"Invalid register ${reg_num}"
	)
	set(${result} ${R${reg_num}})
endmacro()

#[[
	Write a value to a register by number (0-7).
]]
macro(vm_setreg reg_num val)
	lc3_assert(
		${reg_num} GREATER_EQUAL 0 AND ${reg_num} LESS_EQUAL 7
		"Invalid register ${reg_num}"
	)
	lc3_mask(${val} ${LC3_WORD_MASK} masked_val)
	set(R${reg_num} ${masked_val})
endmacro()

#[[
	Set N, Z, P flags based on a result value.
]]
macro(vm_update_condition_codes val)
	# get sign bit
	lc3_mask(${val} ${LC3_WORD_MASK} cc_val)
	lc3_bits(${cc_val} ${LC3_SIGN_BIT} 1 cc_bit)

	set(CC_N 0)
	set(CC_Z 0)
	set(CC_P 0)

	if(cc_bit)
		set(CC_N 1)
	elseif(cc_val EQUAL 0)
		set(CC_Z 1)
	else()
		set(CC_P 1)
	endif()
endmacro()

#[[
	Read a 16-bit word from memory orelse 0.
]]
macro(vm_memread addr result)
	# check privilege
	vm_check_privileged(${addr})

	lc3_mask(${addr} ${LC3_WORD_MASK} mem_index)
	if(DEFINED MEM_${mem_index})
		# read if defined
		set(${result} ${MEM_${mem_index}})
	else()
		# default to 0
		set(${result} 0)
	endif()
endmacro()

#[[
	Write a 16-bit word to memory.
]]
macro(vm_memwrite addr val)
	# check privilege
	vm_check_privileged(${addr})

	# mask
	lc3_mask(${addr} ${LC3_WORD_MASK} mem_index)
	lc3_mask(${val} ${LC3_WORD_MASK} mem_val)

	# set memory
	set(MEM_${mem_index} ${mem_val})
endmacro()

#[[
	Fetch, decode, and execute a single instruction.
]]
macro(lc3_vm_step)
	# read the instruction at PC
	vm_check_privileged(${PC})
	vm_memread(${PC} instruction)

	# advance PC
	lc3_increment(PC)

	# decode the opcode from bits [15, 12]
	math(EXPR opcode "${instruction} >> 12")

	# dispatch the correct instruction
	if(opcode EQUAL 1) # 0001
		vm_exec_add(${instruction})
	elseif(opcode EQUAL 5) # 0101
		vm_exec_and(${instruction})
	elseif(opcode EQUAL 0) # 0000
		vm_exec_br(${instruction})
	elseif(opcode EQUAL 12) # 1100
		vm_exec_jmp(${instruction})
	elseif(opcode EQUAL 4) # 0100
		vm_exec_jsr(${instruction})
	elseif(opcode EQUAL 2) # 0010
		vm_exec_ld(${instruction})
	elseif(opcode EQUAL 6) # 0110
		vm_exec_ldr(${instruction})
	elseif(opcode EQUAL 10) # 1010
		vm_exec_ldi(${instruction})
	elseif(opcode EQUAL 14) # 1110
		vm_exec_lea(${instruction})
	elseif(opcode EQUAL 9) # 1001
		vm_exec_not(${instruction})
	elseif(opcode EQUAL 3) # 0011
		vm_exec_st(${instruction})
	elseif(opcode EQUAL 11) # 1011
		vm_exec_sti(${instruction})
	elseif(opcode EQUAL 7) # 0111
		vm_exec_str(${instruction})
	elseif(opcode EQUAL 15) # 1111
		vm_exec_trap(${instruction})
	elseif(opcode EQUAL 8) # 1000
		vm_exec_rti(${instruction})
	else()
		message(FATAL_ERROR "Unknown opcode: ${opcode} at PC x${PC}")
	endif()
endmacro()

#[[
	Reset VM state.
]]
macro(lc3_vm_reset)
	# zero registers
	set(R0 0)
	set(R1 0)
	set(R2 0)
	set(R3 0)
	set(R4 0)
	set(R5 0)
	set(R6 0)
	set(R7 0)

	# reset cc to zero
	set(CC_N 0)
	set(CC_Z 1)
	set(CC_P 0)

	# default to x3000
	set(PC 12288)

	# unhalt
	set(VM_HALT 0)
endmacro()

#[[
	Init VM and execute instructions until HALT.
]]
macro(lc3_vm_run start_pc)
	lc3_vm_reset()

	# jump to starting location
	set(PC ${start_pc})

	# run
	while(NOT VM_HALT)
		lc3_vm_step()
		if(VM_HALT)
			break()
		endif()
	endwhile()
endmacro()
