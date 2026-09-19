# regex patterns
set(LC3_NUM_PATTERN "^(#?[+-]?[0-9]+|[+-]?0?x[0-9a-fA-F]+)$")
set(LC3_REG_PATTERN "^[Rr][0-7]$")
set(LC3_LABEL_PATTERN "^[A-Za-z_][A-Za-z0-9_]*$")
set(
	LC3_INSTRUCTION_PATTERN
	"^(ADD|AND|BR|BRN|BRZ|BRP|BRNZ|BRNP|BRZP|BRNZP|JMP|JSR|JSRR|LD|LDI|LDR|LEA|NOT|ST|STI|STR|TRAP|RTI|HALT|RET|PUTS|PUTSP|GETC|OUT|IN|PUTN|REG)$"
)
set(LC3_DIRECTIVE_PATTERN "^\\.(ORIG|END|FILL|BLKW|STRINGZ)$")

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
	if("${char}" STREQUAL " " OR "${char}" STREQUAL "," OR "${char}" STREQUAL ":")
		set(${result} TRUE)
	else()
		set(${result} FALSE)
	endif()
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
		"${LC3_NUM_PATTERN}"
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
	lc3_assert(upper_reg MATCHES "${LC3_REG_PATTERN}" "Invalid register: ${str}")

	# return the digit
	string(SUBSTRING "${upper_reg}" 1 1 ${result})
endmacro()

#[[
	Check if a string is a valid number.
]]
macro(asm_is_number str result)
	if("${str}" MATCHES "${LC3_NUM_PATTERN}")
		set(${result} TRUE)
	else()
		set(${result} FALSE)
	endif()
endmacro()

#[[
	Check if a string is a valid register.
]]
macro(asm_is_register str result)
	if("${str}" MATCHES "${LC3_REG_PATTERN}")
		set(${result} TRUE)
	else()
		set(${result} FALSE)
	endif()
endmacro()

#[[
	Check if a token is a known instruction or pseudoop.
]]
macro(asm_is_instruction name result)
	# normalise to uppercase
	string(TOUPPER "${name}" upper_name)

	# check against mnemonics
	set_bool(
		${result}
		upper_name MATCHES
		"${LC3_INSTRUCTION_PATTERN}"
	)
endmacro()

#[[
	Check if a token is an assembler directive.
]]
macro(asm_is_directive name result)
	# normalise to uppercase
	string(TOUPPER "${name}" upper_name)

	# check against directives
	set_bool(
		${result}
		upper_name MATCHES
		"${LC3_DIRECTIVE_PATTERN}"
	)
endmacro()

#[[
	Check if a token is a valid label.
]]
macro(asm_is_label name result)
	string(LENGTH "${name}" label_len)
	if(
		# matches pattern
		"${name}" MATCHES "${LC3_LABEL_PATTERN}"
		# length <= 20
		AND label_len LESS_EQUAL 20
	)
		asm_is_instruction("${name}" is_instruction)
		asm_is_register("${name}" is_register)
		asm_is_number("${name}" is_number)

		set_bool(${result} NOT is_instruction AND NOT is_register AND NOT is_number)
	else()
		set(${result} FALSE)
	endif()
endmacro()

#[[
	Error if the token is an unknown directive.
]]
macro(asm_check_directive token)
	asm_is_directive("${token}" known_dir)
	# not a directive but starts with "."
	if("${token}" MATCHES "^\\." AND NOT known_dir)
		message(FATAL_ERROR "Invalid directive: ${token}")
	endif()
endmacro()

#[[
	Detect whether the first token is a label.
]]
macro(asm_detect_label tokens has_label label_name)
	set(${has_label} FALSE)
	set(${label_name} "")

	# get token
	list(GET ${tokens} 0 first_token)

	# check
	asm_is_label("${first_token}" is_label)
	if(is_label)
		set(${has_label} TRUE)
		set(${label_name} "${first_token}")
	endif()
endmacro()

#[[
	Look up a label name in a label list.
	Labels are stored as "NAME:ADDRESS".
]]
macro(asm_find_label label labels found address)
	set(${found} FALSE)
	set(${address} FALSE)

	# scan labels
	foreach(entry ${labels})
		# get name
		string(FIND "${entry}:" ":" colon_pos)
		string(SUBSTRING "${entry}" 0 ${colon_pos} entry_name)

		if(entry_name STREQUAL "${label}")
			# get address
			math(EXPR entry_offset "${colon_pos} + 1")
			string(SUBSTRING "${entry}" ${entry_offset} -1 entry_addr)

			# set results
			set(${address} "${entry_addr}")
			set(${found} TRUE)
			break()
		endif()
	endforeach()
endmacro()

#[[
	Register a label at an address in the label list.
]]
macro(asm_register_label labels label addr)
	# check for duplicate
	foreach(entry ${${labels}})
		# get name
		string(FIND "${entry}:" ":" colon_pos)
		string(SUBSTRING "${entry}" 0 ${colon_pos} entry_name)

		set(label_str "${label}") # copy to local (see assert note)
		lc3_assert(NOT entry_name STREQUAL label_str "Duplicate label: ${label}")
	endforeach()

	# validate label
	asm_is_label("${label}" is_label)
	lc3_assert(is_label "Invalid label: ${label}")

	# add to list
	list(APPEND ${labels} "${label}:${addr}")
endmacro()
