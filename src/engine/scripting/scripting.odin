package scripting

import runtime "base:runtime"
import c "core:c"
import fmt "core:fmt"
import strings "core:strings"
import lua "vendor:lua/5.4"
import raylib "vendor:raylib"

import app "../app"
import console "../console"

Lua :: ^lua.State
Type :: lua.Type
Function :: lua.CFunction
Context :: runtime.Context
Int :: c.int
Number :: lua.Number

Status :: enum {
	OK,
	INVALID_TABLE,
	TABLE_DOES_NOT_EXIST,
	FIELD_DOES_NOT_EXIST,
}

Func :: struct {
	name:     cstring,
	function: Function,
}

Table :: struct {
	name:      cstring,
	functions: []Func,
}

FieldRef :: struct {
	id:   Int,
	type: Type,
}

@(private)
_lua_state: ^lua.State

@(private)
_context: runtime.Context

@(private)
_lua_stack: Int

init :: proc() {

	_context = context
	_lua_state = lua.newstate(lua_allocator, &_context)
	lua.L_openlibs(_lua_state)

	add_table(table_console)
	add_table(table_app)
	add_table(table_inputs_keyboard)
	add_table(table_gizmos)

	status := lua.Status(lua.L_dofile(_lua_state, "main.lua"))
	if status != .OK {
		err_msg := lua.tostring(_lua_state, -1)
		fmt.printfln("LUA ERROR: %s", err_msg)
		lua.pop(_lua_state, 1)
	}
}

@(private)
add_table :: proc(table: Table) {

	functions_len := len(table.functions)
	functions_list := make([]lua.L_Reg, functions_len + 1)

	defer delete(functions_list)

	// The last element must be null for lua knows where the table ends.
	functions_list[functions_len] = {nil, nil}

	for f, i in table.functions {
		functions_list[i] = {
			name = table.functions[i].name,
			func = table.functions[i].function,
		}
	}

	lua.L_newlib(_lua_state, functions_list)
	lua.setglobal(_lua_state, table.name)
}

get_field :: proc(table: cstring, field: cstring, result: ^FieldRef) -> Status {

	check_stack()

	defer assert_stack()

	result^ = {}
	upper_type := lua.Type(lua.getglobal(_lua_state, table))
	status := Status.OK

	if upper_type == Type.NIL {
		status = .TABLE_DOES_NOT_EXIST
	} else if upper_type != Type.TABLE {
		status = .INVALID_TABLE
	}

	if status != .OK {
		lua.pop(_lua_state, 1)
		return status
	}

	if status == Status.OK {
		field_type := lua.Type(lua.getfield(_lua_state, -1, field))

		result^ = FieldRef {
			id   = lua.L_ref(_lua_state, lua.REGISTRYINDEX),
			type = field_type,
		}

		if field_type == .NIL {
			status = .FIELD_DOES_NOT_EXIST
		}
	}

	lua.pop(_lua_state, 1)

	return status
}

run_func :: proc(func: ^FieldRef, table_name: cstring = nil, args: ..any) {

	if func.type == Type.NIL {
		return
	}

	current_type := Type(lua.rawgeti(_lua_state, lua.REGISTRYINDEX, lua.Integer(func.id)))

	if current_type != func.type {
		func.type = current_type
	}

	if func.type == .FUNCTION {

		nargs := i32(len(args))

		// Insert 'self' arg.
		if table_name != nil {
			// The first argument is 'self' passed by lua.
			if Type(lua.getglobal(_lua_state, table_name)) == .TABLE {
				nargs += 1
			} else {
				// Table not found.
				lua.pop(_lua_state, 1)
				console.warning_fmt(
					"Tried use %s as self but the table was not found.",
					table_name,
				)
			}
		}

		// push parameters.
		for arg in args {
			switch v in arg {
			case f32:
				lua.pushnumber(_lua_state, lua.Number(v))
			case f64:
				lua.pushnumber(_lua_state, lua.Number(v))
			case i32:
				lua.pushinteger(_lua_state, lua.Integer(v))
			case int:
				lua.pushinteger(_lua_state, lua.Integer(v))
			case string:
				lua.pushstring(_lua_state, strings.clone_to_cstring(v, context.temp_allocator))
			case bool:
				lua.pushboolean(_lua_state, b32(v))
			case:
				panic("invalid parameter type")
			}
		}

		if lua.pcall(_lua_state, nargs, 0, 0) != 0 {

			error := to_cstring(-1)
			console.error(string(error))
			lua.pop(_lua_state, 1)
		}
	}
}

get_context :: #force_inline proc() -> runtime.Context {
	return _context
}

to_bool :: #force_inline proc(index: Int) -> bool {

	// TODO: Check parameter type.

	check_stack()
	v := bool(lua.toboolean(_lua_state, index))
	assert_stack()

	return v
}

to_f32 :: #force_inline proc(index: Int) -> f32 {

	// TODO: Check parameter type.

	check_stack()

	number := f32(lua.tonumber(_lua_state, index))
	lua.pop(_lua_state, 1)

	assert_stack()

	return number
}

