require("src.engine.app")
require("src.engine.console")

Game = {}

function Game:Start()
end

function Game:Update(dt)
    App.set_camera_3d({ 5, 1, -5 }, { 0, 0, 1 })
end
