# MARK: contants

set(LC3_REGISTER_COUNT 8)

set(LC3_BYTE_BITS 8)
set(LC3_BYTE_MASK 0xFF)
set(LC3_WORD_MASK 0xFFFF)
set(LC3_SIGN_BIT 15)

set(LC3_ASCII_LIMIT 128)

set(LC3_MEMORY_SIZE 65536) # x10000
set(LC3_USER_MIN 12288) # x3000
set(LC3_USER_MAX 65024) # xFE00

# MARK: interactive

#[[
	Throws a FATAL_ERROR if the condition is not met.
]]
macro(lc3_assert)
	set(assert_args ${ARGV})
	list(GET assert_args -1 assert_msg)
	list(REMOVE_AT assert_args -1)
	if(NOT (${assert_args}))
		message(FATAL_ERROR "${assert_msg}")
	endif()
endmacro()

#[[
	Read a character from stdin.
]]
macro(lc3_input result)
	# HACK: cmake cant read from stdin so we must use dd
	execute_process(
		COMMAND sh -c "dd bs=1 count=1 2>/dev/null"
		INPUT_FILE /dev/stdin
		OUTPUT_VARIABLE ${result}
		OUTPUT_STRIP_TRAILING_WHITESPACE
		ERROR_QUIET
	)
endmacro()

#[[
	Print a string to stdout without a newline.
]]
macro(lc3_print str)
	# HACK: cmake cant print without a newline so we must use printf
	execute_process(COMMAND /usr/bin/printf "%s" "${str}")
endmacro()

# MARK: math and conversions

#[[
	Convert a single character to its ASCII ordinal value.
]]
macro(lc3_ord char result)
	string(HEX "${char}" hex_val)
	math(EXPR ${result} "0x${hex_val}")
endmacro()

#[[
	Convert an ASCII ordinal value to its ASCII character.
]]
macro(lc3_chr code result)
	string(ASCII "${code}" ${result})
endmacro()

#[[
	Mask a value with a bitmask.
]]
macro(lc3_mask input mask result)
	math(EXPR ${result} "${input} & ${mask}")
endmacro()

#[[
	Mask the high byte of a 16 bit word.
]]
macro(lc3_high_byte input result)
	math(EXPR ${result} "(${input} >> ${LC3_BYTE_BITS}) & ${LC3_BYTE_MASK}")
endmacro()

#[[
	Mask the low byte of a 16 bit word.
]]
macro(lc3_low_byte input result)
	math(EXPR ${result} "${input} & ${LC3_BYTE_MASK}")
endmacro()

#[[
	Print a single ASCII ordinal value to stdout without a newline.
	Handles null bytes by emitting a real null byte since CMake cannot.
]]
macro(lc3_print_ord code)
	if(${code} EQUAL 0)
		# HACK: cmake cant print without a newline so we must use printf
		execute_process(COMMAND /usr/bin/printf [[\0]])
	else()
		lc3_chr(${code} print_ord_char)
		lc3_print("${print_ord_char}")
	endif()
endmacro()

#[[
	Increment a variable by 1.
]]
macro(lc3_increment var)
	math(EXPR ${var} "${${var}} + 1")
endmacro()

#[[
	Extract a bit field from a value.

	value:  the value to extract from
	shift:  right-shift amount
	width:  number of bits to extract
	result: variable name to store the result
]]
macro(lc3_bits value shift width result)
	math(EXPR ${result} "(${value} >> ${shift}) & ((1 << ${width}) - 1)")
endmacro()

#[[
	Format a 16-bit value as a hex string with "x" prefix.
]]
macro(lc3_hex val result)
	lc3_mask(${val} ${LC3_WORD_MASK} hex_val)

	set(hex_digits "0123456789ABCDEF")
	set(${result} "")

	# extract 4 hex digits from least significant to most significant
	foreach(hex_index RANGE 3)
		# extract the nibble at position hex_index
		math(EXPR hex_nibble "${hex_val} >> ((${hex_index}) * 4)")
		lc3_mask(${hex_nibble} "0xF" hex_nibble)

		# get corresponding hex character
		string(SUBSTRING "${hex_digits}" ${hex_nibble} 1 hex_char)
		set(${result} "${hex_char}${${result}}")
	endforeach()

	set(${result} "x${${result}}")
endmacro()

#[[
	Convert a uint16 to an int16.
]]
macro(lc3_sint val result)
	if(${val} GREATER_EQUAL 32768)
		math(EXPR ${result} "${val} - 65536")
	else()
		set(${result} ${val})
	endif()
endmacro()

#[[
	Pad left width of string with spaces.
]]
macro(lc3_fmt_pad value width result)
	# build padding
	string(LENGTH "${value}" value_len)
	math(EXPR fmt_pad "${width} - ${value_len}")
	string(REPEAT " " ${fmt_pad} fmt_pad_str)

	# join padding and value
	set(${result} "${fmt_pad_str}${value}")
endmacro()

#[[
	Format an int as %+Nd
]]
macro(lc3_fmt_sint val digits result)
	# prepend + if positive
	if(${val} GREATER_EQUAL 0)
		set(fmt_str "+${val}")
	else()
		set(fmt_str "${val}")
	endif()

	# pad left
	lc3_fmt_pad(${fmt_str} ${digits} ${result})
endmacro()
