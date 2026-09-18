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
