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

vertices := []f32{0.5, 0.5, 0.0, 0.5, -0.5, 0.0, -0.5, -0.5, 0.0, -0.5, 0.5, 0.0}
indices := []u32{0, 1, 3, 1, 2, 3}

main :: proc() {

	vert_shader_code: cstring = `
	#version 410 core

	layout (location = 0) in vec3 aPos;

	void main()
	{
		gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
	}
	`
	frag_shader_code: cstring = `
	#version 330 core
	out vec4 FragColor;

	void main()
	{
		FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);
	} 
	`

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

	// Rendering

	// Shader
	v_shader: u32 = gl.CreateShader(gl.VERTEX_SHADER)
	f_shader: u32 = gl.CreateShader(gl.FRAGMENT_SHADER)

	gl.ShaderSource(v_shader, 1, &vert_shader_code, nil)
	gl.ShaderSource(f_shader, 1, &frag_shader_code, nil)

	gl.CompileShader(v_shader)
	gl.CompileShader(f_shader)

	compile_success: i32
	gl.GetShaderiv(v_shader, gl.COMPILE_STATUS, &compile_success)
	if compile_success == 0 {

		log: [1024]u8
		error_len: i32
		gl.GetShaderInfoLog(v_shader, 512, &error_len, &log[0])
		fmt.printfln("Compile vertex shader error:")

		msg := string(log[:error_len])
		fmt.printfln("%s", msg)
	}

	gl.GetShaderiv(f_shader, gl.COMPILE_STATUS, &compile_success)
	if compile_success == 0 {

		log: [1024]u8
		error_len: i32
		gl.GetShaderInfoLog(f_shader, 512, &error_len, &log[0])
		fmt.printfln("Compile fragment shader error:")

		msg := string(log[:error_len])
		fmt.printfln("%s", msg)
	}

	s_program := gl.CreateProgram()
	gl.AttachShader(s_program, v_shader)
	gl.AttachShader(s_program, f_shader)
	gl.LinkProgram(s_program)

	gl.GetProgramiv(s_program, gl.LINK_STATUS, &compile_success)
	if compile_success == 0 {

		log: [1024]u8
		error_len: i32
		gl.GetProgramInfoLog(f_shader, 512, &error_len, &log[0])
		fmt.printfln("Link shader error:")

		msg := string(log[:error_len])
		fmt.printfln("%s", msg)
	}

	gl.DeleteShader(f_shader)
	gl.DeleteShader(v_shader)

	// Create mesh
	vbo: u32
	vao: u32
	ebo: u32

	gl.GenVertexArrays(1, &vao)
	gl.BindVertexArray(vao)
	gl.GenBuffers(1, &vbo)
	gl.GenBuffers(1, &ebo)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(vertices) * size_of(f32),
		raw_data(vertices),
		gl.STATIC_DRAW,
	)
	gl.BufferData(
		gl.ELEMENT_ARRAY_BUFFER,
		len(indices) * size_of(u32),
		raw_data(indices),
		gl.STATIC_DRAW,
	)

	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * size_of(f32), 0)
	gl.EnableVertexAttribArray(0)

	// Unbinding
	gl.BindVertexArray(0)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
	gl.BindBuffer(gl.ARRAY_BUFFER, 0)

	// Wire Mode
	gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)
	
	for !glfw.WindowShouldClose(window) && !should_exit {
		gl.ClearColor(0.2, 0.3, 0.3, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT) // clear with the color set above

		gl.UseProgram(s_program)
		gl.BindVertexArray(vao)
		gl.DrawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, nil)

		glfw.SwapBuffers(window)
		glfw.PollEvents()
	}

	// Unload mesh
	gl.DeleteBuffers(1, &ebo)
	gl.DeleteBuffers(1, &vbo)
	gl.DeleteVertexArrays(1, &vao)
	gl.DeleteProgram(s_program)

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
