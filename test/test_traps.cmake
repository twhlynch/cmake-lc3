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
