package model

import gl "vendor:OpenGL"
import gltf "vendor:cgltf"

import "../console"

V3 :: [3]f32

Mesh :: struct {
	indices:  []u32,
	vertices: []f32,
	vao:      u32,
	vbo:      u32,
	ebo:      u32,
}

from_file :: proc(path: string) -> ^Mesh {

	options: gltf.options = {}
	cpath := cstring(raw_data(path))
	data, result := gltf.parse_file(options, cpath)

	if result != .success {

		console.error("Can't load model file on %s error: %v", path, result)
		return nil
	}

	result = gltf.load_buffers(options, data, cpath)
	if result != .success {

		console.error("Can't read model on %s error: %v", path, result)
		return nil
	}

	primitive := data.meshes[0].primitives[0]
	mesh := new(Mesh)

	if primitive.indices != nil {

		accessor := primitive.indices
		indices := make([]u32, accessor.count)
		t := new([]f32)

		test := gltf.accessor_unpack_indices(accessor, &indices[0], size_of(u32), accessor.count)
		mesh.indices = indices
	}

	for attribute in primitive.attributes {

		if attribute.type == .position {

			accessor := attribute.data
			num_components := gltf.num_components(accessor.type)
			total_floats := accessor.count * num_components

			vertices := make([]f32, total_floats)
			test := gltf.accessor_unpack_floats(accessor, &vertices[0], total_floats)
			mesh.vertices = vertices
		}
	}

	create_gpu_instance(mesh)

	return mesh
}

unload_mesh :: proc(mesh: ^Mesh) {

	if mesh == nil {
		return
	}

	free(mesh)
}

create_gpu_instance :: proc(mesh: ^Mesh) {

	gl.GenVertexArrays(1, &mesh.vao)
	gl.BindVertexArray(mesh.vao)

	gl.GenBuffers(1, &mesh.vbo)
	gl.GenBuffers(1, &mesh.ebo)

	gl.BindBuffer(gl.ARRAY_BUFFER, mesh.vbo)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, mesh.ebo)

	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(mesh.vertices) * size_of(f32),
		raw_data(mesh.vertices),
		gl.STATIC_DRAW,
	)

	gl.BufferData(
		gl.ELEMENT_ARRAY_BUFFER,
		len(mesh.indices) * size_of(u32),
		raw_data(mesh.indices),
		gl.STATIC_DRAW,
	)

	// Vertex position only
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 8 * size_of(f32), 0)
	gl.EnableVertexAttribArray(0)

	gl.VertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, 8 * size_of(f32), 3 * size_of(f32))
	gl.EnableVertexAttribArray(1)

	gl.VertexAttribPointer(2, 2, gl.FLOAT, gl.FALSE, 8 * size_of(f32), 6 * size_of(f32))
	gl.EnableVertexAttribArray(2)

	// Unbinding
	gl.BindVertexArray(0)

	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
}
