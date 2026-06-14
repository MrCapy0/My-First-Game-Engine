package main

import runtime "base:runtime"
import "core:math/rand"
import gl "vendor:OpenGL"

import "src/engine/console"
import "src/engine/model"
import "src/engine/render"
import "src/engine/window"

import lmath "src/engine/lmath"

import game "src/engine/game"

default_context: runtime.Context

main :: proc() {

	default_context = context

	window.init(default_context)
	render.start()

	//cube_mesh := model.from_file("assets/models/Cube.glb")
	//plane_2 := model.from_file("assets/models/Plane.glb")
	//test := model.from_file("assets/models/Test.glb")
	//tutorial1 := model.from_file("assets/models/tutorial1.glb")
	//mesh := model.from_file("assets/models/triangle.glb")
	//mesh := model.from_file("assets/models/House_5.glb")
	car_mesh := model.from_file("assets/models/car.glb")
	car_tex := render.load_texture("assets/models/T_Plymouth_Gran_Fury_1989_BaseColor.png")
	shader := render.load_shader("my_shader.vert", "my_shader.frag")

	//gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)

	pos: lmath.V3 = {0, 0, 0}
	rot: lmath.V3 = {0, 0, 0}

	model: render.Model = {}
	model.mesh = car_mesh
	model.shaders = make([]render.Shader, len(car_mesh.parts))

	gl.Enable(gl.DEPTH_TEST)

	//model_2: render.Model = {}
	//model_2.mesh = cube_mesh
	//model_2.shaders = make([]render.Shader, len(cube_mesh.parts))

	render.add_draw(model.mesh, lmath.M4_Identity)
	//render.add_draw(cube_mesh, lmath.translate(lmath.V3({2, 0, 1})))

	for i in 0 ..< len(model.shaders) {
		model.shaders[i] = shader
	}

	// for i in 0 ..< len(model_2.shaders) {
	// 	model_2.shaders[i] = shader
	// }

	test := false

	game.start()

	for !window.should_close() {
		window.update_events()

		if window.is_key_triggered(window.KEYS.Escape) {
			break
		}

		dt := window.get_delta_time()
		game.update(f32(dt))

		gl.ClearColor(0.2, 0.3, 0.3, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT) // clear with the color set above
		gl.BindTexture(gl.TEXTURE_2D, car_tex.gl)

		render.draw_model(model)
		//render.draw_model(model_2)
		render.update()

		window.update_draw()
	}

	window.end()
}
