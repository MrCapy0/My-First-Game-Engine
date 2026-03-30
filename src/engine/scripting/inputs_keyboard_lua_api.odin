package scripting

import "../inputs"

@(private)
lua_inputs_keyboard_was_pressed :: proc "c" (state: Lua) -> Int {

	context = get_context()
	key_str := to_cstring(1)
	key := inputs.to_keyboard_key(string(key_str))
	press := inputs.is_key_down(key)

	push_bool(press)

	return 1
}

@(private)
table_inputs_keyboard := Table {
	name      = "__InputsKeyboard",
	functions = {Func{name = "_was_pressed", function = lua_inputs_keyboard_was_pressed}},
}
