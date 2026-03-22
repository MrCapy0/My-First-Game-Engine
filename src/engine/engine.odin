package engine

import "core:fmt"
import "scripting"
import "vendor:raylib"

import l "vendor:lua/5.4"

println :: proc(str: cstring) {
	fmt.println(str)
}

lua_println :: proc "c" (lua: scripting.Lua) -> scripting.Int {
	context = scripting.get_context()

	str := l.tostring(lua, 1)
	println(str)
	return 0
}

run :: proc() {

	scripting.init()
	scripting.add_table(
		scripting.Table {
			name = "engine",
			functions = []scripting.Func {
				scripting.Func{name = "println", function = lua_println},
			},
		},
	)

	scripting.load_scripts()

	start_func_ref: scripting.FieldRef
	update_func_ref: scripting.FieldRef

	start_func_status := scripting.get_field("game", "Start", &start_func_ref)
	update_func_status := scripting.get_field("game", "Update", &update_func_ref)

	raylib.InitWindow(800, 600, "Hello, world")
	raylib.SetTargetFPS(60)

	scripting.run_func(&start_func_ref)

	for {
		if (raylib.WindowShouldClose()) {
			break
		}

		scripting.run_func(&update_func_ref)
		scripting.print_stack_debug()

		raylib.BeginDrawing()
		raylib.ClearBackground(raylib.RAYWHITE)
		raylib.EndDrawing()
	}

	raylib.CloseWindow()
}
