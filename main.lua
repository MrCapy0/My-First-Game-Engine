require("src.engine.app")
require("src.engine.console")

Game = {}
Game.init_settings = InitSettings:new("My Game", 1920, 1050)

function Game:Start()
    Console.log("hello, world")
end

function Game:Update(dt)
    App.set_camera_3d({ 5, 1, -5 }, { 1, 0, 1 })
end
