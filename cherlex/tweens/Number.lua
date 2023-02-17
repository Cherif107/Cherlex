local Tween = require 'cherlex.tweens.root.Tween'

---@class TweenNumber Tweening Numbers (callback required)
local TweenNumber = function(From, To, Duration, Options, TweenCallback, start)
    start = start or true
    local this = Tween(Duration, Options, function(twn, scale, elapsed)
        twn.value = twn.startValue + twn.range * scale
        if twn.callback ~= nil then twn.callback(twn.value, twn) end
    end)
    this.value = From
    this.startValue = From
    this.range = To-From
    this.callback = TweenCallback
    if start then this.start() end
    return this
end
return TweenNumber