#[[
	Throws a FATAL_ERROR if the condition is not met.
]]
macro(lc3_assert)
	set(assert_args ${ARGV})
	list(GET assert_args -1 assert_msg)
	list(REMOVE_AT assert_args -1)
	if(NOT (${assert_args}))
		message(FATAL_ERROR "${assert_msg}")
	endif()
endmacro()
