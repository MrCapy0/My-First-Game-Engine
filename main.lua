require("src.engine.app")
require("src.engine.console")
require("src.engine.inputs_keyboard")
require("src.engine.math.vec")

Game = {}
local init_settings = InitSettings:new()
init_settings.window_title = "My Game"
init_settings.window_width = 1200
init_settings.window_height = 900
init_settings.window_allow_resize = true
init_settings.window_use_msaa_4x = true
init_settings.window_use_vsync = true

Game.init_settings = init_settings

local player_pos = V3.new(0, 2, 0)

function Game:Start()
    Console.log(V3.normalize(V3.new(1, 1, 1)))

    Console.log(V3.new(0, 2, 0) == V3.new(0, 2, 0))
    Console.log(V3.new(0, 2, 1) == V3.new(0, 2, 0))
end

function Game:Update(dt)
    local move_speed = dt * 10
    player_pos = player_pos - V3.new(0, 0, move_speed)
    App.set_camera_3d(player_pos, V3.new(0, 0, 1))
end
