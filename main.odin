package main

import "base:runtime"
import "core:c"
import "core:fmt"
import gl "vendor:OpenGL"
import "vendor:glfw"

GL_MAJOR_VERSION :: 4
GL_MINOR_VERSION :: 1

window: glfw.WindowHandle
default_context: runtime.Context

should_exit := false

main :: proc() {

	default_context = context

	fmt.println("Hellope!")

	if glfw.Init() != glfw.TRUE {
		fmt.println("Failed to initialize GLFW")
		return
	}
	defer glfw.Terminate()

	glfw.WindowHint(glfw.RESIZABLE, glfw.TRUE)
	glfw.WindowHint(glfw.OPENGL_FORWARD_COMPAT, glfw.TRUE)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, GL_MAJOR_VERSION)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, GL_MINOR_VERSION)

	window = glfw.CreateWindow(640, 480, "Todo", nil, nil)
	defer glfw.DestroyWindow(window)

	if window == nil {
		fmt.println("Unable to create window")
		return
	}

	glfw.MakeContextCurrent(window)

	// Enable vsync
	glfw.SwapInterval(1)

	gl.load_up_to(GL_MAJOR_VERSION, GL_MINOR_VERSION, glfw.gl_set_proc_address)

	glfw.SetKeyCallback(window, key_callback)
	glfw.SetMouseButtonCallback(window, mouse_callback)
	glfw.SetCursorPosCallback(window, cursor_position_callback)
	glfw.SetFramebufferSizeCallback(window, framebuffer_size_callback)

	for !glfw.WindowShouldClose(window) && !should_exit {
		gl.ClearColor(0.2, 0.3, 0.3, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT) // clear with the color set above

		glfw.SwapBuffers(window)
		glfw.PollEvents()
	}

	glfw.Terminate()
}

key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32) {
	if key == glfw.KEY_ESCAPE && action == glfw.PRESS {
		should_exit = true
	}
}

mouse_callback :: proc "c" (window: glfw.WindowHandle, button, action, mods: i32) {}

cursor_position_callback :: proc "c" (window: glfw.WindowHandle, xpos, ypos: f64) {}

scroll_callback :: proc "c" (window: glfw.WindowHandle, xoffset, yoffset: f64) {}

framebuffer_size_callback :: proc "c" (window: glfw.WindowHandle, width, height: i32) {

	context = default_context
	window_size := get_window_size()
	gl.Viewport(0, 0, window_size.x, window_size.y)
}

get_window_size :: proc() -> [2]i32 {

	x, y := glfw.GetWindowSize(window)
	return [2]i32{x, y}
}
