# cmake -P test/test.cmake

cmake_minimum_required(VERSION 3.19)

get_filename_component(REPO_ROOT "${CMAKE_CURRENT_LIST_DIR}/.." ABSOLUTE)

include(${REPO_ROOT}/src/lc3_utils.cmake)
include(${REPO_ROOT}/src/lc3_asm_parse.cmake)
include(${REPO_ROOT}/src/lc3_asm.cmake)
include(${REPO_ROOT}/src/lc3_asm_encode.cmake)
include(${REPO_ROOT}/src/lc3_vm.cmake)
include(${REPO_ROOT}/src/lc3_vm_exec.cmake)
include(${REPO_ROOT}/src/lc3_vm_traps.cmake)

#[[
	Assert helper specifically for tests.
]]
macro(test_assert_equal actual expected message)
	if(NOT "${actual}" STREQUAL "${expected}")
		message(
			FATAL_ERROR
			"FAIL: ${message} (expected '${expected}', got '${actual}')"
		)
	else()
		message(STATUS "PASS: ${message}")
	endif()
endmacro()

# MARK: mock io

set(MOCK_INPUT_CHAR "")
macro(lc3_input result)
	set(${result} "${MOCK_INPUT_CHAR}")
endmacro()

set(CAPTURED_OUTPUT "")
macro(lc3_print_ord code)
	list(APPEND CAPTURED_OUTPUT "${code}")
endmacro()

macro(test_reset)
	lc3_vm_reset()
	set(CAPTURED_OUTPUT "")
endmacro()

# MARK: tests

get_filename_component(TEST_ROOT "${CMAKE_CURRENT_LIST_DIR}" ABSOLUTE)

include(${TEST_ROOT}/test_traps.cmake)
include(${TEST_ROOT}/test_instructions.cmake)
