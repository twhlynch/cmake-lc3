test_reset()
set(R1 1)
set(R2 1)
vm_exec_add(4162) # add r0 r1 r2
test_assert_equal("${R0}" "2" "add")

test_reset()
set(R1 1)
vm_exec_add(4193) # add r0 r1 #1
test_assert_equal("${R0}" "2" "add imm")

test_reset()
vm_exec_trap(61477) # trap x25 (halt)
test_assert_equal("${VM_HALT}" "1" "trap")
