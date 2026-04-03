package inputs

import "core:fmt"
import "vendor:raylib"

import "../console"

KeyboardKey :: raylib.KeyboardKey

to_keyboard_key :: proc(key_name: string) -> KeyboardKey {
	switch key_name {
	case "a":
		return .A
	case "b":
		return .B
	case "c":
		return .C
	case "d":
		return .D
	case "e":
		return .E
	case "f":
		return .F
	case "g":
		return .G
	case "h":
		return .H
	case "i":
		return .I
	case "j":
		return .J
	case "k":
		return .K
	case "l":
		return .L
	case "m":
		return .M
	case "n":
		return .N
	case "o":
		return .O
	case "p":
		return .P
	case "q":
		return .Q
	case "r":
		return .R
	case "s":
		return .S
	case "t":
		return .T
	case "u":
		return .U
	case "v":
		return .V
	case "w":
		return .W
	case "x":
		return .X
	case "y":
		return .Y
	case "z":
		return .Z

	case "0":
		return .ZERO
	case "1":
		return .ONE
	case "2":
		return .TWO
	case "3":
		return .THREE
	case "4":
		return .FOUR
	case "5":
		return .FIVE
	case "6":
		return .SIX
	case "7":
		return .SEVEN
	case "8":
		return .EIGHT
	case "9":
		return .NINE

	case "space":
		return .SPACE
	case "escape":
		return .ESCAPE
	case "enter":
		return .ENTER
	case "tab":
		return .TAB
	case "backspace":
		return .BACKSPACE
	case "insert":
		return .INSERT
	case "delete":
		return .DELETE
	case "up":
		return .UP
	case "down":
		return .DOWN
	case "left":
		return .LEFT
	case "right":
		return .RIGHT

	case "shift":
		return .LEFT_SHIFT
	case "ctrl":
		return .LEFT_CONTROL
	case "alt":
		return .LEFT_ALT

	case "f1":
		return .F1
	case "f2":
		return .F2
	case "f3":
		return .F3
	case "f4":
		return .F4
	case "f5":
		return .F5
	case "f6":
		return .F6
	case "f7":
		return .F7
	case "f8":
		return .F8
	case "f9":
		return .F9
	case "f10":
		return .F10
	case "f11":
		return .F11
	case "f12":
		return .F12

	case:
		error := fmt.aprintfln("Key %s is invalid", key_name)
		console.error(error)
		return .KEY_NULL
	}
}

is_started :: proc(key: KeyboardKey) -> bool{
	return raylib.IsKeyPressed(key)
}

is_pressed :: proc(key: KeyboardKey) -> bool {
	return raylib.IsKeyDown(key)
}
