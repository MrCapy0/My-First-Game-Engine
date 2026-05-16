package engine

import queue "core:container/queue"
import lmath "core:math/linalg"

MAX_INSTANCES_DRAW_PER_MESH :: 100000

MeshPart :: struct {
	vao:            u32,
	vbo:            u32,
	ebo:            u32,
	buffer:         []f32,
	indices_buffer: []u32,
}

Mesh :: struct {
	draw_count:        u32,
	instance_buffer:   u32,
	instances:         ^[MAX_INSTANCES_DRAW_PER_MESH]lmath.Matrix4f32,
	instances_keys:    ^[MAX_INSTANCES_DRAW_PER_MESH]^u32,
	free_instance_ids: ^queue.Queue(^u32),
	parts:             []^MeshPart,
}
