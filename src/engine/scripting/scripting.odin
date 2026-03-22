package scripting

import runtime "base:runtime"
import c "core:c"
import fmt "core:fmt"
import lua "vendor:lua/5.4"

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
	tables:    []Table,
}

FieldRef :: struct {
	id:   Int,
	type: Type,
}


@(private)
lua_state: ^lua.State

@(private)
_context: runtime.Context


init :: proc() {

	_context = context
	lua_state = lua.newstate(lua_allocator, &_context)
}

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

	lua.L_newlib(lua_state, functions_list)
	lua.setglobal(lua_state, table.name)
}

load_scripts :: proc() {
	status := lua.L_dofile(lua_state, "main.lua")
}

get_field :: proc(table: cstring, field: cstring, result: ^FieldRef) -> Status {

	top := lua.gettop(lua_state)
	defer lua.settop(lua_state, top)

	fmt.printfln("initial: %d", lua.gettop(lua_state))
	result^ = {}
	upper_type := lua.Type(lua.getglobal(lua_state, table))
	status := Status.OK

	if upper_type == Type.NIL {
		status = .TABLE_DOES_NOT_EXIST
	} else if upper_type != Type.TABLE {
		status = .INVALID_TABLE
	}

	if status == Status.OK {
		field_type := lua.Type(lua.getfield(lua_state, -1, field))

		result^ = FieldRef {
			id   = lua.L_ref(lua_state, lua.REGISTRYINDEX),
			type = field_type,
		}
	}

	return status
}

print_stack_debug :: proc() {
	top := lua.gettop(lua_state)
	fmt.printfln("--- STACK TOP: %d ---", top)
	for i in 1 ..= top {
		type := lua.type(lua_state, i)
		fmt.printfln("[%d] %s", i, lua.typename(lua_state, type))
	}
	fmt.println("---------------------")
}

run_func :: proc(func: ^FieldRef) {

	if func.type == Type.NIL {
		return
	}

	top := lua.gettop(lua_state)
	defer lua.settop(lua_state, top)

	current_type := Type(lua.rawgeti(lua_state, lua.REGISTRYINDEX, lua.Integer(func.id)))

	if current_type != func.type {
		func.type = current_type
	}

	if func.type == .FUNCTION {
		if lua.pcall(lua_state, 0, 0, 0) != 0 {
			fmt.printfln("Error: %s", lua.tostring(lua_state, -1))
		}
	}
}

get_context :: proc() -> runtime.Context {
	return _context
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
