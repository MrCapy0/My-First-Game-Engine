package render

import "core:math/linalg"
import os "core:os"
import gl "vendor:OpenGL"

import console "../console"

ShaderParameterTypes :: enum {
	FLOAT     = gl.FLOAT,
	V3        = gl.FLOAT_VEC3,
	TEXTURE2D = gl.SAMPLER_2D,
	M4        = gl.FLOAT_MAT4,
}

ShaderParamFloat :: struct {
	location: i32,
	value:    f32,
}

ShaderParamV3 :: struct {
	location: i32,
	value:    linalg.Vector3f32,
}

ShaderParamM4 :: struct {
	location: i32,
	value:    linalg.Matrix4x4f32,
}

ShaderParamTexture2D :: struct {
	location: i32,
	value:    i32,
}

ShaderParam :: union {
	ShaderParamFloat,
	ShaderParamV3,
	ShaderParamM4,
	ShaderParamTexture2D,
}

Shader :: struct {
	id: u32,
}

ShaderInternal :: struct {
	program:    u32,
	parameters: map[string]ShaderParam,
}

RenderQueueId :: struct {
	shader_program: u32,
	vao:            u32,
}

DrawCall :: struct {
	apply_params_queue: ^[dynamic]ShaderParam,
}

DrawSettings :: struct {
	parameters: []ShaderParam,
}

loaded_shaders: [dynamic]ShaderInternal
draw_queue: map[RenderQueueId]^DrawCall
draw_requests: u64 = 0

load_shader :: proc(v_path: string, f_path: string) -> Shader {

	allocator := context.allocator
	v_code, v_code_ok := os.read_entire_file(v_path, allocator)
	f_code, f_code_ok := os.read_entire_file(f_path, allocator)

	if v_code_ok != os.General_Error.None {

		console.error("Load vertex shader file error: %v \npath: %s", v_code_ok, v_path)
		return {}
	}

	defer delete(v_code, allocator)

	if f_code_ok != os.General_Error.None {

		console.error("Load fragment shader file error: %v \npath: %s", f_code_ok, f_path)
		return {}
	}

	defer delete(f_code, allocator)

	v_shader := gl.CreateShader(gl.VERTEX_SHADER)
	f_shader := gl.CreateShader(gl.FRAGMENT_SHADER)

	v_code_s := cstring(raw_data(string(v_code)))
	f_code_s := cstring(raw_data(string(f_code)))
	gl.ShaderSource(v_shader, 1, &v_code_s, nil)
	gl.ShaderSource(f_shader, 1, &f_code_s, nil)

	gl.CompileShader(v_shader)
	gl.CompileShader(f_shader)

	// TODO: Add macro for debug/release

	v_compile_ok: i32
	f_compile_ok: i32
	gl.GetShaderiv(v_shader, gl.COMPILE_STATUS, &v_compile_ok)
	gl.GetShaderiv(f_shader, gl.COMPILE_STATUS, &f_compile_ok)

	if v_compile_ok == 0 {

		log_len: i32
		gl.GetShaderiv(v_shader, gl.INFO_LOG_LENGTH, &log_len)

		message := make([]u8, log_len, context.temp_allocator)
		gl.GetShaderInfoLog(v_shader, log_len, &log_len, &message[0])

		console.error(
			"Shader compilation error on vertex shader: \n    path: %s\n    error: %s\n",
			v_path,
			message,
		)

		free_all(context.temp_allocator)
		return {}
	}

	if f_compile_ok == 0 {

		log_len: i32
		gl.GetShaderiv(f_shader, gl.INFO_LOG_LENGTH, &log_len)

		message := make([]u8, log_len, context.temp_allocator)
		gl.GetShaderInfoLog(f_shader, log_len, &log_len, &message[0])

		console.error(
			"Shader compilation error on fragment shader:\n    path: %s\n    error: %s",
			f_path,
			message,
		)

		free_all(context.temp_allocator)
		return {}
	}

	program := gl.CreateProgram()
	gl.AttachShader(program, v_shader)
	gl.AttachShader(program, f_shader)
	gl.LinkProgram(program)

	program_link_ok: i32
	gl.GetProgramiv(program, gl.LINK_STATUS, &program_link_ok)

	if program_link_ok == 0 {

		log_len: i32
		gl.GetProgramiv(program, gl.INFO_LOG_LENGTH, &log_len)

		message := make([]u8, log_len, context.temp_allocator)
		gl.GetProgramInfoLog(program, log_len, &log_len, &message[0])

		console.error(
			"Shader linking error:\n    vertex shader: %s\n    fragment shader: %s\n    error:",
			v_path,
			f_path,
			message,
		)

		free_all(context.temp_allocator)
		return {}
	}

	new_shader: Shader = {
		id = u32(len(loaded_shaders)),
	}

	new_shader_internal: ShaderInternal = {
		program = program,
	}

	parameters_count: i32
	parameter_biggest_name_len: i32
	gl.GetProgramiv(program, gl.ACTIVE_UNIFORMS, &parameters_count)
	gl.GetProgramiv(program, gl.ACTIVE_UNIFORM_MAX_LENGTH, &parameter_biggest_name_len)

	name_buffer := make([]u8, parameter_biggest_name_len, context.temp_allocator)

	for i: u32 = 0; i < u32(parameters_count); i += 1 {

		parameter_name_len: i32
		parameter_size: i32
		parameter_type_raw: u32
		gl.GetActiveUniform(
			program,
			i,
			parameter_biggest_name_len,
			&parameter_name_len,
			&parameter_size,
			&parameter_type_raw,
			raw_data(name_buffer),
		)

		parameter_name := string(name_buffer[:parameter_name_len])
		parameter_type := ShaderParameterTypes(parameter_type_raw)
		parameter_location := gl.GetUniformLocation(program, cstring(raw_data(parameter_name)))

		#partial switch parameter_type {
		case .FLOAT:
			new_shader_internal.parameters[parameter_name] = ShaderParamFloat {
				location = parameter_location,
				value    = 0,
			}
			break
		case .V3:
			new_shader_internal.parameters[parameter_name] = ShaderParamV3 {
				location = parameter_location,
				value    = {0, 0, 0},
			}
			break
		case .TEXTURE2D:
			new_shader_internal.parameters[parameter_name] = ShaderParamTexture2D {
				location = parameter_location,
				value    = 0,
			}
			break
		}
	}

	append(&loaded_shaders, new_shader_internal)
	free_all(context.temp_allocator)
	return new_shader
}

