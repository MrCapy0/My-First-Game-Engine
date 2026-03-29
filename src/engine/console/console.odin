package console

import "core:fmt"

log :: #force_inline proc(str: string) {
	fmt.println("LOG: ", str)
}

log_fmt :: #force_inline proc(str: string, args: ..any) {
	fmt.print("LOG: ")
	fmt.printfln(str, args)
}

warning_fmt :: #force_inline proc(str: string, args: ..any) {
	fmt.print("WARNING: ")
	fmt.println(str, args)
}

warning :: #force_inline proc(str: string) {
	fmt.println("WARNING: ", str)
}

error :: #force_inline proc(str: string) {
	fmt.println("ERROR: ", str)
}
