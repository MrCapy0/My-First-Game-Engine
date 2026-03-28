package scripting

import "../console"

@(private)
lua_log :: proc "c" (state: Lua) -> Int {

	context = get_context()
	str := to_string(1)
	console.log(str)

	return 0
}

@(private)
table_console := Table {
	name      = "__Console",
	functions = []Func{Func{name = "_log", function = lua_log}},
}
