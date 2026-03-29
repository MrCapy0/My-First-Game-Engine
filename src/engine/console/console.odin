package console

import "core:fmt"

log :: #force_inline proc(str: string) {
	fmt.println("INFO: ", str)
}

log_fmt :: #force_inline proc(str: string, args: ..any) {
	fmt.print("INFO: ")
	fmt.printfln(str, ..args)
}

warning_fmt :: #force_inline proc(str: string, args: ..any) {
	fmt.print("WARNING: ")
	fmt.printfln(str, ..args)
}
warning :: #force_inline proc(str: string) {
	fmt.println("WARNING: ", str)
}

error :: #force_inline proc(str: string) {
	fmt.println("ERROR: ", str)
}
