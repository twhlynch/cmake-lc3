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
set(MEM_12289 12290)
set(MEM_12290 43)
vm_exec_ldi(40961) # ldi r0 #1
test_assert_equal("${R0}" "43" "ldi")

test_reset()
set(R1 12288)
set(MEM_12290 44)
vm_exec_ldr(24642) # ldr r0 r1 #2
test_assert_equal("${R0}" "44" "ldr")

test_reset()
set(R1 12292)
set(MEM_12290 44)
vm_exec_ldr(24702) # ldr r0 r1 #-2
test_assert_equal("${R0}" "44" "ldr negative")

test_reset()
vm_exec_lea(57345) # lea r0 #1
test_assert_equal("${R0}" "12289" "lea")

test_reset()
set(R1 0)
vm_exec_not(36991) # not r0 r1
test_assert_equal("${R0}" "65535" "not")


test_reset()
vm_exec_trap(61477) # trap x25 (halt)
test_assert_equal("${VM_HALT}" "1" "trap")
