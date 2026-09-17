#[[
	getc (x20)
	Read a single character from stdin into R0.
]]
macro(vm_trap_getc)
	# get input
	lc3_input(getc_char)

	# store ordinal value or 0
	if(getc_char STREQUAL "")
		set(R0 0)
	else()
		lc3_ord("${getc_char}" R0)
	endif()
endmacro()

#[[
	out (x21)
	Print the character in R0 to stdout.
]]
macro(vm_trap_out)
	# print the low byte of R0
	lc3_low_byte(${R0} out_char)
	lc3_print_ord(${out_char})
endmacro()

#[[
	puts (x22)
	Print a null-terminated string starting at address in R0
]]
macro(vm_trap_puts)
	# R0 is starting address
	set(puts_addr ${R0})

	while(TRUE)
		# read a character from memory
		vm_memread(${puts_addr} puts_char)

		# break on null terminator
		if(puts_char EQUAL 0)
			break()
		endif()

		# print the low byte
		lc3_low_byte(${puts_char} puts_char_code)
		lc3_print_ord(${puts_char_code})

		# increment address
		lc3_increment(puts_addr)
	endwhile()
endmacro()

#[[
	in (x23)
	Prompt and read a character from stdin into R0.
]]
macro(vm_trap_in)
	message(STATUS "Input: ")

	# get input
	lc3_input(in_char)

	# store ordinal value or 0
	if(NOT in_char STREQUAL "")
		lc3_ord("${in_char}" R0)
	else()
		set(R0 0)
	endif()

	# echo the low byte
	lc3_low_byte("${R0}" in_char_code)
	lc3_print_ord(${in_char_code})
endmacro()

#[[
	putsp (x24)
	Print a packed string.
]]
macro(vm_trap_putsp)
	# R0 is starting address
	set(putsp_addr ${R0})

	while(TRUE)
		# read a word from memory
		vm_memread(${putsp_addr} putsp_word)

		# break on null terminator
		if(putsp_word EQUAL 0)
			break()
		endif()

		# low byte first
		lc3_low_byte(${putsp_word} putsp_lo)
		lc3_print_ord(${putsp_lo})

		# high byte second
		lc3_high_byte(${putsp_word} putsp_hi)
		lc3_print_ord(${putsp_hi})

		# increment address
		lc3_increment(putsp_addr)
	endwhile()
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
