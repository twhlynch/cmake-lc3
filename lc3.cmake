cmake_minimum_required(VERSION 3.19)

# include everything here once instead of per file
get_filename_component(lc3_dir "${CMAKE_CURRENT_LIST_DIR}" ABSOLUTE)

include(${lc3_dir}/src/lc3_utils.cmake)
include(${lc3_dir}/src/lc3_asm_parse.cmake)
include(${lc3_dir}/src/lc3_asm.cmake)
include(${lc3_dir}/src/lc3_asm_encode.cmake)
include(${lc3_dir}/src/lc3_vm.cmake)
include(${lc3_dir}/src/lc3_vm_exec.cmake)
include(${lc3_dir}/src/lc3_vm_traps.cmake)

# cmake -P lc3.cmake CMAKE_ARGV3
set(input "${CMAKE_ARGV3}")

if(input STREQUAL "")
	lc3_print("Usage: cmake -P lc3.cmake example.asm\n")
	message(FATAL_ERROR "No input file provided")
endif()

# assemble and run
lc3_asm_assemble("${input}")
lc3_vm_run(${ASM_PC})
