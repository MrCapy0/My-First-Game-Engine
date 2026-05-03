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

	console.log("scenes %d", len(data.scenes))
	for s in data.scenes {
		console.log("Scene %s", s.name)
		for n in s.nodes {
			log_scene_node(data, n, 1)
		}
	}
	console.log("Meshes %d", len(data.meshes))
	for m in data.meshes {
		console.log("	%s", m.name)
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
	position_count: uint

	for att in primitive.attributes {

		accessor := att.data
		if (att.type == .position) {

			position_count = accessor.count

			console.log("Vertices count %d", position_count)

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

	part := new(MeshPart)
	part.buffer = make([]f32, position_count * 3)
	part.indices_buffer = make([]u32, unpacked_indices_count)

	for p, i in position_buffer {
		part.buffer[i] = p
	}

	for indice, i in indices_buffer {
		part.indices_buffer[i] = u32(indice)
	}

	delete(position_buffer)
	delete(indices_buffer)

	return part
}

log_scene_node :: proc(data: ^gltf.data, node: ^gltf.node, iteration: i32) {

	sb: strings.Builder
	strings.builder_init(&sb)
	defer strings.builder_destroy(&sb)

	for i: i32 = 0; i < iteration * 4; i += 1 {
		strings.write_string(&sb, " ")
	}

	strings.write_string(&sb, string(node.name))
	strings.write_string(&sb, "		")
	if node.mesh != nil {
		strings.write_string(&sb, "mesh: ")
		strings.write_string(&sb, string(node.mesh.name))
	}

	console.log("%s", strings.to_string(sb))
	for n in node.children {
		log_scene_node(data, n, iteration + 1)
	}
}
