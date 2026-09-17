#[[
	Collect labels and compute their addresses.
	source_lines_must contain the source lines.
]]
macro(asm_pass1 source_lines_var labels_out addr_out)
	# TODO: first pass
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
	# TODO: assemble
endmacro()
