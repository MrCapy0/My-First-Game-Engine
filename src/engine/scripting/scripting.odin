package scripting

import "../console"
import runtime "base:runtime"
import c "core:c"
import fmt "core:fmt"
import lua "vendor:lua/5.4"
import "vendor:raylib"

Lua :: ^lua.State
Type :: lua.Type
Function :: lua.CFunction
Context :: runtime.Context
Int :: c.int

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
	add_table(app_table)

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
	}

	lua.pop(_lua_state, 1)

	return status
}

run_func :: proc(func: ^FieldRef) {

	if func.type == Type.NIL {
		return
	}

	current_type := Type(lua.rawgeti(_lua_state, lua.REGISTRYINDEX, lua.Integer(func.id)))

	if current_type != func.type {
		func.type = current_type
	}

	if func.type == .FUNCTION {
		if lua.pcall(_lua_state, 0, 0, 0) != 0 {
			console.error(to_string(-1))
			lua.pop(_lua_state, 1)
		}
	}
}

get_context :: #force_inline proc() -> runtime.Context {
	return _context
}

to_f32 :: #force_inline proc(index: Int) -> f32 {

	check_stack()

	number := f32(lua.tonumber(_lua_state, index))
	lua.pop(_lua_state, 1)

	assert_stack()

	return number
}

to_string :: proc(index: Int) -> cstring {
	str := lua.tostring(_lua_state, index)
	return str
}

to_vec3 :: proc(index: Int) -> raylib.Vector3 {

	v: raylib.Vector3 = {0, 0, 0}
	check_stack()

	if lua.istable(_lua_state, index) {
		lua.rawgeti(_lua_state, index, 1); v.x = f32(lua.tonumber(_lua_state, -1))
		lua.rawgeti(_lua_state, index, 2); v.y = f32(lua.tonumber(_lua_state, -1))
		lua.rawgeti(_lua_state, index, 3); v.z = f32(lua.tonumber(_lua_state, -1))
		lua.pop(_lua_state, 3)
	}

	defer assert_stack()

	return v
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
check_stack :: proc() {
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
