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
set(R1 6)
set(R2 5)
vm_exec_and(20546) # and r0 r1 r2
test_assert_equal("${R0}" "4" "and")

test_reset()
set(R1 6)
vm_exec_and(20579) # and r0 r1 #3
test_assert_equal("${R0}" "2" "and imm")

test_reset()
vm_exec_br(1026) # brz #2
test_assert_equal("${PC}" "12290" "br")

test_reset()
vm_exec_br(513) # brp #1
test_assert_equal("${PC}" "12288" "br skip")

test_reset()
vm_exec_trap(61477) # trap x25 (halt)
test_assert_equal("${VM_HALT}" "1" "trap")
