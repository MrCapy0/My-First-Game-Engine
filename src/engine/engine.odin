package engine

import "core:fmt"
import "vendor:raylib"

import "app"
import "console"
import "scripting"

run :: proc() {

	scripting.init()

	init_settings_field_ref: scripting.FieldRef
	start_func_ref: scripting.FieldRef
	update_func_ref: scripting.FieldRef

	init_settings_status := scripting.get_field("Game", "init_settings", &init_settings_field_ref)

	#partial switch init_settings_status {
	case .FIELD_DOES_NOT_EXIST:
		console.warning("'Game.init_settings' does not found on main.lua")
		break
	}

	if init_settings_field_ref.type != .TABLE {
		console.warning("'Game.init_settings' on main.lua is not a table.")
	}

	scripting.get_data(&init_settings_field_ref)
	init_settings := scripting.to_init_settings(1)
	scripting.pop_data(1)

	start_func_status := scripting.get_field("Game", "Start", &start_func_ref)
	update_func_status := scripting.get_field("Game", "Update", &update_func_ref)

	#partial switch start_func_status {
	case .INVALID_TABLE:
		console.warning("'Game' table is invalid on main.lua")
		break
	case .TABLE_DOES_NOT_EXIST:
		console.warning("'Game' table is does not exist on main.lua")
		break
	}

	window_flags: raylib.ConfigFlags = {.WINDOW_HIGHDPI}

	if init_settings.window_allow_resize {
		window_flags += {.WINDOW_RESIZABLE}
	}

	if init_settings.window_use_full_screen {
		window_flags += {.FULLSCREEN_MODE}
	}

	if init_settings.window_use_msaa_4x {
		window_flags += {.MSAA_4X_HINT}
	}

	if init_settings.window_use_vsync {
		window_flags += {.VSYNC_HINT}
	}

	raylib.SetConfigFlags(window_flags)
	raylib.InitWindow(
		init_settings.window_width,
		init_settings.window_height,
		init_settings.window_title,
	)

	raylib.SetTargetFPS(60)

	scripting.run_func(&start_func_ref)

	for {
		if raylib.WindowShouldClose() {
			break
		}

		delta := app.get_delta()
		scripting.run_func(&update_func_ref, "Game", delta)

		raylib.BeginDrawing()
		raylib.BeginMode3D(app.get_camera_3d())
		raylib.ClearBackground(raylib.RAYWHITE)

		raylib.DrawGrid(50, 1)

		raylib.EndMode3D()
		raylib.EndDrawing()
	}

	raylib.CloseWindow()
}
