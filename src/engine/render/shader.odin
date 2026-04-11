package shader

import "core:log"
import os "core:os"
import gl "vendor:OpenGL"

import console "../console"

Shader :: struct {
	id: u32,
}

ShaderInternal :: struct {
	program: u32,
}

loaded_shaders: [dynamic]ShaderInternal

new_shader :: proc(v_path: string, f_path: string) -> Shader {

	allocator := context.allocator
	v_code, v_code_ok := os.read_entire_file(v_path, allocator)
	f_code, f_code_ok := os.read_entire_file(f_path, allocator)

	if v_code_ok != os.General_Error.None {

		console.error_fmt("Load vertex shader file error: %v \npath: %s", v_code_ok, v_path)
		return {}
	}

	defer delete(v_code, allocator)

	if f_code_ok != os.General_Error.None {

		console.error_fmt("Load fragment shader file error: %v \npath: %s", f_code_ok, f_path)
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

		console.error_fmt(
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

		console.error_fmt(
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

		console.error_fmt(
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

	append(&loaded_shaders, new_shader_internal)

	return new_shader
}

draw :: proc(shader: Shader) {

	// TODO: invalid shaders must be initialized with id -1 to handle error cases on debug builds.
	gl.UseProgram(loaded_shaders[shader.id].program)
}

end :: proc() {

	shaders_count := len(loaded_shaders)
	for i := 0; i < shaders_count; i += 1 {
		shader := loaded_shaders[i]
		gl.DeleteProgram(shader.program)
	}
}
