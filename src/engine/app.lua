App = {}

---@class InitSettings
---@field window_title string
---@field window_width integer
---@field window_height integer
---@field window_allow_resize boolean
---@field window_use_vsync boolean
---@field window_use_msaa_4x boolean
InitSettings = {
    window_title = "Game",
    window_width = 800,
    window_height = 600,
    window_allow_resize = true,
    window_use_vsync = true,
    window_use_msaa_4x = true
}

---@return InitSettings
function InitSettings:new()
    return {
        window_title = "Game",
        window_width = 800,
        window_height = 600,
        window_allow_resize = true,
        window_use_vsync = true,
        window_use_msaa_4x = true
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
