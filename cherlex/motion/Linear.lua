local Tween = require 'cherlex.tweens.root.Tween'

---@class LinearMotion Linear motion tweens
local LinearMotion = function(Object, FromX, FromY, ToX, ToY, Duration_Speed, useDuration, Options)
    if useDuration == nil then useDuration = true end
    local this = Tween(1, Options, function(tween, scale, elapsed)
        tween.object.x = tween.fromX + tween.moveX * scale
        tween.object.y = tween.fromY + tween.moveY * scale
        if (tween.secondsSinceStart >= tween.duration and tween.x == (tween.fromX+tween.moveX) and tween.y == (tween.fromY+tween.moveY)) then
            tween.tweenCount = tween.tweenCount + 1
            tween.finished = true
        end
    end)
    setmetatable(this, {__index = function(t, k)
        if k == 'distance' then
            return getDistance(t)
        end
        return rawget(t, k)
    end})
    this.object = Object
    this.distance = -1
    this.fromX, this.fromY = FromX, FromY
    this.moveX, this.moveY = ToX-FromX, ToY-FromY
    this.duration = (useDuration and Duration_Speed or getDistance(this)/Duration_Speed)
    this.allowFinish = false
    this.start()
    return this
end

function getDistance(t)
    if rawget(t, 'distance') < 0 then
        t.distance = math.sqrt(t.moveX^2+t.moveY^2)
        return math.sqrt(t.moveX^2+t.moveY^2)
    end
    return rawget(t, 'distance')
end

return LinearMotion