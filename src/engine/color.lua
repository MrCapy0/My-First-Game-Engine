---@class Color
Color = {
    r = 0,
    g = 0,
    b = 0,
    a = 255,
    __index = Color,
}

function Color.new(r, g, b, a)
    return setmetatable({
        r = r or 0,
        g = g or 0,
        b = b or 0,
        a = a or 255
    }, Color)
end

Color.WHITE        = Color.new(255, 255, 255, 255)
Color.BLACK        = Color.new(0, 0, 0, 255)
Color.GRAY         = Color.new(128, 128, 128, 255)
Color.LIGHT_GRAY   = Color.new(200, 200, 200, 255)
Color.DARK_GRAY    = Color.new(50, 50, 50, 255)

Color.RED          = Color.new(255, 0, 0, 255)
Color.DARK_RED     = Color.new(139, 0, 0, 255)
Color.MAROON       = Color.new(128, 0, 0, 255)
Color.PINK         = Color.new(255, 192, 203, 255)
Color.MAGENTA      = Color.new(255, 0, 255, 255)

Color.GREEN        = Color.new(0, 255, 0, 255)
Color.DARK_GREEN   = Color.new(0, 100, 0, 255)
Color.LIME         = Color.new(50, 205, 50, 255)
Color.FOREST       = Color.new(34, 139, 34, 255)
Color.OLIVE        = Color.new(128, 128, 0, 255)

Color.BLUE         = Color.new(0, 0, 255, 255)
Color.DARK_BLUE    = Color.new(0, 0, 139, 255)
Color.SKY_BLUE     = Color.new(135, 206, 235, 255)
Color.NAVY         = Color.new(0, 0, 128, 255)
Color.CYAN         = Color.new(0, 255, 255, 255)

Color.YELLOW       = Color.new(255, 255, 0, 255)
Color.GOLD         = Color.new(255, 215, 0, 255)
Color.ORANGE       = Color.new(255, 165, 0, 255)
Color.DARK_ORANGE  = Color.new(255, 140, 0, 255)
Color.LIGHT_ORANGE = Color.new(255, 200, 80, 255)

Color.PURPLE       = Color.new(128, 0, 128, 255)
Color.VIOLET       = Color.new(238, 130, 238, 255)
Color.INDIGO       = Color.new(75, 0, 130, 255)

Color.BROWN        = Color.new(165, 42, 42, 255)
Color.SAND         = Color.new(194, 178, 128, 255)
Color.BEIGE        = Color.new(245, 245, 220, 255)

Color.TRANSPARENT  = Color.new(0, 0, 0, 0)
