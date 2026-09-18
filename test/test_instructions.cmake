test_reset()
set(R1 1)
set(R2 1)
vm_exec_add(4162) # add r0 r1 r2
test_assert_equal("${R0}" "2" "add")
