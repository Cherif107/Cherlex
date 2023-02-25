local Tween = require 'cherlex.tweens.root.Tween'

local function normalizeValues(Object, Values)
    local V = {}
    for f, v in next, Values, nil do
       V[f] = {
        startValue = Object[f],
        range = v-Object[f]
       }
    end
    return V
end

---@class TweenVariable For Tweening Variables
local TweenVariable = function(Object, Values, Duration, Options)
    local this = Tween(Duration, Options, function(twn, scale, elapsed)
        for field, value in next, twn.values, nil do
            twn.object[field] = value.startValue + value.range * scale
        end
    end)
    this.object = Object
    this.values = normalizeValues(this.object, Values)
    this.start()
    return this
end

return TweenVariable