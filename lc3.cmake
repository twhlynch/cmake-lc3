cmake_minimum_required(VERSION 3.19)

# include all src files
get_filename_component(lc3_dir "${CMAKE_CURRENT_LIST_DIR}" ABSOLUTE)
file(GLOB lc3_cmake_files CONFIGURE_DEPENDS "${lc3_dir}/src/*.cmake")
include(${lc3_cmake_files})

# cmake -P lc3.cmake CMAKE_ARGV3
set(input "${CMAKE_ARGV3}")

if(input STREQUAL "")
	message(STATUS "Usage: cmake -P lc3.cmake example.asm")
	message(FATAL_ERROR "No input file provided")
endif()

# assemble and run
lc3_asm_assemble("${input}")
lc3_vm_run(${ASM_PC})
