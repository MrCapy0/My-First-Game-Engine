package scripting

import "../app"
import "vendor:raylib"

@(private = "file")
lua_set_camera_3d :: proc "c" (lua: Lua) -> Int {
	context = get_context()
	pos := to_vec3(1)
	dir := to_vec3(2)
	app.set_camera_3d(pos, dir)
	return 0
}

@(private = "file")
lua_get_delta :: proc "c" (lua: Lua) -> Int {
	context = get_context()
	dt := app.get_delta()
	push_number(dt)
	return 1
}

@(private = "file")
lua_get_is_full_screen :: proc "c" (lua: Lua) -> Int {
	context = get_context()
	full_screen := app.get_is_full_screen()
	push_bool(full_screen)
	return 1
}

@(private = "file")
lua_set_full_screen :: proc "c" (lua: Lua) -> Int {
	context = get_context()
	full_screen := to_bool(1)
	app.set_full_screen(full_screen)
	return 0
}

@(private)
table_app := Table {
	name      = "__App",
	functions = []Func {
		Func{name = "_set_camera_3d", function = lua_set_camera_3d},
		Func{name = "_get_delta", function = lua_get_delta},
		Func{name = "_get_is_full_screen", function = lua_get_is_full_screen},
		Func{name = "_set_full_screen", function = lua_set_full_screen},
	},
}