to_cstring :: #force_inline proc(index: Int) -> cstring {

	// TODO: Check parameter type.

	str := lua.L_tostring(_lua_state, index)
	return str
}

to_vec3 :: proc(index: Int) -> raylib.Vector3 {

	// TODO: Check parameter type.

	v: raylib.Vector3 = {0, 0, 0}
	check_stack()

	if lua.istable(_lua_state, index) {
		lua.getfield(_lua_state, index, "x"); v.x = f32(lua.tonumber(_lua_state, -1))
		lua.getfield(_lua_state, index, "y"); v.y = f32(lua.tonumber(_lua_state, -1))
		lua.getfield(_lua_state, index, "z"); v.z = f32(lua.tonumber(_lua_state, -1))
		lua.pop(_lua_state, 3)
	}

	defer assert_stack()

	return v
}

to_color :: proc(index: Int) -> raylib.Color {

	// TODO: Check parameter type.

	c: raylib.Color = {0, 0, 0, 1}
	check_stack()

	if lua.istable(_lua_state, index) {
		lua.getfield(_lua_state, index, "r"); c.r = u8(lua.tonumber(_lua_state, -1))
		lua.getfield(_lua_state, index, "g"); c.g = u8(lua.tonumber(_lua_state, -1))
		lua.getfield(_lua_state, index, "b"); c.b = u8(lua.tonumber(_lua_state, -1))
		lua.getfield(_lua_state, index, "a"); c.a = u8(lua.tonumber(_lua_state, -1))
		lua.pop(_lua_state, 4)
	}

	defer assert_stack()

	return c
}

to_init_settings :: proc(index: Int) -> app.InitSettings {

	init_settings := app.InitSettings{}
	init_settings.window_title = "Game"
	init_settings.window_width = 800
	init_settings.window_height = 600

	check_stack()

	if lua.istable(_lua_state, index) {

		// TODO: Check types before get values.

		lua.getfield(_lua_state, index, "window_title")
		init_settings.window_title = lua.tostring(_lua_state, -1)

		lua.getfield(_lua_state, index, "window_width")
		init_settings.window_width = i32(lua.tonumber(_lua_state, -1))

		lua.getfield(_lua_state, index, "window_height")
		init_settings.window_height = i32(lua.tonumber(_lua_state, -1))

		lua.getfield(_lua_state, index, "window_allow_resize")
		init_settings.window_allow_resize = bool(lua.toboolean(_lua_state, -1))

		lua.getfield(_lua_state, index, "window_use_msaa_4x")
		init_settings.window_use_msaa_4x = bool(lua.toboolean(_lua_state, -1))

		lua.getfield(_lua_state, index, "window_use_vsync")
		init_settings.window_use_vsync = bool(lua.toboolean(_lua_state, -1))

		lua.getfield(_lua_state, index, "window_use_full_screen")
		init_settings.window_use_full_screen = bool(lua.toboolean(_lua_state, -1))

		lua.pop(_lua_state, 7)
	}

	assert_stack()

	return init_settings
}

get_data :: #force_inline proc(field: ^FieldRef) -> Type {
	return Type(lua.rawgeti(_lua_state, lua.REGISTRYINDEX, lua.Integer(field.id)))
}

pop_data :: #force_inline proc(count: i32) {
	lua.pop(_lua_state, Int(count))
}

@(private)
push_number_f64 :: #force_inline proc(number: f64) {
	lua.pushnumber(_lua_state, Number(number))
}

@(private)
push_number_f32 :: #force_inline proc(number: f32) {
	lua.pushnumber(_lua_state, Number(number))
}

@(private)
push_number :: proc {
	push_number_f32,
	push_number_f64,
}

@(private)
push_bool :: proc(b: bool) {
	lua.pushboolean(_lua_state, b32(b))
}

@(private)
lua_allocator :: proc "c" (ud: rawptr, ptr: rawptr, osize, nsize: c.size_t) -> (buf: rawptr) {
	old_size := int(osize)
	new_size := int(nsize)
	context = (^runtime.Context)(ud)^

	if ptr == nil {
		data, err := runtime.mem_alloc(new_size)
		return raw_data(data) if err == .None else nil
	} else {
		if nsize > 0 {
			data, err := runtime.mem_resize(ptr, old_size, new_size)
			return raw_data(data) if err == .None else nil
		} else {
			runtime.mem_free(ptr)
			return
		}
	}
}

@(private)
@(disabled = !ODIN_DEBUG)
check_stack :: #force_inline proc() {
	_lua_stack = lua.gettop(_lua_state)
}

@(private)
@(disabled = !ODIN_DEBUG)
assert_stack :: proc() {

	stack_size := lua.gettop(_lua_state)
	message := fmt.tprintfln(
		"Memory leak allocking lua stack. Was spected %d but is %d",
		_lua_stack,
		stack_size,
	)
	assert(stack_size == _lua_stack, message)
}
