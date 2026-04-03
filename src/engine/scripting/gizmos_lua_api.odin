package scripting

import "../gizmos"
import "vendor:raylib"

@(private = "file")
lua_gizmos_draw_wire_cube :: proc "c" (state: Lua) -> Int {

	// TODO: check args.

	context = get_context()
	pos := to_vec3(1)
	scale := to_vec3(2)
	color := to_color(3)

	gizmos.draw_wire_cube(pos, scale, color)

	return 0
}

table_gizmos := Table {
	name      = "__Gizmos",
	functions = []Func{Func{name = "_draw_cube", function = lua_gizmos_draw_wire_cube}},
}
