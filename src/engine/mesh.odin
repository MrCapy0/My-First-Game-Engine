package engine

MeshPart :: struct {
	vao:            u32,
	vbo:            u32,
	ebo:            u32,
	buffer:         []f32,
	indices_buffer: []u32,
}

Mesh :: struct {
	parts: []^MeshPart,
}
