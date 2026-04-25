package main

import runtime "base:runtime"
import c "core:c"
import fmt "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:math/rand"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"

import "src/engine/model"
import "src/engine/render"
import "src/engine/window"

GL_MAJOR_VERSION :: 4
GL_MINOR_VERSION :: 1

default_context: runtime.Context

should_exit := false

draw_id: u64
s: render.Shader
transform: linalg.Matrix4x4f32

plane: model.Mesh
view_pos: linalg.Vector3f32

w_pressed := false
s_pressed := false
a_pressed := false
d_pressed := false

arrow_left_pressed := false
arrow_right_pressed := false

rot_y: f32 = 0

main :: proc() {

	default_context = context

	window.init(default_context)
	render.init()

	s = render.load_shader("./my_shader.vert", "./my_shader.frag")
	t := render.load_texture("./assets/materials/Ceramic Floor_1.png")

	cube := model.from_file("assets/models/Cube.glb")
	transform = linalg.matrix4_translate_f32({0, 0, 0})

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
				render.ShaderParamM4 {
					location = render.get_uniform_location(s, "transform"),
					value = transform,
				},
			},
		},
	)

	view_pos = {0, 0, 5}
	render.set_camera_transform(view_pos, render.camera_rot)

	for true {
		window.update_events()

		if window.is_key_triggered(window.KEYS.Space) {
			fmt.printfln("trigger")
		}

		if window.is_key_down(window.KEYS.E) {
			fmt.printfln("press")
		}

		//fmt.printfln("%f %f", window.get_mouse_pos().x, window.get_mouse_pos().y)
		fmt.printfln("%f %f", window.get_mouse_delta().x, window.get_mouse_delta().y)

		mrz := linalg.matrix4_rotate_f32(linalg.DEG_PER_RAD * 30, {0, 0, 1})

		gl.ClearColor(0.2, 0.3, 0.3, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT) // clear with the color set above

		gl.ActiveTexture(gl.TEXTURE0)
		gl.BindTexture(gl.TEXTURE_2D, render.loaded_textures[t.id].texture)

		window_size := window.get_window_size()
		aspect := f32(window_size.x) / f32(window_size.y)
		render.set_camera_transform(view_pos, linalg.quaternion_from_euler_angle_y(rot_y))

		move_speed :: 0.1
		if window.is_key_down(window.KEYS.W) {
			view_pos.z -= move_speed
		}

		if window.is_key_down(window.KEYS.S) {
			view_pos.z += move_speed
		}

		if window.is_key_down(window.KEYS.A) {
			view_pos.x += move_speed
		}

		if window.is_key_down(window.KEYS.D) {
			view_pos.x -= move_speed
		}

		mouse_delta := window.get_mouse_delta()

		rot_y += mouse_delta.x * -0.01

		render.update()
		window.update_draw()
	}

	render.end()
	window.end()
}
