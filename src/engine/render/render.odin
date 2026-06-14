package render

import engine "../"
import lmath "../lmath"
import "core:container/queue"
import gl "vendor:OpenGL"

@(private)
Mesh :: engine.Mesh

@(private)
MeshPart :: engine.MeshPart

POSITION_ATTRIB :: 0
UV_ATTRIB :: 2
MATRIX_INSTANCING_ATTRIB :: 10

UBO_VIEW_BINDING_ID :: 0

ViewSettings :: struct {
	transform: lmath.Transform,
	fov:       f32,
	near:      f32,
	far:       f32,
}

@(private)
ViewData :: struct {
	perspective: lmath.M4,
	translation: lmath.M4,
	rotation:    lmath.M4,
}

@(private)
View :: struct {
	updated:  bool,
	ubo:      u32,
	settings: ViewSettings,
	data:     ViewData,
}

@(private)
view: View

start :: proc() {

	// View.
	{
		// Create view UBO.
		gl.GenBuffers(1, &view.ubo)
		gl.BindBuffer(gl.UNIFORM_BUFFER, view.ubo)
		gl.BufferData(gl.UNIFORM_BUFFER, size_of(ViewData), nil, gl.STATIC_DRAW)
		gl.BindBuffer(gl.UNIFORM_BUFFER, 0)

		// Default settings.
		view.settings = {
			near = 0.02,
			far = 10000,
			fov = 60,
			transform = {pos = lmath.V3_ZERO, rot = lmath.Q_Identity},
		}

		view.updated = true
		view.data = {
			translation = lmath.M4_inverse(lmath.translate(lmath.V3({0, 0, 0}))),
			rotation    = lmath.M4_Identity,
			perspective = lmath.M4_perspective(
				view.settings.fov * lmath.DEG_TO_RAD,
				1,
				view.settings.near,
				view.settings.far,
				true,
			),
		}
	}
}

update :: proc() {

	// Update view.
	{
		if view.updated {
			view.updated = false
			gl.BindBuffer(gl.UNIFORM_BUFFER, view.ubo)
			gl.BufferSubData(gl.UNIFORM_BUFFER, 0, size_of(ViewData), &view.data)
			gl.BindBuffer(gl.UNIFORM_BUFFER, 0)
		}
	}
}

create_gpu_mesh :: proc(mesh: ^Mesh) {

	mesh.draw_count = 0
	mesh.instances = new([engine.MAX_INSTANCES_DRAW_PER_MESH]lmath.M4)
	mesh.instances_keys = new([engine.MAX_INSTANCES_DRAW_PER_MESH]^u32)
	v4_size := size_of(lmath.V4)

	// Instancing buffer.
	gl.GenBuffers(1, &mesh.instance_buffer)
	gl.BindBuffer(gl.ARRAY_BUFFER, mesh.instance_buffer)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		engine.MAX_INSTANCES_DRAW_PER_MESH * size_of(lmath.M4),
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

		stride: i32 = size_of(f32) * (3 + 2)
		gl.VertexAttribPointer(POSITION_ATTRIB, 3, gl.FLOAT, gl.FALSE, stride, 0)
		gl.EnableVertexAttribArray(POSITION_ATTRIB)

		gl.VertexAttribPointer(UV_ATTRIB, 2, gl.FLOAT, gl.FALSE, stride, uintptr(3 * size_of(f32)))
		gl.EnableVertexAttribArray(UV_ATTRIB)

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

add_draw :: proc(mesh: ^Mesh, world: lmath.M4) -> ^u32 {

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

set_view :: proc(v: ViewSettings) {

	// TODO: Send to GPU only on draw.

	view.updated = true
	view.data = {
		translation = lmath.M4_inverse(lmath.translate(v.transform.pos)),
		rotation    = lmath.M4_inverse(lmath.Q_to_M4(v.transform.rot)),
		perspective = lmath.M4_perspective(
			view.settings.fov * lmath.DEG_TO_RAD,
			1,
			view.settings.near,
			view.settings.far,
			false,
		),
	}
}

@(private)
update_instance :: proc(mesh: ^Mesh, id: ^u32) {

	world := mesh.instances[id^]
	matrix_size := int(size_of(lmath.M4))

	gl.BindBuffer(gl.ARRAY_BUFFER, mesh.instance_buffer)
	gl.BufferSubData(gl.ARRAY_BUFFER, int(id^) * matrix_size, matrix_size, &world[0, 0])
	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
}
