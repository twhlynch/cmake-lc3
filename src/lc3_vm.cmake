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
	# TODO: set condition code
endmacro()

#[[
	Read a 16-bit word from memory orelse 0.
]]
macro(vm_memread addr result)
	# TODO: read from MEM_<ddr>
endmacro()

#[[
	Write a 16-bit word to memory.
]]
macro(vm_memwrite addr val)
	# TODO: write to MEM_<ddr>
endmacro()

#[[
	Fetch, decode, and execute a single instruction.
]]
macro(lc3_vm_step)
	# TODO: read instruction, decode, dispatch to vm_exec_<instruction>
endmacro()

#[[
	Init VM and execute instructions until HALT.
]]
macro(lc3_vm_run start_pc)
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

	# jump to starting location
	set(PC ${start_pc})

	# unhalt and run
	set(VM_HALT 0)
	while(NOT VM_HALT)
		lc3_vm_step()
		if(VM_HALT)
			break()
		endif()
	endwhile()
endmacro()
