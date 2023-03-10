local TweenNumber = require 'cherlex.tweens.Number'

---@class CircularMotion Circular motion tweens
local CircularMotion = function(Object, CenterX, CenterY, Radius, Angle, Clockwise, Duration_Speed, useDuration, Options)
    if useDuration == nil then useDuration = true end
    Duration_Speed = useDuration and Duration_Speed or (Radius * (math.pi * 2)) / Duration_Speed
    local this = TweenNumber(Angle*math.pi/(-180), (math.pi*2) * (Clockwise and 1 or -1), Duration_Speed, Options, function(v, twn)
        twn.object.x = twn.centerX + math.cos(v) * twn.radius
        twn.object.y = twn.centerY + math.sin(v) * twn.radius
    end, false)
    this.object = Object
    this.centerX, this.centerY = CenterX, CenterY
    this.radius = Radius
    this.start()
    return this
end
return CircularMotion