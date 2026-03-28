Console = {}

function Console.log(str)
    ---@diagnostic disable-next-line: undefined-global
    __Console._log(str)
end

return Console
