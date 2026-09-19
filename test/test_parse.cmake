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

# tokenize

lc3_tokenize("ADD R0 R1 R2" tokens)
test_assert_equal("${tokens}" "ADD;R0;R1;R2" "tokenize spaces")

lc3_tokenize("ADD R0,R1,R2" tokens)
test_assert_equal("${tokens}" "ADD;R0;R1;R2" "tokenize commas")

lc3_tokenize("LD   R0,label" tokens)
test_assert_equal("${tokens}" "LD;R0;label" "tokenize mixed whitespace")

lc3_tokenize("Label: HALT" tokens)
test_assert_equal("${tokens}" "Label;HALT" "Label colon")

lc3_tokenize(".STRINGZ \"hello world\"" tokens)
test_assert_equal("${tokens}" ".STRINGZ;\"hello world\"" "tokenize quoted string")

lc3_tokenize(".STRINGZ \"a,b\"" tokens)
test_assert_equal("${tokens}" ".STRINGZ;\"a,b\"" "tokenize comma in string")

lc3_tokenize("NOT R1 R1," tokens)
test_assert_equal("${tokens}" "NOT;R1;R1" "no empty token")

# lc3_num

# #N #-N #+N

lc3_num("#10" num)
test_assert_equal("${num}" "10" "#N")

lc3_num("#-10" num)
test_assert_equal("${num}" "-10" "#-N")

lc3_num("#+10" num)
test_assert_equal("${num}" "10" "#+N")

# N -N +N

lc3_num("10" num)
test_assert_equal("${num}" "10" "N")

lc3_num("-10" num)
test_assert_equal("${num}" "-10" "-N")

lc3_num("+10" num)
test_assert_equal("${num}" "10" "+N")

# xN -xN +xN

lc3_num("xA" num)
test_assert_equal("${num}" "10" "xN")

lc3_num("-xA" num)
test_assert_equal("${num}" "-10" "-xN")

lc3_num("+xA" num)
test_assert_equal("${num}" "10" "+xN")

# 0xN -0xN +0xN

lc3_num("0xA" num)
test_assert_equal("${num}" "10" "0xN")

lc3_num("-0xA" num)
test_assert_equal("${num}" "-10" "-0xN")

lc3_num("+0xA" num)
test_assert_equal("${num}" "10" "+0xN")
