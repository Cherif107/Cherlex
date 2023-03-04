local Tween = require 'cherlex.tweens.root.Tween'
local util = require 'cherlex.util.StringUtil'

local function get(object, fieldString)
    local fields = util.split(fieldString, '.')
    local dis = object
    if #fields > 0 then
        for i = 1, #fields do
            dis = dis[fields[i]]
        end
    end
    return dis
end
local function set(object, fieldString, value)
    local fields = util.split(fieldString, '.')
    local restOfFields = fieldString:sub(1, #fieldString - #fields[#fields])
    get(object, restOfFields)[fields[#fields]] = value
end

local function normalizeValues(Object, Values)
    local V = {}
    for f, v in next, Values, nil do
       V[f] = {
        startValue = get(Object, f),
        range = v-get(Object, f)
       }
    end
    return V
end

---@class TweenVariable For Tweening Variables
local TweenVariable = function(Object, Values, Duration, Options)
    local this = Tween(Duration, Options, function(twn, scale, elapsed)
        for field, value in next, twn.values, nil do
            set(twn.object, field, value.startValue + value.range * scale)
        end
    end)
    this.object = Object
    this.values = normalizeValues(this.object, Values)
    this.start()
    return this
end

return TweenVariable
