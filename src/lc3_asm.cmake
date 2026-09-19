#[[
	Collect labels and compute their addresses.
	source_lines_var must contain the source lines.
]]
macro(asm_pass1 source_lines_var labels_out)
	set(labels "")
	set(addr 0)
	set(orig_found FALSE)

	foreach(raw_line IN LISTS ${source_lines_var})
		# tokenize line and detect label
		lc3_tokenize("${raw_line}" tokens)
		asm_detect_label(tokens has_label label_name)

		# collect label if present
		if(has_label)
			asm_register_label(labels "${label_name}" ${addr})
		endif()

		# find opcode after any label
		set(opcode_index 0)
		if(has_label)
			set(opcode_index 1)
		endif()

		# check for a token
		list(LENGTH tokens token_count)
		if(opcode_index GREATER_EQUAL token_count)
			lc3_assert(orig_found "Instruction before .ORIG")
			# dont increment address
			continue()
		endif()

		# get the first token
		list(GET tokens ${opcode_index} opcode)
		string(TOUPPER "${opcode}" opcode_upper)

		# remember address before this line
		set(prev_addr ${addr})

		# advance address based on instruction or directive
		if(opcode_upper STREQUAL ".ORIG")
			# ensure only one
			lc3_assert(NOT orig_found "Multiple .ORIG directives")
			set(orig_found TRUE)

			# set address to orig value
			math(EXPR index "${opcode_index} + 1")
			list(GET tokens ${index} orig_value)
			lc3_num("${orig_value}" addr)
			lc3_assert(addr GREATER_EQUAL 0 ".ORIG cannot be negative")

			# no need to check since nothing is written yet
			continue()
		elseif(opcode_upper STREQUAL ".END")
			# stop parsing
			break()
		elseif(opcode_upper STREQUAL ".FILL")
			# fill is one word
			lc3_increment(addr)
		elseif(opcode_upper STREQUAL ".BLKW")
			# get blkw value
			math(EXPR index "${opcode_index} + 1")
			list(GET tokens ${index} count_value)
			lc3_num("${count_value}" count_num)
			lc3_assert(count_num GREATER_EQUAL 0 ".BLKW cannot be negative")

			# calculate end address
			math(EXPR new_addr "${addr} + ${count_num}")
			lc3_assert(new_addr LESS_EQUAL ${LC3_WORD_MASK} ".BLKW overflows")
			set(addr ${new_addr})
		elseif(opcode_upper STREQUAL ".STRINGZ")
			# each char + null terminator is one word
			math(EXPR index "${opcode_index} + 1")
			list(GET tokens ${index} string_value)

			# get string size - quotes + null
			string(LENGTH "${string_value}" str_len)
			math(EXPR str_len "${str_len} - 2 + 1")

			# increase address
			math(EXPR addr "${addr} + ${str_len}")
			lc3_assert(addr LESS_EQUAL ${LC3_WORD_MASK} ".STRINGZ overflows")
		else()
			# instruction is 1 word
			lc3_increment(addr)
		endif()

		# orig should be first
		lc3_assert(orig_found "Instruction before .ORIG")

		# check privilege of written words
		if(addr GREATER prev_addr)
			math(EXPR written_addr "${addr} - 1")
			lc3_check_privileged(${written_addr})
			lc3_check_privileged(${prev_addr})
		endif()
	endforeach()

	set(${labels_out} "${labels}")
endmacro()

#[[
	Encode instructions into machine code.
]]
macro(asm_pass2 source_lines_var labels_var)
	# TODO: encoding pass
endmacro()

#[[
	Main entry point for the assembler.
	Reads the file, runs both passes, and populates MEM_<addr> variables.
]]
macro(lc3_asm_assemble filename)
	# read source into clean code lines
	asm_read_source("${filename}" source_lines)

	# collect labels and compute addresses
	asm_pass1(source_lines labels)
endmacro()
