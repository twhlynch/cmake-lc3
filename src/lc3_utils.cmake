# MARK: contants

set(LC3_REGISTER_COUNT 8)

set(LC3_BYTE_BITS 8)
set(LC3_BYTE_MASK 0xFF)
set(LC3_WORD_MASK 0xFFFF)

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

