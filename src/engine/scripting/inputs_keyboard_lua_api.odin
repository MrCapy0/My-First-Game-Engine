package scripting

import "../inputs"

@(private = "file")
lua_inputs_keyboard_is_started :: proc "c" (state: Lua) -> Int {

	context = get_context()
	key_str := to_cstring(1)
	key := inputs.to_keyboard_key(string(key_str))
	press := inputs.is_started(key)

	push_bool(press)

	return 1
}

@(private = "file")
lua_inputs_keyboard_is_pressed :: proc "c" (state: Lua) -> Int {

	context = get_context()
	key_str := to_cstring(1)
	key := inputs.to_keyboard_key(string(key_str))
	press := inputs.is_pressed(key)

	push_bool(press)

	return 1
}

@(private)
table_inputs_keyboard := Table {
	name      = "__InputsKeyboard",
	functions = {
		Func{name = "_is_started", function = lua_inputs_keyboard_is_started},
		Func{name = "_is_pressed", function = lua_inputs_keyboard_is_pressed},
	},
}
