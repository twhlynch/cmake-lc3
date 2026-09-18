# cmake -P test/test_traps.cmake

cmake_minimum_required(VERSION 3.19)

get_filename_component(REPO_ROOT "${CMAKE_CURRENT_LIST_DIR}/.." ABSOLUTE)
include(${REPO_ROOT}/src/lc3_utils.cmake)
include(${REPO_ROOT}/src/lc3_vm.cmake)
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

test_reset()
vm_trap_halt()
test_assert_equal("${VM_HALT}" "1" "halt")

test_reset()
set(MOCK_INPUT_CHAR "A")
vm_trap_getc()
test_assert_equal("${R0}" "65" "getc")

test_reset()
set(MOCK_INPUT_CHAR "")
vm_trap_getc()
test_assert_equal("${R0}" "0" "getc empty input")

test_reset()
set(R0 65) # A
vm_trap_out()
test_assert_equal("${CAPTURED_OUTPUT}" "65" "out")

test_reset()
set(R0 258) # x0102
vm_trap_out()
test_assert_equal("${CAPTURED_OUTPUT}" "2" "out low byte")

test_reset()
set(R0 12288) # x3000
set(MEM_12288 72) # H
set(MEM_12289 105) # i
set(MEM_12290 0) # \0
vm_trap_puts()
test_assert_equal("${CAPTURED_OUTPUT}" "72;105" "puts")

test_reset()
set(MOCK_INPUT_CHAR "Z")
vm_trap_in()
test_assert_equal("${R0}" "90" "in")
test_assert_equal("${CAPTURED_OUTPUT}" "90" "in echoes")

test_reset()
set(MOCK_INPUT_CHAR "")
vm_trap_in()
test_assert_equal("${R0}" "0" "in empty input")

test_reset()
set(R0 12288) # x3000
math(EXPR MEM_12288 "0x4241") # A (0x41) B (0x42)
set(MEM_12289 0) # \0
vm_trap_putsp()
test_assert_equal("${CAPTURED_OUTPUT}" "65;66" "putsp")

# putn and reg dont test anything just show output

test_reset()
set(R0 65535)
vm_trap_putn()

test_reset()
set(R0 72)
set(R1 10)
set(R2 32)
vm_trap_reg()
