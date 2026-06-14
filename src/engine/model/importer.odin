package model

import "core:strings"
import gltf "vendor:cgltf"

import engine "../"
import console "../console"
import render "../render"

@(private)
Mesh :: engine.Mesh

@(private)
MeshPart :: engine.MeshPart

from_file :: proc(path: string) -> ^Mesh {

	console.log("Importing model from %s", path)

	options: gltf.options = {}
	cpath := cstring(raw_data(path))
	data, result := gltf.parse_file(options, cpath)

	if result != .success {
		console.error("Can't load model file on %s error: %v", path, result)
		return {}
	}

	result = gltf.load_buffers(options, data, cpath)
	if result != .success {
		console.error("Can't read model on %s error: %v", path, result)
		return {}
	}

	gltf_mesh := data.meshes[0]
	mesh := new(Mesh)
	mesh.parts = make([]^MeshPart, len(gltf_mesh.primitives))
	for p, i in gltf_mesh.primitives {

		part := process_mesh_part(data, p)
		mesh.parts[i] = part
	}

	render.create_gpu_mesh(mesh)

	return mesh
}

@(private)
process_mesh_part :: proc(data: ^gltf.data, primitive: gltf.primitive) -> ^MeshPart {

	if primitive.type != .triangles {

		console.error("Invalid mesh part type: %v!", primitive.type)
		return {}
	}

	position_buffer: []f32
	uv_buffer: []f32
	position_count: uint
	uv_count: uint

	for att in primitive.attributes {

		accessor := att.data
		if (att.type == .position) {

			position_count = accessor.count

			if (accessor.component_type != .r_32f) {

				console.error(
					"Invalid mesh! position components must be %v but is %v",
					gltf.component_type.r_32f,
					accessor.component_type,
				)
			}

			if (accessor.type != .vec3) {

				console.error(
					"Invalid mesh! position type must be %v but is %v",
					gltf.type.vec3,
					accessor.type,
				)
			}

			position_buffer = make([]f32, position_count * 3)
			count := gltf.accessor_unpack_floats(accessor, &position_buffer[0], position_count * 3)
		}

		if att.type == .texcoord {

			if (accessor.type != .vec2) {
				console.error(
					"Invalid mesh! texcoord type must be %v but is %v",
					gltf.type.vec2,
					accessor.type,
				)
			}

			uv_count = accessor.count
			uv_buffer = make([]f32, uv_count * 2)
			count := gltf.accessor_unpack_floats(accessor, &uv_buffer[0], uv_count * 2)
		}
	}

	indices_accessor := primitive.indices
	if indices_accessor.component_type != .r_16u {

		console.error(
			"TODO: Add support for meshs with indices %v",
			indices_accessor.component_type,
		)

		console.error("Was expected u16 but the indice is %v.", indices_accessor.component_type)

		return {}
	}

	indices_buffer := make([]u16, indices_accessor.count)
	unpacked_indices_count := gltf.accessor_unpack_indices(
		indices_accessor,
		&indices_buffer[0],
		size_of(u16),
		indices_accessor.count,
	)

	// TODO: The buffer len is the sum of all buffers.
	// Maybe we can decrease buffer size adding options to not import some data like UVs?
	buffer_len := (position_count * 3) + (uv_count * 2)

	part := new(MeshPart)
	part.buffer = make([]f32, buffer_len)
	part.indices_buffer = make([]u32, unpacked_indices_count)

	for i in 0 ..< position_count {
		buffer_stride := i * (3 + 2) // Position + UV.
		position_stride := i * 3
		uv_stride := i * 2

		part.buffer[buffer_stride] = position_buffer[position_stride] * -1 // For some reason X is being imported in reverse.
		part.buffer[buffer_stride + 1] = position_buffer[position_stride + 1]
		part.buffer[buffer_stride + 2] = position_buffer[position_stride + 2]

		if len(uv_buffer) > 0 {
			part.buffer[buffer_stride + 3] = uv_buffer[uv_stride]
			part.buffer[buffer_stride + 4] = uv_buffer[uv_stride + 1]
		} else {
			part.buffer[buffer_stride + 3] = 0.0
			part.buffer[buffer_stride + 4] = 0.0
		}
	}

	for indice, i in indices_buffer {
		part.indices_buffer[i] = u32(indice)
	}

	delete(position_buffer)
	delete(indices_buffer)

	return part
}
