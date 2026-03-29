package scripting

import "../app"
import "vendor:raylib"

@(private)
lua_set_camera_3d :: proc "c" (lua: Lua) -> Int {
	context = get_context()
	pos := to_vec3(1)
	dir := to_vec3(2)
	app.set_camera_3d(pos, dir)
	return 0
}

@(private)
lua_get_delta :: proc "c" (lua: Lua) -> Int {
	context = get_context()
	dt := app.get_delta()
	push_number(dt)
	return 1
}

@(private)
table_app := Table {
	name      = "__App",
	functions = []Func {
		Func{name = "_set_camera_3d", function = lua_set_camera_3d},
		Func{name = "_get_delta", function = lua_get_delta},
	},
}
