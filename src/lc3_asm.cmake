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
			asm_require_operands("${tokens}" "${opcode_index}" 1)
			asm_operand("${tokens}" "${opcode_index}" 1 orig_value)
			lc3_num("${orig_value}" addr)
			lc3_assert(addr GREATER_EQUAL 0 ".ORIG cannot be negative")

			# no need to check since nothing is written yet
			continue()
		elseif(opcode_upper STREQUAL ".END")
			# stop parsing
			asm_require_operands("${tokens}" "${opcode_index}" 0)
			break()
		elseif(opcode_upper STREQUAL ".FILL")
			# fill is one word
			asm_require_operands("${tokens}" "${opcode_index}" 1)
			lc3_increment(addr)
		elseif(opcode_upper STREQUAL ".BLKW")
			# get blkw value
			asm_require_operands("${tokens}" "${opcode_index}" 1)
			asm_operand("${tokens}" "${opcode_index}" 1 count_value)
			lc3_num("${count_value}" count_num)
			lc3_assert(count_num GREATER_EQUAL 0 ".BLKW cannot be negative")

			# calculate end address
			math(EXPR new_addr "${addr} + ${count_num}")
			lc3_assert(new_addr LESS_EQUAL ${LC3_WORD_MASK} ".BLKW overflows")
			set(addr ${new_addr})
		elseif(opcode_upper STREQUAL ".STRINGZ")
			# each char + null terminator is one word
			asm_require_operands("${tokens}" "${opcode_index}" 1)
			asm_operand("${tokens}" "${opcode_index}" 1 string_value)

			set(string_value_check "${string_value}") # copy to local (see assert note)
			# strings must be quoted
			lc3_assert(string_value_check MATCHES "^\".*\"$" ".STRINGZ requires a quoted string")

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
	set(addr 0)
	set(origin 0)
	set(labels "${${labels_var}}")

	foreach(raw_line IN LISTS ${source_lines_var})
		# tokenize line and detect label
		lc3_tokenize("${raw_line}" tokens)
		asm_detect_label(tokens has_label label_name)

		# find opcode after any label
		set(opcode_index 0)
		if(has_label)
			set(opcode_index 1)
		endif()

		# check for a token
		list(LENGTH tokens token_count)
		if(opcode_index GREATER_EQUAL token_count)
			continue()
		endif()

		# get the first token
		list(GET tokens ${opcode_index} opcode)
		string(TOUPPER "${opcode}" opcode_upper)

		# assembler directives
		if(opcode_upper STREQUAL ".ORIG")
			# set address to orig value
			asm_require_operands("${tokens}" "${opcode_index}" 1)
			asm_operand("${tokens}" "${opcode_index}" 1 orig_value)
			lc3_num("${orig_value}" addr)
			set(origin ${addr})

			# orig must be in user space
			lc3_check_privileged(${addr})
		elseif(opcode_upper STREQUAL ".END")
			# stop parsing
			asm_require_operands("${tokens}" "${opcode_index}" 0)
			break()
		elseif(opcode_upper STREQUAL ".FILL")
			# get fill value
			asm_require_operands("${tokens}" "${opcode_index}" 1)
			asm_operand("${tokens}" "${opcode_index}" 1 fill_value)

			# resolve label or number
			asm_find_label("${fill_value}" "${labels}" label_found label_addr)
			if(label_found)
				# label address
				set(word ${label_addr})
			else()
				# value
				lc3_num("${fill_value}" word)
			endif()

			# store word
			lc3_mask(${word} ${LC3_WORD_MASK} word)
			asm_write_word(addr ${word})
		elseif(opcode_upper STREQUAL ".BLKW")
			# get blkw value
			asm_require_operands("${tokens}" "${opcode_index}" 1)
			asm_operand("${tokens}" "${opcode_index}" 1 count_value)
			lc3_num("${count_value}" count_num)

			# write count zero words
			set(blkw_remaining ${count_num})
			while(blkw_remaining GREATER 0)
				asm_write_word(addr 0)
				lc3_decrement(blkw_remaining)
			endwhile()
		elseif(opcode_upper STREQUAL ".STRINGZ")
			# each char + null terminator is one word
			asm_require_operands("${tokens}" "${opcode_index}" 1)
			asm_operand("${tokens}" "${opcode_index}" 1 string_value)

			# get string without quotes
			string(LENGTH "${string_value}" str_len)
			math(EXPR inner_len "${str_len} - 2")
			string(SUBSTRING "${string_value}" 1 ${inner_len} str_chars)
			string(LENGTH "${str_chars}" char_count)

			# write each char
			set(char_index 0)
			while(char_index LESS char_count)
				string(SUBSTRING "${str_chars}" ${char_index} 1 current_char)
				lc3_ord("${current_char}" char_ordinal)
				asm_write_word(addr ${char_ordinal})
				lc3_increment(char_index)
			endwhile()

			# write null terminator
			asm_write_word(addr 0)
		else()
			# invalid directives fail
			asm_check_directive("${opcode}")

			# pseudo-instructions
			asm_encode_pseudo("${opcode_upper}" pseudo_done addr)
			if(pseudo_done)
				# pseudos take no operands
				asm_require_operands("${tokens}" "${opcode_index}" 0)
			elseif(opcode_upper STREQUAL "ADD")
				asm_encode_add("${tokens}" "${opcode_index}" addr "${labels}")
			elseif(opcode_upper STREQUAL "AND")
				asm_encode_and("${tokens}" "${opcode_index}" addr "${labels}")
			elseif(opcode_upper STREQUAL "NOT")
				asm_encode_not("${tokens}" "${opcode_index}" addr "${labels}")
			elseif(opcode_upper IN_LIST ASM_BR_NAMES)
				asm_encode_branch("${tokens}" "${opcode_index}" addr "${labels}")
			elseif(opcode_upper STREQUAL "JMP")
				asm_encode_jmp("${tokens}" "${opcode_index}" addr "${labels}")
			elseif(opcode_upper STREQUAL "JSR")
				asm_encode_jsr("${tokens}" "${opcode_index}" addr "${labels}")
			elseif(opcode_upper STREQUAL "JSRR")
				asm_encode_jsrr("${tokens}" "${opcode_index}" addr "${labels}")
			elseif(opcode_upper STREQUAL "LD")
				asm_encode_ld("${tokens}" "${opcode_index}" addr "${labels}")
			elseif(opcode_upper STREQUAL "LDI")
				asm_encode_ldi("${tokens}" "${opcode_index}" addr "${labels}")
			elseif(opcode_upper STREQUAL "LDR")
				asm_encode_ldr("${tokens}" "${opcode_index}" addr "${labels}")
			elseif(opcode_upper STREQUAL "LEA")
				asm_encode_lea("${tokens}" "${opcode_index}" addr "${labels}")
			elseif(opcode_upper STREQUAL "ST")
				asm_encode_st("${tokens}" "${opcode_index}" addr "${labels}")
			elseif(opcode_upper STREQUAL "STI")
				asm_encode_sti("${tokens}" "${opcode_index}" addr "${labels}")
			elseif(opcode_upper STREQUAL "STR")
				asm_encode_str("${tokens}" "${opcode_index}" addr "${labels}")
			elseif(opcode_upper STREQUAL "TRAP")
				asm_encode_trap("${tokens}" "${opcode_index}" addr "${labels}")
			elseif(opcode_upper STREQUAL "RTI")
				asm_encode_rti("${tokens}" "${opcode_index}" addr "${labels}")
			else()
				message(FATAL_ERROR "Unknown instruction: ${opcode_upper}")
			endif()
		endif()
	endforeach()

	set(ASM_PC ${origin})
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

	# encode instructions into machine code
	asm_pass2(source_lines labels)
endmacro()
