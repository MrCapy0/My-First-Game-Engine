package app

import "core:fmt"
import "core:math"
import "vendor:raylib"

InitSettings :: struct {
	window_title:           cstring,
	window_width:           i32,
	window_height:          i32,
	window_allow_resize:    bool,
	window_use_vsync:       bool,
	window_use_full_screen: bool,
	window_use_msaa_4x:     bool,
}

ScreenSettings :: struct {
	title:           cstring,
	allow_resize:    bool,
	use_vsync:       bool,
	use_full_screen: bool,
	use_msaa_4x:     bool,
}

@(private)
window_width: i32

@(private)
window_height: i32

@(private)
default_window_width: i32

@(private)
default_window_height: i32

@(private)
default_window_pos: raylib.Vector2

@(private)
screen_width: i32

@(private)
screen_height: i32

@(private)
window_settings: ScreenSettings

@(private)
camera_3d: raylib.Camera3D = raylib.Camera3D {
	fovy       = 60,
	position   = {0, 2, -5},
	projection = raylib.CameraProjection.PERSPECTIVE,
	target     = {0, 0, 0},
	up         = {0, 1, 0},
}

init :: proc(settings: InitSettings) {

	window_width = math.max(settings.window_width, 0)
	window_height = math.max(settings.window_height, 0)
	window_flags: raylib.ConfigFlags = {.WINDOW_HIGHDPI}

	default_window_width = window_width
	default_window_height = window_height

	if settings.window_use_full_screen {

		// Set initial resolution to 0 to raylib start with maximized size.
		window_width = 0
		window_height = 0
	}

	if settings.window_allow_resize {
		window_flags += {.WINDOW_RESIZABLE}
	}

	if settings.window_use_msaa_4x {
		window_flags += {.MSAA_4X_HINT}
	}

	if settings.window_use_vsync {
		window_flags += {.VSYNC_HINT}
	}

	window_settings.title = settings.window_title
	window_settings.allow_resize = settings.window_allow_resize
	window_settings.use_full_screen = settings.window_use_full_screen
	window_settings.use_msaa_4x = settings.window_use_msaa_4x
	window_settings.use_vsync = settings.window_use_vsync

	raylib.SetConfigFlags(window_flags)
	raylib.InitWindow(window_width, window_height, settings.window_title)
	raylib.SetTargetFPS(60)

	screen_width = i32(raylib.GetMonitorWidth(0))
	screen_height = i32(raylib.GetMonitorHeight(0))
	default_window_pos = raylib.GetWindowPosition()

	// Default window size can't be 0 to avoid crash on exit full screen.
	if default_window_width == 0 || default_window_height == 0 {
		default_window_width = screen_width
		default_window_height = screen_height
	}

	if settings.window_use_full_screen {
		window_width = screen_width
		window_height = screen_height
		set_full_screen(true)

		default_window_pos = {
			f32((screen_width / 2) - (default_window_width / 2)),
			f32((screen_height / 2) - (default_window_height / 2)),
		}
	}
}

update :: proc() {

	if raylib.IsWindowResized() {
		window_width = i32(raylib.GetScreenWidth())
		window_height = i32(raylib.GetScreenHeight())

		if !window_settings.use_full_screen {
			default_window_width = window_width
			default_window_height = window_height
		}
	}
}

set_camera_3d :: #force_inline proc(position: raylib.Vector3, direction: raylib.Vector3) {
	camera_3d.position = position
	camera_3d.target = position + direction
}

get_camera_3d :: #force_inline proc() -> raylib.Camera3D {

	// TODO: Expose it on lua side.

	return camera_3d
}

get_delta :: #force_inline proc() -> f32 {
	return raylib.GetFrameTime()
}

set_full_screen :: proc(use_full_screen: bool) {

	if raylib.IsWindowFullscreen() == use_full_screen {
		return
	}

	window_settings.use_full_screen = use_full_screen

	if use_full_screen {

		default_window_pos = raylib.GetWindowPosition()

		window_width = screen_width
		window_height = screen_height
		raylib.SetWindowSize(i32(screen_width), i32(screen_height))
		raylib.ToggleFullscreen()
		
	} else {

		raylib.ToggleFullscreen()
		raylib.SetWindowSize(i32(default_window_width), i32(default_window_height))
		raylib.SetWindowPosition(i32(default_window_pos.x), i32(default_window_pos.y))
	}
}

get_is_full_screen :: #force_inline proc() -> bool {
	return window_settings.use_full_screen
}

get_window_width :: #force_inline proc() -> i32 {
	return window_width
}

get_window_height :: #force_inline proc() -> i32 {
	return window_height
}

get_screen_width :: #force_inline proc() -> i32 {
	return screen_width
}

get_screen_height :: #force_inline proc() -> i32 {
	return screen_height
}

@(private)
apply_window_settings :: proc(settings: ScreenSettings) {

	window_flags: raylib.ConfigFlags = {.WINDOW_HIGHDPI}

	if settings.allow_resize {
		window_flags += {.WINDOW_RESIZABLE}
	}

	if settings.use_msaa_4x {
		window_flags += {.MSAA_4X_HINT}
	}

	if settings.use_vsync {
		window_flags += {.VSYNC_HINT}
	}

	raylib.SetWindowState(window_flags)
}
