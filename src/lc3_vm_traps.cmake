#[[
	getc (x20)
	Read a single character from stdin into R0.
]]
macro(vm_trap_getc)
	# TODO: read input to R0
endmacro()

#[[
	out (x21)
	Print the character in R0 to stdout.
]]
macro(vm_trap_out)
	# TODO: print R0
endmacro()

#[[
	puts (x22)
	Print a null-terminated string starting at address in R0
]]
macro(vm_trap_puts)
	# TODO: print string at R0
endmacro()

#[[
	in (x23)
	Prompt and read a character from stdin into R0.
]]
macro(vm_trap_in)
	# TODO: prompt for input
endmacro()

#[[
	putsp (x24)
	Print a packed string.
]]
macro(vm_trap_putsp)
	# TODO: print packed string at R0
endmacro()

#[[
	halt (x25)
	Stop execution.
]]
macro(vm_trap_halt)
	set(VM_HALT 1)
endmacro()

#[[
	putn (x30)
	Print the value in R0 as a decimal number.
]]
macro(vm_trap_putn)
	# TODO: print
endmacro()

#[[
	reg (x31)
	Print all registers.
]]
macro(vm_trap_reg)
	# TODO: print all registers
endmacro()
