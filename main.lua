require("src.engine.app")
require("src.engine.console")
require("src.engine.gizmos")
require("src.engine.inputs_keyboard")
require("src.engine.math.vec")
require("src.engine.color")

Game = {}
local init_settings = InitSettings:new()
init_settings.window_title = "My Game"
init_settings.window_width = 1200
init_settings.window_height = 800
init_settings.window_allow_resize = true
init_settings.window_use_msaa_4x = true
init_settings.window_use_vsync = true
init_settings.window_use_full_screen = false

Game.init_settings = init_settings

local player_pos = V3.new(0, 2, -10)
local t = 0

function Game:Start()
end

function Game:Update(dt)
    if Keyboard.is_started(Keyboard.Keys.space) then
        App.set_full_screen(not App.get_is_full_screen())
    end

    local move_speed = dt * 10
    t = t + (dt)
    --player_pos = player_pos - V3.new(0, 0, move_speed)
    App.set_camera_3d(player_pos, V3.new(0, 0, 1))
    Gizmos.draw_cube(V3.new(0, t, 0), V3.new(1, 1, 1), Color.DARK_BLUE)
end
