require("src.engine.app")
require("src.engine.console")

Game = {}
local init_settings = InitSettings:new()
init_settings.window_title = "My Game"
init_settings.window_width = 1200
init_settings.window_height = 900
init_settings.window_allow_resize = true
init_settings.window_use_msaa_4x = true
init_settings.window_use_vsync = true

Game.init_settings = init_settings

function Game:Start()
    Console.log("hello, world")
end

function Game:Update(dt)
    App.set_camera_3d({ 5, 1, -5 }, { 1, 0, 1 })
end
