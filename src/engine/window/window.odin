package window

import runtime "base:runtime"
import fmt "core:fmt"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"

@(private)
GL_MAJOR_VERSION :: 4

@(private)
GL_MINOR_VERSION :: 1

@(private)
triggered_keyboard_keys: map[KEYS]bool

@(private)
down_keyboard_keys: map[KEYS]bool

@(private)
mouse_pos: [2]f32

@(private)
mouse_delta: [2]f32

KEYS :: enum {
	Unknown       = -1,
	Space         = 32,
	Apostrophe    = 39,
	Comma         = 44,
	Minus         = 45,
	Period        = 46,
	Slash         = 47,
	Semicolon     = 59,
	Equal         = 61,
	Left_Bracket  = 91,
	Backslash     = 92,
	Right_Bracket = 93,
	Grave_Accent  = 96,
	World_1       = 161,
	World_2       = 162,
	Num_0         = 48,
	Num_1         = 49,
	Num_2         = 50,
	Num_3         = 51,
	Num_4         = 52,
	Num_5         = 53,
	Num_6         = 54,
	Num_7         = 55,
	Num_8         = 56,
	Num_9         = 57,
	A             = 65,
	B             = 66,
	C             = 67,
	D             = 68,
	E             = 69,
	F             = 70,
	G             = 71,
	H             = 72,
	I             = 73,
	J             = 74,
	K             = 75,
	L             = 76,
	M             = 77,
	N             = 78,
	O             = 79,
	P             = 80,
	Q             = 81,
	R             = 82,
	S             = 83,
	T             = 84,
	U             = 85,
	V             = 86,
	W             = 87,
	X             = 88,
	Y             = 89,
	Z             = 90,
	Escape        = 256,
	Enter         = 257,
	Tab           = 258,
	Backspace     = 259,
	Insert        = 260,
	Delete        = 261,
	Right         = 262,
	Left          = 263,
	Down          = 264,
	Up            = 265,
	Page_Up       = 266,
	Page_Down     = 267,
	Home          = 268,
	End           = 269,
	Caps_Lock     = 280,
	Scroll_Lock   = 281,
	Num_Lock      = 282,
	Print_Screen  = 283,
	Pause         = 284,
	F1            = 290,
	F2            = 291,
	F3            = 292,
	F4            = 293,
	F5            = 294,
	F6            = 295,
	F7            = 296,
	F8            = 297,
	F9            = 298,
	F10           = 299,
	F11           = 300,
	F12           = 301,
	F13           = 302,
	F14           = 303,
	F15           = 304,
	F16           = 305,
	F17           = 306,
	F18           = 307,
	F19           = 308,
	F20           = 309,
	F21           = 310,
	F22           = 311,
	F23           = 312,
	F24           = 313,
	F25           = 314,
	KP_0          = 320,
	KP_1          = 321,
	KP_2          = 322,
	KP_3          = 323,
	KP_4          = 324,
	KP_5          = 325,
	KP_6          = 326,
	KP_7          = 327,
	KP_8          = 328,
	KP_9          = 329,
	KP_Decimal    = 330,
	KP_Divide     = 331,
	KP_Multiply   = 332,
	KP_Subtract   = 333,
	KP_Add        = 334,
	KP_Enter      = 335,
	KP_Equal      = 336,
	Left_Shift    = 340,
	Left_Control  = 341,
	Left_Alt      = 342,
	Left_Super    = 343,
	Right_Shift   = 344,
	Right_Control = 345,
	Right_Alt     = 346,
	Right_Super   = 347,
	Menu          = 348,
}

@(private)
glfw_window: glfw.WindowHandle

@(private)
window_context: runtime.Context

init :: proc(c: runtime.Context) {

	window_context = c
	triggered_keyboard_keys = make(map[KEYS]bool)
	down_keyboard_keys = make(map[KEYS]bool)

	if glfw.Init() != glfw.TRUE {
		fmt.println("Failed to initialize GLFW")
		return
	}

	glfw.WindowHint(glfw.RESIZABLE, glfw.TRUE)
	glfw.WindowHint(glfw.OPENGL_FORWARD_COMPAT, glfw.TRUE)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, GL_MAJOR_VERSION)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, GL_MINOR_VERSION)

	glfw_window = glfw.CreateWindow(640, 480, "Todo", nil, nil)

	if glfw_window == nil {
		fmt.println("Unable to create window")
		return
	}

	glfw.MakeContextCurrent(glfw_window)

	gl.load_up_to(GL_MAJOR_VERSION, GL_MINOR_VERSION, glfw.gl_set_proc_address)

	// Enable vsync
	glfw.SwapInterval(1)
	glfw.SetKeyCallback(glfw_window, key_callback)
	glfw.SetMouseButtonCallback(glfw_window, mouse_callback)
	glfw.SetCursorPosCallback(glfw_window, cursor_position_callback)
	glfw.SetFramebufferSizeCallback(glfw_window, framebuffer_size_callback)
}

update_events :: proc() {

	mouse_delta = {0, 0}
	clear_map(&triggered_keyboard_keys)
	glfw.PollEvents()
}

update_draw :: proc() {
	glfw.SwapBuffers(glfw_window)
}

end :: proc() {
	glfw.DestroyWindow(glfw_window)
	glfw.Terminate()

	delete(down_keyboard_keys)
	delete(triggered_keyboard_keys)
}

get_window_size :: proc() -> [2]i32 {

	x, y := glfw.GetWindowSize(glfw_window)
	return [2]i32{x, y}
}

is_key_triggered :: proc(key: KEYS) -> bool {

	return triggered_keyboard_keys[key]
}

is_key_down :: proc(key: KEYS) -> bool {
	return down_keyboard_keys[key]
}

@(private)
key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32) {

	context = window_context
	k := KEYS(key)

	if action == glfw.PRESS {
		triggered_keyboard_keys[k] = true
		down_keyboard_keys[k] = true
	}

	if action == glfw.RELEASE {
		delete_key(&down_keyboard_keys, k)
	}
}

get_mouse_pos :: #force_inline proc() -> [2]f32 {
	return mouse_pos
}

get_mouse_delta :: #force_inline proc() -> [2]f32 {
	return mouse_delta
}

@(private)
mouse_callback :: proc "c" (window: glfw.WindowHandle, button, action, mods: i32) {
}

@(private)
cursor_position_callback :: proc "c" (window: glfw.WindowHandle, xpos, ypos: f64) {

	mouse_delta.x = f32(xpos) - mouse_pos.x
	mouse_delta.y = f32(ypos) - mouse_pos.y

	mouse_pos.x = f32(xpos)
	mouse_pos.y = f32(ypos)
}

@(private)
scroll_callback :: proc "c" (window: glfw.WindowHandle, xoffset, yoffset: f64) {}

@(private)
framebuffer_size_callback :: proc "c" (window: glfw.WindowHandle, width, height: i32) {

	context = window_context
	window_size := get_window_size()
	gl.Viewport(0, 0, window_size.x, window_size.y)
}
