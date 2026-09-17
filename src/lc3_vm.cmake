#[[
	Verify an address is in user memory or crash.
]]
macro(vm_check_privileged addr)
	# TODO: check for privelaged memory access
endmacro()

#[[
	Read the value of a register by number (0-7).
]]
macro(vm_getreg reg_num result)
	# TODO: set a register
endmacro()

#[[
	Write a value to a register by number (0-7).
]]
macro(vm_setreg reg_num val)
	# TODO: get a register
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
	# TODO: initialize, jump to start, step while unhalted
endmacro()
