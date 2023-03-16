local function contains(t, k)
    for i, o in pairs(t) do
        if k == i then
            return true
        end
    end
end
---@class Vector2 a Vector2 class
local Vector2 = {}
Vector2.new = function(x, y)
    local this = {}
    this = {
        x = x or 0,
        y = y or 0,

        add = function(v2, res)
            res = res or Vector2.new()
            res.setTo(v2.x+this.x, v2.y+this.y)
            return res
        end,
        clone = function()
            return Vector2.new(this.x, this.y)
        end,
        equals = function(v2)
            return (v2 ~= nil and (this.x == v2.x) and (this.y == v2.y))
        end,
        normalize = function(thickness)
            if this.x == 0 and this.y == 0 then return end
            local norm = thickness / math.sqrt(this.x^2+this.y^2)
            this.x = this.x*norm
            this.y = this.y*norm
        end,
        offset = function(dx, dy)
            this.x, this.y = this.x + dx, this.y + dy
        end,
        setTo = function(xa, ya)
            this.x, this.y = xa, ya
        end,
        subtract = function(v, res)
            res = res or Vector2.new()
            res.setTo(this.x-v.x, this.y-v.y)
            return res
        end
    }
    local gettersnSetters = {}
    gettersnSetters = {
        length = {get = function() return gettersnSetters.lengthSquared.get()^0.5 end},
        lengthSquared = {get = function() return this.x^2+this.y^2 end}
    }
    return setmetatable(this, {
        __index = function(t, k)
            if contains(gettersnSetters, k) then
                return gettersnSetters[k].get()
            end
            return rawget(t, k)
        end
    })
end

Vector2.distance = function(p1, p2)
    return math.sqrt((p1.x-p2.x)^2 + (p1.y-p2.y)^2)
end
Vector2.interpolate = function(p1, p2, f, res)
    res = res or Vector2.new()
    res.setTo(p2.x+f*(p1.x-p2.x), p2.y+f*(p1.y-p2.y))
    return res
end
Vector2.polar = function(len, angle, res)
    res = res or Vector2.new()
    res.setTo(len*math.cos(angle), len*math.sin(angle))
    return res
end
return setmetatable(Vector2, {__call = function(t, ...) return Vector2.new(...) end})