init :: proc() {
	draw_queue = make(map[RenderQueueId]^DrawCall)
}

update :: proc() {

	last_vao: u32
	last_program: u32

	for id, draw_call in draw_queue {

		shader_program := id.shader_program
		vao := id.vao

		if last_program != shader_program {
			last_program = shader_program
			gl.UseProgram(shader_program)
		}

		// Apply parameters.
		for param_raw in draw_call.apply_params_queue {

			switch param in param_raw {
			case ShaderParamFloat:
				gl.Uniform1f(param.location, param.value)
				break
			case ShaderParamV3:
				x := param.value.x
				y := param.value.y
				z := param.value.z
				gl.Uniform3f(param.location, x, y, z)
				break
			case ShaderParamM4:
				break
			case ShaderParamTexture2D:
				break
			}
		}

		clear_dynamic_array(draw_call.apply_params_queue)

		if last_vao != vao {
			last_vao = vao
			gl.BindVertexArray(vao)
		}

		gl.DrawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, nil)
	}

	gl.UseProgram(0)
	gl.BindVertexArray(0)
}

end :: proc() {

	shaders_count := len(loaded_shaders)
	for i := 0; i < shaders_count; i += 1 {
		shader := loaded_shaders[i]
		gl.DeleteProgram(shader.program)
	}
}

@(private)
get_program :: #force_no_inline proc(shader: Shader) -> u32 {
	return loaded_shaders[shader.id].program
}

add_draw :: proc(shader: Shader, vao: u32, draw_settings: DrawSettings) -> u64 {

	shader_program := get_program(shader)
	queue_id: RenderQueueId = {
		shader_program = shader_program,
		vao            = vao,
	}

	// TODO: Instead of add/remove why not use a pool?

	draw_id := draw_requests
	draw_call: ^DrawCall = new(DrawCall)
	draw_call.apply_params_queue = new([dynamic]ShaderParam)

	for param in draw_settings.parameters {
		append(draw_call.apply_params_queue, param)
	}

	draw_queue[queue_id] = draw_call
	draw_requests += 1

	return draw_id
}

remove_draw :: proc(shader: Shader, vao: u32, id: u64) {

	queue_id: RenderQueueId = {
		shader_program = get_program(shader),
		vao            = vao,
	}

	data, exist := draw_queue[queue_id]
	if exist {
		free(data)
		draw_queue[queue_id] = nil
	}

	delete_key(&draw_queue, queue_id)
}

update_draw :: proc(shader: Shader, vao: u32, id: u64, param: ShaderParam) {

	// TODO: Add assert.

	queue_id: RenderQueueId = {
		shader_program = get_program(shader),
		vao            = vao,
	}

	draw_call, exist := draw_queue[queue_id]
	if exist {

		// TODO: Avoid duplicated appends.
		append(draw_call.apply_params_queue, param)
	}
}

get_uniform_location :: proc(shader: Shader, name: string) -> i32 {

	params := &loaded_shaders[shader.id].parameters
	value, exist := params[name]

	// TODO: Cache locations.
	return gl.GetUniformLocation(get_program(shader), cstring(raw_data(name)))
}

// @(private)
// apply_params :: proc(queue_id: RenderQueueId, id: u64) {

// 	// TODO: Add a way to skip unchanged values.

// 	shader_program := queue_id.shader_program
// 	queue := draw_queues[queue_id]
// 	params := queue[id].shader_params
// 	gl.UseProgram(shader_program)

// for param_raw in params {

// 	switch param in param_raw {
// 	case ShaderParamFloat:
// 		console.log_fmt("apply %d %4f", param.location, param.value)
// 		gl.Uniform1f(param.location, param.value)
// 		console.log("hello")
// 		break
// 	case ShaderParamV3:
// 		break
// 	case ShaderParamM4:
// 		break
// 	case ShaderParamTexture2D:
// 		break
// 	}
// }

// 	gl.UseProgram(0)
// }
