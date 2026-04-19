package main

import runtime "base:runtime"
import c "core:c"
import fmt "core:fmt"
import "core:math/linalg"
import "core:math/rand"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"

import "src/engine/model"
import "src/engine/render"

GL_MAJOR_VERSION :: 4
GL_MINOR_VERSION :: 1

window: glfw.WindowHandle
default_context: runtime.Context

should_exit := false

vertices := []f32 {
	0.5,
	0.5,
	0.0,
	1.0,
	0.0,
	0.0,
	1.0,
	1.0, // top right
	0.5,
	-0.5,
	0.0,
	0.0,
	1.0,
	0.0,
	1.0,
	0.0, // bottom right
	-0.5,
	-0.5,
	0.0,
	0.0,
	0.0,
	1.0,
	0.0,
	0.0, // bottom left
	-0.5,
	0.5,
	0.0,
	1.0,
	1.0,
	0.0,
	0.0,
	1.0, // top left
}
indices := []u32{0, 1, 3, 1, 2, 3}

draw_id: u64
s: render.Shader

plane: model.Mesh

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

	render.init()

	// Enable vsync
	glfw.SwapInterval(1)

	gl.load_up_to(GL_MAJOR_VERSION, GL_MINOR_VERSION, glfw.gl_set_proc_address)

	glfw.SetKeyCallback(window, key_callback)
	glfw.SetMouseButtonCallback(window, mouse_callback)
	glfw.SetCursorPosCallback(window, cursor_position_callback)
	glfw.SetFramebufferSizeCallback(window, framebuffer_size_callback)

	s = render.load_shader("./my_shader.vert", "./my_shader.frag")
	t := render.load_texture("./assets/materials/Ceramic Floor_1.png")

	// Wire Mode
	//gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)

	//m := linalg.identity(linalg.Matrix4x4f32)

	cube := model.from_file("assets/models/Cube.glb")

	plane.vertices = []f32 {
		0.5,
		0.5,
		0.0,
		1.0,
		0.0,
		0.0,
		1.0,
		1.0, // top right
		0.5,
		-0.5,
		0.0,
		0.0,
		1.0,
		0.0,
		1.0,
		0.0, // bottom right
		-0.5,
		-0.5,
		0.0,
		0.0,
		0.0,
		1.0,
		0.0,
		0.0, // bottom left
		-0.5,
		0.5,
		0.0,
		1.0,
		1.0,
		0.0,
		0.0,
		1.0, // top left
	}
	plane.indices = []u32{0, 1, 3, 1, 2, 3}
	model.create_gpu_instance(&plane)

	draw_id = render.add_draw(
		s,
		plane.vao,
		{
			parameters = {
				render.ShaderParamFloat {
					location = render.get_uniform_location(s, "mult"),
					value = rand.float32(),
				},
				render.ShaderParamV3 {
					location = render.get_uniform_location(s, "color"),
					value = [3]f32{rand.float32(), rand.float32(), rand.float32()},
				},
			},
		},
	)


	for !glfw.WindowShouldClose(window) && !should_exit {

		mrz := linalg.matrix4_rotate_f32(linalg.DEG_PER_RAD * 30, {0, 0, 1})

		gl.ClearColor(0.2, 0.3, 0.3, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT) // clear with the color set above

		gl.ActiveTexture(gl.TEXTURE0)
		gl.BindTexture(gl.TEXTURE_2D, render.loaded_textures[t.id].texture)

		render.update()

		glfw.SwapBuffers(window)
		glfw.PollEvents()
	}

	render.end()

	glfw.Terminate()
}

key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32) {

	context = default_context

	if key == glfw.KEY_ESCAPE && action == glfw.PRESS {
		should_exit = true
	}

	if key == glfw.KEY_SPACE && action == glfw.PRESS {
		render.remove_draw(s, plane.vao, draw_id)
	}

	if key == glfw.KEY_ENTER && action == glfw.PRESS {
		render.update_draw(
			s,
			plane.vao,
			draw_id,
			render.ShaderParamFloat {
				location = render.get_uniform_location(s, "mult"),
				value = rand.float32(),
			},
		)

		render.update_draw(
			s,
			plane.vao,
			draw_id,
			render.ShaderParamV3 {
				location = render.get_uniform_location(s, "color"),
				value = [3]f32{rand.float32(), rand.float32(), rand.float32()},
			},
		)
	}

	if key == glfw.KEY_SPACE && action == glfw.PRESS {

		random_v := rand.float32()
		uniform_loc := render.get_uniform_location(s, "mult")
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
