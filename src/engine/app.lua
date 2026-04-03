App = {}

---@class InitSettings
---@field window_title string
---@field window_width integer
---@field window_height integer
---@field window_allow_resize boolean
---@field window_use_vsync boolean
---@field window_use_msaa_4x boolean
---@field window_use_full_screen boolean
InitSettings = {
    window_title = "Game",
    window_width = 800,
    window_height = 600,
    window_allow_resize = true,
    window_use_vsync = true,
    window_use_msaa_4x = true,
    window_use_full_screen = true
}

---@return InitSettings
function InitSettings:new()
    return {
        window_title = "Game",
        window_width = 800,
        window_height = 600,
        window_allow_resize = true,
        window_use_vsync = true,
        window_use_msaa_4x = true,
        window_use_full_screen = true
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

---@param full_screen boolean
function App.set_full_screen(full_screen)
    ---@diagnostic disable-next-line: undefined-global
    __App._set_full_screen(full_screen)
end

---@return boolean
function App.get_is_full_screen()
    ---@diagnostic disable-next-line: undefined-global
    return __App._get_is_full_screen()
end

return App, InitSettings
