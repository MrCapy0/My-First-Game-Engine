App = {}

---@class InitSettings
---@field window_title string
---@field window_width integer
---@field window_height integer
InitSettings = {
    window_title = "Game",
    window_width = 800,
    window_height = 600,
}

---@param title string
---@param window_width integer
---@param window_height integer
---@return InitSettings
function InitSettings:new(title, window_width, window_height)
    return {
        window_title = title,
        window_width = window_width,
        window_height = window_height
    }
end

function App.set_camera_3d(pos, rot)
    ---@diagnostic disable-next-line: undefined-global
    __App._set_camera_3d(pos, rot)
end

function App.get_delta()
    ---@diagnostic disable-next-line: undefined-global
    return __App._get_delta()
end

return App, InitSettings
