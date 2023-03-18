local Angle = require 'cherlex.math.Angle'
local Math = require 'cherlex.math.Math'

---@class Velocity a velocity class
local Velocity = {}
Velocity = {
    moveTowardsObject = function(Object1, Object2, speed, maxTime)
        speed = speed or 60 maxTime = maxTime or 0
        local a = Angle.angleBetween(Object1, Object2)
        if maxTime > 0 then
            local d = Math.distanceBetween(Object1, Object2)
            speed = math.floor(d/(maxTime/1000))
        end
        Object1.velocity.x = math.cos(a)*speed
        Object1.velocity.y = math.sin(a)*speed
    end
}
return Velocity