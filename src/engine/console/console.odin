package console

import "core:fmt"

log :: #force_inline proc(str: string, args: ..any) {
	fmt.print("INFO: ")
	fmt.printfln(str, ..args)
}

warning :: #force_inline proc(str: string, args: ..any) {
	fmt.print("WARNING: ")
	fmt.printfln(str, ..args)
}

error :: #force_inline proc(str: string, args: ..any) {
	fmt.print("ERROR: ")
	fmt.printfln(str, ..args)
}
