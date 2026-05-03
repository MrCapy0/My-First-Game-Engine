package main

import runtime "base:runtime"
import lmath "core:math/linalg"
import "core:math/rand"
import gl "vendor:OpenGL"

import "src/engine/model"
import "src/engine/render"
import "src/engine/window"

GL_MAJOR_VERSION :: 4
GL_MINOR_VERSION :: 1

default_context: runtime.Context

main :: proc() {

	default_context = context

	window.init(default_context)

	//cube := model.from_file("assets/models/Cube.glb")
	//plane_2 := model.from_file("assets/models/Plane.glb")
	//test := model.from_file("assets/models/Test.glb")
	//tutorial1 := model.from_file("assets/models/tutorial1.glb")
	//mesh := model.from_file("assets/models/triangle.glb")
	//mesh := model.from_file("assets/models/House_5.glb")
	mesh := model.from_file("assets/models/car.glb")
	shader := render.load_shader("my_shader.vert", "my_shader.frag")

	view_param_loc := gl.GetUniformLocation(shader.program, "v")
	perspective_param_loc := gl.GetUniformLocation(shader.program, "p")
	transform_param_loc := gl.GetUniformLocation(shader.program, "t")

	window.set_cursor_visible(true)

	vbo: u32
	vao: u32
	ebo: u32

	gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)

	cam_pos: lmath.Vector3f32 = {0, -2, -6}
	cam_rot: lmath.Vector3f32 = {0, 0, 0}
	pos: lmath.Vector3f32 = {0, 0, 0}
	rot: lmath.Vector3f32 = {0, 0, 0}

	model: render.Model = {}
	model.mesh = mesh
	model.shaders = make([]render.Shader, len(mesh.parts))
	for i in 0 ..< len(mesh.parts) {
		model.shaders[i] = shader
	}

	for true {
		window.update_events()

		if window.is_key_triggered(window.KEYS.Escape) {
			break
		}

		cam_rot.y += f32(window.get_delta_time()) * 0.1
		pos.y += f32(window.get_delta_time()) / 3

		//cam_pos.z += f32(window.get_delta_time())

		perspective := lmath.matrix4_perspective(
			60 * lmath.RAD_PER_DEG,
			window.get_window_aspect(),
			0.05,
			1000,
			true,
		)
		cam_mat := lmath.matrix4_translate(cam_pos)
		// cam_mat *= linalg.matrix4_from_quaternion_f32(
		// 	linalg.quaternion_from_pitch_yaw_roll_f32(cam_rot.x, cam_rot.y, cam_rot.z),
		// )
		// cam_mat := linalg.matrix4_look_at(
		// 	cam_pos,
		// 	linalg.Vector3f32({0, 0, 0}),
		// 	linalg.Vector3f32({0, 1, 0}),
		// 	true,
		// )

		rot.y += f32(window.get_delta_time() * 0.1)
		transform := lmath.identity(lmath.Matrix4f32)
		//transform = linalg.matrix4_translate_f32(pos)
		transform *= lmath.matrix4_from_quaternion(
			lmath.quaternion_from_pitch_yaw_roll(rot.x, rot.y, rot.z),
		)

		gl.ClearColor(0.2, 0.3, 0.3, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT) // clear with the color set above

		gl.UseProgram(shader.program)
		gl.UniformMatrix4fv(view_param_loc, 1, gl.FALSE, &cam_mat[0, 0])
		gl.UniformMatrix4fv(perspective_param_loc, 1, gl.FALSE, &perspective[0, 0])
		gl.UniformMatrix4fv(transform_param_loc, 1, gl.FALSE, &transform[0, 0])

		render.draw_model(model)
		window.update_draw()
	}

	window.end()
}
