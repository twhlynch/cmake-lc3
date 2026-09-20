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

# lc3_reg

lc3_reg("R0" reg)
test_assert_equal("${reg}" "0" "R0")

lc3_reg("r7" reg)
test_assert_equal("${reg}" "7" "r7")

# asm_is_instruction

asm_is_instruction("ADD" is_instr)
test_assert_equal("${is_instr}" "TRUE" "instruction")

asm_is_instruction("brnzp" is_instr)
test_assert_equal("${is_instr}" "TRUE" "lowercase instruction")

asm_is_instruction("HALT" is_instr)
test_assert_equal("${is_instr}" "TRUE" "pseudoop")

asm_is_instruction("LOOP" is_instr)
test_assert_equal("${is_instr}" "FALSE" "label")

asm_is_instruction(".ORIG" is_instr)
test_assert_equal("${is_instr}" "FALSE" "directive")

# asm_is_directive

asm_is_directive(".ORIG" is_dir)
test_assert_equal("${is_dir}" "TRUE" "directive")

asm_is_directive(".STRINGZ" is_dir)
test_assert_equal("${is_dir}" "TRUE" "lowercase directive")

asm_is_directive(".EXTERN" is_dir)
test_assert_equal("${is_dir}" "FALSE" "not directive")

# asm_is_number

asm_is_number("#10" is_num)
test_assert_equal("${is_num}" "TRUE" "is number hash")

asm_is_number("xFF" is_num)
test_assert_equal("${is_num}" "TRUE" "is number hex")

asm_is_number("42" is_num)
test_assert_equal("${is_num}" "TRUE" "is number decimal")

asm_is_number("R0" is_num)
test_assert_equal("${is_num}" "FALSE" "is number register")

asm_is_number("ADD" is_num)
test_assert_equal("${is_num}" "FALSE" "is number instruction")

# asm_is_register

asm_is_register("R0" is_reg)
test_assert_equal("${is_reg}" "TRUE" "is register R0")

asm_is_register("r7" is_reg)
test_assert_equal("${is_reg}" "TRUE" "is register lowercase")

asm_is_register("R8" is_reg)
test_assert_equal("${is_reg}" "FALSE" "is register R8")

asm_is_register("ADD" is_reg)
test_assert_equal("${is_reg}" "FALSE" "is register instruction")

# asm_is_label

asm_is_label("LOOP" is_label)
test_assert_equal("${is_label}" "TRUE" "is label")

asm_is_label("ABCDEFGHIJKLMNOPQRST" is_label)
test_assert_equal("${is_label}" "TRUE" "is label 20 chars")

asm_is_label("ABCDEFGHIJKLMNOPQRSTU" is_label)
test_assert_equal("${is_label}" "FALSE" "is label 21 chars")

asm_is_label("123" is_label)
test_assert_equal("${is_label}" "FALSE" "is label number")

asm_is_label("x10" is_label)
test_assert_equal("${is_label}" "FALSE" "is label hex")

asm_is_label("R0" is_label)
test_assert_equal("${is_label}" "FALSE" "is label register")

asm_is_label("ADD" is_label)
test_assert_equal("${is_label}" "FALSE" "is label instruction")

asm_is_label(".ORIG" is_label)
test_assert_equal("${is_label}" "FALSE" "is label directive")

# asm_check_directive

lc3_tokenize(".FILL" token)
asm_check_directive("${token}" is_directive)

# asm_detect_label

lc3_tokenize("Loop not r0 r1" tokens)
asm_detect_label(tokens has_label label_name)
test_assert_equal("${has_label}" "TRUE" "detect label")
test_assert_equal("${label_name}" "Loop" "detect label name")

lc3_tokenize("not r0 r1" tokens)
asm_detect_label(tokens has_label label_name)
test_assert_equal("${has_label}" "FALSE" "detect no label")

lc3_tokenize(".ORIG x3000" tokens)
asm_detect_label(tokens has_label label_name)
test_assert_equal("${has_label}" "FALSE" "detect no label directive")

lc3_tokenize("Loop" tokens)
asm_detect_label(tokens has_label label_name)
test_assert_equal("${has_label}" "TRUE" "detect just label")

lc3_tokenize("Loop: not r0 r1" tokens)
asm_detect_label(tokens has_label label_name)
test_assert_equal("${label_name}" "Loop" "detect colon label")

lc3_tokenize("123 not r0 r1" tokens)
asm_detect_label(tokens has_label label_name)
test_assert_equal("${has_label}" "FALSE" "detect not label number")

lc3_tokenize("r0" tokens)
asm_detect_label(tokens has_label label_name)
test_assert_equal("${has_label}" "FALSE" "detect not label register")

lc3_tokenize("add" tokens)
asm_detect_label(tokens has_label label_name)
test_assert_equal("${has_label}" "FALSE" "detect not label instruction")

# asm_find_label

asm_find_label("LOOP" "LOOP:4096;END:4100" found address)
test_assert_equal("${found}" "TRUE" "find label")
test_assert_equal("${address}" "4096" "find label address")

asm_find_label("loop" "LOOP:4096;END:4100" found address)
test_assert_equal("${found}" "FALSE" "find label case sensitive")

asm_find_label("MISSING" "LOOP:4096;END:4100" found address)
test_assert_equal("${found}" "FALSE" "find label missing")

# asm_register_label

set(labels "")
asm_register_label(labels "A" 1)
test_assert_equal("${labels}" "A:1" "register label")

asm_register_label(labels "B" 2)
test_assert_equal("${labels}" "A:1;B:2" "register second label")
