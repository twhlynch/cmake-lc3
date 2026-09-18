# asm_strip_comments

set(content "ADD R0 R1 R2 ; comment")
asm_strip_comments(content)
test_assert_equal("${content}" "ADD R0 R1 R2 " "strip comments")

# asm_split_lines

set(content "a\nb\nc")
asm_split_lines(content lines)
test_assert_equal("${lines}" "a;b;c" "split lines")

set(content "a\r\nb")
asm_split_lines(content lines)
test_assert_equal("${lines}" "a;b" "split CRLF lines")

# asm_strip_line

asm_strip_line("  ADD R0 R1 R2  " stripped)
test_assert_equal("${stripped}" "ADD R0 R1 R2" "strip surrounding whitespace")

asm_strip_line("\tLD R0,label" stripped)
test_assert_equal("${stripped}" "LD R0,label" "strip tab")

asm_strip_line("   " stripped)
test_assert_equal("${stripped}" "" "strip whitespace only")

# asm_is_blank_line

asm_is_blank_line("" blank)
test_assert_equal("${blank}" "1" "blank empty")

asm_is_blank_line("ADD R0 R1 R2" blank)
test_assert_equal("${blank}" "0" "blank code")
