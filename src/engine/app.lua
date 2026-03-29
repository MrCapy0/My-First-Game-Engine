App = {}

function App.set_camera_3d(pos, rot)
    ---@diagnostic disable-next-line: undefined-global
    __App._set_camera_3d(pos, rot)
end

function App.get_delta()
    ---@diagnostic disable-next-line: undefined-global
    return __App._get_delta()
end

return App
