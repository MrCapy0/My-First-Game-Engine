package console

import "core:fmt"

log :: #force_inline proc(str: cstring) {
	fmt.println("LOG: ", str)
}

warning :: #force_inline proc(str: cstring) {
	fmt.println("WARNING: ", str)
}

error :: #force_inline proc(str: cstring) {
	fmt.println("ERROR: ", str)
}

