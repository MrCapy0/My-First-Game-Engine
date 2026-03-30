---@class V3
---@field x number
---@field y number
---@field z number
V3 = {
    x = 0,
    y = 0,
    z = 0,
    __index = V3
}

---@param x? number
---@param y? number
---@param z? number
---@return V3
function V3.new(x, y, z)
    return setmetatable({
        x = x or 0,
        y = y or 0,
        z = z or 0
    }, V3)
end

---@param a V3
---@param b V3
---@return V3
function V3.__add(a, b)
    return V3.new(
        a.x + b.x,
        a.y + b.y,
        a.z + b.z
    )
end

---@param a V3
---@param b V3
---@return V3
function V3.__sub(a, b)
    return V3.new(
        a.x - b.x,
        a.y - b.y,
        a.z - b.z
    )
end

---@param a V3
---@param b V3
---@return V3
function V3.__mul(a, b)
    return V3.new(
        a.x * b.x,
        a.y * b.y,
        a.z * b.z
    )
end

---@param a V3
---@param b V3
---@return V3
function V3.__div(a, b)
    return V3.new(
        a.x / b.x,
        a.y / b.y,
        a.z / b.z
    )
end

---@param a V3
---@param b V3
---@return boolean
function V3.__eq(a, b)
    return a.x == b.x and a.y == b.y and a.z == b.z
end

---@param a V3
---@param b V3
---@return boolean
function V3.__lt(a, b)
    if a.x ~= b.x then return a.x < b.x end
    if a.y ~= b.y then return a.y < b.y end
    return a.z < b.z
end

---@param a V3
---@param b V3
---@return boolean
function V3.__le(a, b)
    if a.x ~= b.x then return a.x <= b.x end
    if a.y ~= b.y then return a.y <= b.y end
    return a.z <= b.z
end

---@param v V3
---@return V3
function V3.normalize(v)
    local l = math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)

    if (l < 0.00001) then
        return V3.new(0, 0, 0)
    end

    return V3.new(v.x / l, v.y / l, v.z / l)
end

---@return string
function V3:__tostring()
    return string.format("(%.3f, %.3f, %.3f)", self.x, self.y, self.z)
end

return V3
