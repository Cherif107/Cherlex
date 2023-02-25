local Game = require 'cherlex.Game'

---@class Angle
local Angle = {}
Angle = {
    DEG = 180/math.pi,
    RAD = math.pi/180,

    angleFromOrigin = function(x, y, deg)
        return math.atan2(x, y) * (deg and Angle.DEG or 1)
    end,
    wrapAngle = function(angle)
        angle = (angle > 180 and Angle.wrapAngle(angle - 360) or (angle < -180 and Angle.wrapAngle(angle + 360) or angle))
        return angle
    end,
    angleBetweenMouse = function(Object, degrees)
        if Object == nil then return 0 end

        local p = Object.getScreenPosition()
        local dx = Game.mouse.screenX - p.x
        local dy = Game.mouse.screenY - p.y

        p.put()
        return Angle.angleFromOrigin(dx, dy, degrees)
    end,
    angleBetween = function(Object, Object2, deg)
        local dx = (Object2.x+Object2.origin.x) - (Object.x+Object.origin.x)
        local dy = (Object2.y+Object2.origin.y) - (Object.y+Object.origin.y)
        return Angle.angleFromOrigin(dx, dy, deg)
    end,

    radiansFromOrigin = function(x, y) return Angle.angleFromOrigin(x, y, false) end,
    degreesFromOrigin = function(x, y) return Angle.angleFromOrigin(x, y, true) end,
    radiansBetweenMouse = function(Object) return Angle.angleBetweenMouse(Object, false) end,
    degreesBetweenMouse = function(Object) return Angle.angleBetweenMouse(Object, true) end,
    radiansBetween = function(Object1, Object2) return Angle.angleBetween(Object1, Object2, false) end,
    degreesBetween = function(Object1, Object2) return Angle.angleBetween(Object1, Object2, true) end,
}

return Angle