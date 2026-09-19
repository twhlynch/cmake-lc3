#[[
	Read a source file into a clean list of code lines.
	Removes comments, trims, and drops blanks.
]]
macro(asm_read_source filename result)
	# read file
	file(READ "${filename}" read_content)

	# strip comments first as cmake uses ; for lists
	asm_strip_comments(read_content)

	# split into lines
	asm_split_lines(read_content read_lines)

	# trim and drop blanks
	set(${result} "")
	foreach(raw_line IN LISTS read_lines)
		asm_strip_line("${raw_line}" line)
		asm_is_blank_line("${line}" blank)
		if(NOT blank)
			list(APPEND ${result} "${line}")
		endif()
	endforeach()
endmacro()

#[[
	Strip comments from a source string.
]]
macro(asm_strip_comments content)
	string(REGEX REPLACE ";[^\n]*" "" ${content} "${${content}}")
endmacro()

#[[
	Split a string into lines.
]]
macro(asm_split_lines content result)
	string(REGEX REPLACE "\r\n" "\n" ${content} "${${content}}")
	string(REGEX REPLACE "\n" ";" ${result} "${${content}}")
endmacro()

#[[
	Expand tabs and strip surrounding whitespace.
]]
macro(asm_strip_line raw_line result)
	string(REPLACE "\t" " " sl_stripped "${raw_line}")
	string(STRIP "${sl_stripped}" ${result})
endmacro()

#[[
	Check if a line is empty.
]]
macro(asm_is_blank_line line result)
	if("${line}" STREQUAL "")
		set(${result} 1)
	else()
		set(${result} 0)
	endif()
endmacro()

#[[
	Check if a character is whitespace or optional separator syntax.
]]
macro(asm_token_whitespace char result)
	set_bool(${result} "${char}" STREQUAL " " OR "${char}" STREQUAL "," OR "${char}" STREQUAL ":")
endmacro()

#[[
	Split a line of assembly into a list of tokens.
]]
macro(lc3_tokenize line result)
	set(${result} "")
	string(LENGTH "${line}" line_len)
	set(index 0)

	while(index LESS line_len)
		# skip whitespace and optional characters
		while(index LESS line_len)
			# read char
			string(SUBSTRING "${line}" ${index} 1 current_char)

			# break once at real char
			asm_token_whitespace("${current_char}" ignore_token)
			if(NOT ignore_token)
				break()
			endif()

			lc3_increment(index)
		endwhile()

		# exit at EOL
		if(index EQUAL line_len)
			break()
		endif()

		# read the next token
		string(SUBSTRING "${line}" ${index} 1 current_char)

		# are we in a string
		if(current_char STREQUAL "\"")
			set(current_token "\"")
			lc3_increment(index)

			# read until closing quote
			while(index LESS line_len)
				# read next character
				string(SUBSTRING "${line}" ${index} 1 next_char)

				# break on closing quote
				if(next_char STREQUAL "\"")
					string(APPEND current_token "\"")
					lc3_increment(index)
					break()
				endif()

				# append char to token
				string(APPEND current_token "${next_char}")

				lc3_increment(index)
			endwhile()

			# save token
			list(APPEND ${result} "${current_token}")
		else()
			set(current_token "")

			# read until end of token or line
			while(index LESS line_len)
				# read next character
				string(SUBSTRING "${line}" ${index} 1 next_char)

				# break if end of token
				asm_token_whitespace("${next_char}" ignore_token)
				if(ignore_token)
					break()
				endif()

				# append char to token
				string(APPEND current_token "${next_char}")

				lc3_increment(index)
			endwhile()

			# save token
			if(NOT current_token STREQUAL "")
				list(APPEND ${result} "${current_token}")
			endif()
		endif()
	endwhile()
endmacro()

#[[
	Parse a numeric string to an integer value.
	Supported formats: #N #-N #+N N -N +N xN -xN +xN 0xN -0xN +0xN
]]
macro(lc3_num str result)
	# validate with regex
	set(num_str "${str}") # copy to local (see assert note)
	lc3_assert(
		num_str MATCHES
		"^(#?[+-]?[0-9]+|[+-]?0?x[0-9a-fA-F]+)$"
		"Invalid number: ${str}"
	)

	# strip # prefix
	string(REGEX REPLACE "#" "" num "${str}")

	# add 0 prefix for hex
	string(REGEX REPLACE "^([+-]?)x" "\\10x" num "${num}")

	# evaluate with math
	math(EXPR ${result} "${num}")
endmacro()

#[[
	Parse a register name to its number.
]]
macro(lc3_reg str result)
	# normalise to uppercase
	string(TOUPPER "${str}" upper_reg)

	# must match R0-R7
	lc3_assert(upper_reg MATCHES "^R[0-7]$" "Invalid register: ${str}")

	# return the digit
	string(SUBSTRING "${upper_reg}" 1 1 ${result})
endmacro()
