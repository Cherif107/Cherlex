local EPSILON = 0.0000001
---@class Math an extention for lua math
local meth = {}
meth = {
    PI2 = math.pi/2,

    NaN = 0/0,
    NEGATIVE_INFINITY = -1/0,
    POSITIVE_INFINITY = 1/0,

    EPSILON = EPSILON,
    
    round = function(x)
        return x + 0.5 - (x + 0.5) % 1
    end,
    tround = function(x, n)
        x = x * 10^(n or 0)
        return (x >= 0 and math.floor(x+0.5) or math.ceil(x+0.5))/10^(n or 0)
    end,
    roundDecimal = function(x, n)
        return tonumber(string.format('%.'..n..'f', x))
    end,
    isNaN = function(x) return x ~= x end,
    distance = function(x1, y1, x2, y2)
        return ((x2-x1)^2+(y2-y1)^2)^0.5
    end,
    distanceBetween = function(Object1, Object2)
        return meth.distance(Object1.x, Object1.y, Object2.x, Object2.y)
    end,
    angleBetween = function(x1, y1, x2, y2)
        return math.deg(math.atan((y2-y1)/(x2-x1)))
    end,
    lerp = function(value, goal, ratio)
        return value + ratio * (goal - value)
    end,
    equals = function(A, B, Diff)
        Diff = Diff or EPSILON
        return math.abs(A-B) <= Diff
    end,
    pointInCoords = function(px, py, rx, ry, rw, rh)
        return (px >= rx and px <= (rx + rw)) and (py >= ry and py <= (ry + rh))
    end,
    pointInObject = function(px, py, Object)
        return meth.pointInCoords(px, py, Object.x, Object.y, Object.width, Object.height)
    end,
    vectorLength = function(dx, dy) return math.sqrt(dx^2+dy^2) end,
    isFinite = function(x)
        return (x ~= meth.POSITIVE_INFINITY and x ~= meth.NEGATIVE_INFINITY and x ~= meth.NaN)
    end,
    bound = function(value, max, min)
        local lower = ((min ~= nil and value < min) and min or value)
        return (max ~= nil and lower > max) and max or lower
    end,
    wrap = function(value, min, max)
        local range = max - min + 1
        if value < min then
            value = value + range * math.floor((min-value) / range + 1)
        end
        return min + (value-min) % range
    end
}


return meth
-- ok