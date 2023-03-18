local import = require 'import'
local Ease = import 'tweens.Ease'
local Type = import 'tweens.Type'
local Math = import 'math.Math'
local Color = import 'util.Color'

local function uhhhIdk(name, key)
    if type(key) == 'number' then
        return name..'['..key..']'
    end
    return name..'.'..key
end

local tweens = {}
local function normalizeValues(Name, Values)
    local V = {}
    for f, v in next, Values, nil do
       V[f] = {
        startValue = getProperty(uhhhIdk(Name, f)),
        range = v-getProperty(uhhhIdk(Name, f))
       }
    end
    return V
end


---@class Tween_OLD a tween class
local Tween = {}
Tween = {
    tween = function(Object, Values, Duration, Options)
        Options = Options or {}
        local this = {}
        this = {
            Object = Object,
            Values = normalizeValues(rawget(Object, '__name'), Values),
            Duration = Duration,

            Ease = Options.ease or Ease.linear,
            Type = Options.type or Type.PERSIST,
            onComplete = Options.onComplete,

            _onUpdate = Options.onUpdate,

            finished = false,
            scale = 0,

            extraInfo = {
                _secondsSinceStart = 0,
                startDelay = 0
            },
            backwardsOn = Options.type == Type.BACKWARD,
            tweenCount = 0,

            replay = function()
                return Tween.tween(Object, Values, Duration, Options)
            end,
            cancel = function()
                this.finished = true
                for field, fT in next, this.Values, nil do
                    Object[field] = fT.startValue
                end
            end,
            stop = function()
                this.finished = true
            end,
            pause = function()
                this.paused = true
            end,
            resume = function()
                this.paused = false
            end
        }
        table.insert(tweens, this)
        return this
    end,
    num = function(From, To, Duration, Options, TweenCallback)
        Options = Options or {}
        local this = {}
        this = {
            value = From,
            startValue = From,
            range = To-From,
            Duration = Duration,

            Ease = Options.ease or Ease.linear,
            Type = Options.type or Type.PERSIST,
            onComplete = Options.onComplete,
            _onUpdate = Options.onUpdate,

            onUpdate = TweenCallback,

            finished = false,
            scale = 0,

            extraInfo = {
                _secondsSinceStart = 0,
                startDelay = 0
            },
            backwardsOn = Options.type == Type.BACKWARD,

            number = true,
            tweenCount = 0,

            replay = function()
                return Tween.num(From, To, Duration, Options, TweenCallback)
            end,
            cancel = function()
                this.finished = true
                this.value = From
            end,
            stop = function()
                this.finished = true
            end
        }
        table.insert(tweens, this)
        return this, #tweens
    end
}
Tween.circularMotion = function(Object, X, Y, Radius, Angle, Clockwise, Duration_Speed, useDuration, Options)
    useDuration = useDuration or true
    Duration_Speed = useDuration and Duration_Speed or (Radius * (math.pi * 2)) / Duration_Speed
    local twn = {}
    twn = Tween.num(Angle*math.pi/(-180), (math.pi*2) * (Clockwise and 1 or -1), Duration_Speed, Options, function(v)
        Object.x = X + math.cos(v) * Radius
        Object.y = Y + math.sin(v) * Radius
    end)
    return twn

end
Tween.color = function(Object, From, To, Duration, Options)
    return Tween.num(0, 1, Duration, Options, function(v)
        Object.color = Color.interpolate(From, To, v)
    end)
end

local p = onUpdate or nil
function onUpdate(el)
    for _, tween in next, tweens, nil do
        if not tween.finished and not tween.paused then
            tween.extraInfo._secondsSinceStart = math.min(tween.extraInfo._secondsSinceStart + el, tween.Duration)
            tween.scale = tween.Ease(math.max((tween.extraInfo._secondsSinceStart), 0) / tween.Duration)
            if tween.backwardsOn then
                tween.scale = 1-tween.scale
            end
            if tween.number then
                tween.value = tween.startValue+tween.range*tween.scale
                if tween.onUpdate ~= nil then
                    tween.onUpdate(tween.value)
                end
            else
                for f, v in next, tween.Values, nil do
                    tween.Object[f] = v.startValue+v.range*tween.scale
                end
            end
            if tween._onUpdate ~= nil then
                tween._onUpdate(tween)
            end
            if tween.extraInfo._secondsSinceStart >= tween.Duration then
                if (tween.Type == Type.PINGPONG) then
                    tween.extraInfo._secondsSinceStart = 0
                    tween.backwardsOn = not tween.backwardsOn
                    tween.tweenCount = tween.tweenCount + 1
                elseif (tween.Type == Type.LOOPING) then
                    tween.extraInfo._secondsSinceStart = 0
                    tween.tweenCount = tween.tweenCount + 1
                else
                    tween.tweenCount = tween.tweenCount + 1
                    tween.finished = true
                end
                if tween.onComplete ~= nil then
                    tween.onComplete(tween)
                    if tween.Type == Type.ONESHOT then
                        tweens[_] = nil
                    end
                end
            end
        end
    end

    if p ~= nil then p(el) end
end

return Tween