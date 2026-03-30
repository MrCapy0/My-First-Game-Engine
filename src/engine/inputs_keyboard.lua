Keyboard = {

    ---@enum Keyboard.Keys
    Keys = {
        a = "a",
        b = "b",
        c = "c",
        d = "d",
        e = "e",
        f = "f",
        g = "g",
        h = "h",
        i = "i",
        j = "j",
        k = "k",
        l = "l",
        m = "m",
        n = "n",
        o = "o",
        p = "p",
        q = "q",
        r = "r",
        s = "s",
        t = "t",
        u = "u",
        v = "v",
        w = "w",
        x = "x",
        y = "y",
        z = "z",

        n0 = "0",
        n1 = "1",
        n2 = "2",
        n3 = "3",
        n4 = "4",
        n5 = "5",
        n6 = "6",
        n7 = "7",
        n8 = "8",
        n9 = "9",

        space = "space",
        escape = "escape",
        enter = "enter",
        tab = "tab",
        backspace = "backspace",
        insert = "insert",
        delete = "delete",

        up = "up",
        down = "down",
        left = "left",
        right = "right",

        shift = "shift",
        ctrl = "ctrl",
        alt = "alt",

        f1 = "f1",
        f2 = "f2",
        f3 = "f3",
        f4 = "f4",
        f5 = "f5",
        f6 = "f6",
        f7 = "f7",
        f8 = "f8",
        f9 = "f9",
        f10 = "f10",
        f11 = "f11",
        f12 = "f12"
    }
}

---@param key Keyboard.Keys
function Keyboard.was_pressed(key)
    ---@diagnostic disable-next-line: undefined-global
    return __InputsKeyboard._was_pressed(key)
end

return Keyboard
