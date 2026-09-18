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
set(R2 12300)
vm_exec_jmp(49280) # jmp r2
test_assert_equal("${PC}" "12300" "jmp")

test_reset()
vm_exec_jsr(18437) # jsr #5
test_assert_equal("${R7}" "12288" "jsr r7")
test_assert_equal("${PC}" "12293" "jsr")

test_reset()
set(R2 12300)
vm_exec_jsr(16512) # jsrr r2
test_assert_equal("${R7}" "12288" "jsrr r7")
test_assert_equal("${PC}" "12300" "jsrr")

test_reset()
set(MEM_12289 42)
vm_exec_ld(8193) # ld r0 #1
test_assert_equal("${R0}" "42" "ld")

test_reset()
vm_exec_trap(61477) # trap x25 (halt)
test_assert_equal("${VM_HALT}" "1" "trap")
