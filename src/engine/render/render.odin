package render

import engine "../"
import "core:container/queue"
import lmath "core:math/linalg"
import gl "vendor:OpenGL"

@(private)
Mesh :: engine.Mesh

@(private)
MeshPart :: engine.MeshPart

POSITION_ATTRIB :: 0
MATRIX_INSTANCING_ATTRIB :: 10

create_gpu_mesh :: proc(mesh: ^Mesh) {

	mesh.draw_count = 0
	mesh.instances = new([engine.MAX_INSTANCES_DRAW_PER_MESH]lmath.Matrix4f32)
	mesh.instances_keys = new([engine.MAX_INSTANCES_DRAW_PER_MESH]^u32)
	v4_size := size_of(lmath.Vector4f32)

	// Instancing buffer.
	gl.GenBuffers(1, &mesh.instance_buffer)
	gl.BindBuffer(gl.ARRAY_BUFFER, mesh.instance_buffer)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		engine.MAX_INSTANCES_DRAW_PER_MESH * size_of(lmath.Matrix4f32),
		raw_data(mesh.instances),
		gl.STATIC_DRAW,
	)

	for p in mesh.parts {

		// Mesh's part buffers.
		gl.GenVertexArrays(1, &p.vao)
		gl.BindVertexArray(p.vao)
		gl.GenBuffers(1, &p.vbo)
		gl.GenBuffers(1, &p.ebo)

		// VBO
		gl.BindBuffer(gl.ARRAY_BUFFER, p.vbo)
		gl.BufferData(
			gl.ARRAY_BUFFER,
			len(p.buffer) * size_of(f32),
			raw_data(p.buffer),
			gl.STATIC_DRAW,
		)

		// EBO
		gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, p.ebo)
		gl.BufferData(
			gl.ELEMENT_ARRAY_BUFFER,
			len(p.indices_buffer) * size_of(u32),
			raw_data(p.indices_buffer),
			gl.STATIC_DRAW,
		)

		gl.VertexAttribPointer(POSITION_ATTRIB, 3, gl.FLOAT, gl.FALSE, size_of(f32) * 3, 0)
		gl.EnableVertexAttribArray(POSITION_ATTRIB)

		// Configure instancing buffer.
		gl.BindBuffer(gl.ARRAY_BUFFER, mesh.instance_buffer)
		gl.VertexAttribPointer(
			MATRIX_INSTANCING_ATTRIB,
			4,
			gl.FLOAT,
			gl.FALSE,
			i32(4 * v4_size),
			0,
		)

		gl.VertexAttribPointer(
			MATRIX_INSTANCING_ATTRIB + 1,
			4,
			gl.FLOAT,
			gl.FALSE,
			i32(4 * v4_size),
			uintptr(v4_size),
		)

		gl.VertexAttribPointer(
			MATRIX_INSTANCING_ATTRIB + 2,
			4,
			gl.FLOAT,
			gl.FALSE,
			i32(4 * v4_size),
			uintptr(2 * v4_size),
		)

		gl.VertexAttribPointer(
			MATRIX_INSTANCING_ATTRIB + 3,
			4,
			gl.FLOAT,
			gl.FALSE,
			i32(4 * v4_size),
			uintptr(3 * v4_size),
		)

		gl.EnableVertexAttribArray(MATRIX_INSTANCING_ATTRIB)
		gl.EnableVertexAttribArray(MATRIX_INSTANCING_ATTRIB + 1)
		gl.EnableVertexAttribArray(MATRIX_INSTANCING_ATTRIB + 2)
		gl.EnableVertexAttribArray(MATRIX_INSTANCING_ATTRIB + 3)

		gl.VertexAttribDivisor(MATRIX_INSTANCING_ATTRIB, 1)
		gl.VertexAttribDivisor(MATRIX_INSTANCING_ATTRIB + 1, 1)
		gl.VertexAttribDivisor(MATRIX_INSTANCING_ATTRIB + 2, 1)
		gl.VertexAttribDivisor(MATRIX_INSTANCING_ATTRIB + 3, 1)
	}

	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BindVertexArray(0)

	mesh.free_instance_ids = new(queue.Queue(^u32))
	queue.init(mesh.free_instance_ids)
}

draw_model :: proc(model: Model) {

	parts := model.mesh.parts
	shaders := model.shaders
	draw_count := i32(model.mesh.draw_count)
	for p, i in parts {

		shader := shaders[i]

		gl.UseProgram(shader.program)
		gl.BindVertexArray(p.vao)
		gl.DrawElementsInstanced(
			gl.TRIANGLES,
			i32(len(p.indices_buffer)),
			gl.UNSIGNED_INT,
			nil,
			draw_count,
		)
	}
}

add_draw :: proc(mesh: ^Mesh, world: lmath.Matrix4f32) -> ^u32 {

	// TODO: Check parameters.

	if mesh.instances_keys[mesh.draw_count] == nil {
		mesh.instances_keys[mesh.draw_count] = new(u32)
	}

	id := mesh.instances_keys[mesh.draw_count]
	id^ = mesh.draw_count

	mesh.instances[id^] = world
	mesh.draw_count += 1

	update_instance(mesh, id)

	return id
}

remove_draw :: proc(mesh: ^Mesh, id: ^u32) {

	// TODO: Check parameters.
	queue.enqueue(mesh.free_instance_ids, id)

	// Swap last with cleaned ID.
	mesh.instances_keys[id^] = mesh.instances_keys[mesh.draw_count - 1]
	mesh.instances_keys[mesh.draw_count - 1] = id
	mesh.instances[id^] = mesh.instances[mesh.draw_count - 1]

	mesh.draw_count -= 1
}

update_instance :: proc(mesh: ^Mesh, id: ^u32) {

	world := mesh.instances[id^]
	matrix_size := int(size_of(lmath.Matrix4f32))

	gl.BindBuffer(gl.ARRAY_BUFFER, mesh.instance_buffer)
	gl.BufferSubData(gl.ARRAY_BUFFER, int(id^) * matrix_size, matrix_size, &world[0, 0])
	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
}
