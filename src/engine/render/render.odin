package render

import engine "../"
import gl "vendor:OpenGL"

@(private)
Mesh :: engine.Mesh

@(private)
MeshPart :: engine.MeshPart

create_gpu_mesh :: proc(mesh: ^Mesh) {

	for p in mesh.parts {

		gl.GenVertexArrays(1, &p.vao)
		gl.BindVertexArray(p.vao)
		gl.GenBuffers(1, &p.vbo)
		gl.GenBuffers(1, &p.ebo)
		gl.BindBuffer(gl.ARRAY_BUFFER, p.vbo)
		gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, p.ebo)
		gl.BufferData(
			gl.ARRAY_BUFFER,
			len(p.buffer) * size_of(f32),
			raw_data(p.buffer),
			gl.STATIC_DRAW,
		)
		gl.BufferData(
			gl.ELEMENT_ARRAY_BUFFER,
			len(p.indices_buffer) * size_of(u32),
			raw_data(p.indices_buffer),
			gl.STATIC_DRAW,
		)
		gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, size_of(f32) * 3, 0)
		gl.EnableVertexAttribArray(0)
	}

	gl.BindVertexArray(0)
}

draw_model :: proc(model: Model) {

	parts := model.mesh.parts
	shaders := model.shaders
	for p, i in parts {

		shader := shaders[i]

		gl.UseProgram(shader.program)
		gl.BindVertexArray(p.vao)
		gl.DrawElements(
			gl.TRIANGLES,
			i32(len(p.indices_buffer)),
			gl.UNSIGNED_INT,
			nil,
		)
	}
}
