local TweenNumber = require 'cherlex.tweens.Number'
local Color = require 'cherlex.util.Color'

---@class TweenColor Tween an Object's color by Interpolating it
local TweenColor = function(Object, From, To, Duration, Options)
    local this = TweenNumber(0, 1, Duration, Options, function(v, twn)
        twn.object.color = Color.interpolate(twn.fromColor, twn.toColor, v)
    end, false)
    this.object = Object
    this.fromColor = From
    this.toColor = To
    this.start()
    return this
end

return TweenColor