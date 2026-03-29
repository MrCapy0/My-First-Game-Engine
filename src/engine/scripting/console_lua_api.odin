package scripting

import "../console"

@(private)
lua_log :: proc "c" (state: Lua) -> Int {

	context = get_context()

	check_stack()

	str := to_cstring(1)
	console.log(string(str))
	pop_data(1)

	assert_stack()

	return 0
}

@(private)
table_console := Table {
	name      = "__Console",
	functions = []Func{Func{name = "_log", function = lua_log}},
}
