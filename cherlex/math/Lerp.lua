local Math = require 'cherlex.math.Math'

---@class Lerp a lerping class (useful for some cases)
local Lerp = {}
Lerp = {
    Lerpers = {},
    setStatus = function(from, to, ratio, ratioMultiplier, callback, tag)
        local this = {
            From = from or Lerp.Lerpers[tag] or 0,
            Goal = to,
            Ratio = ratio,
            Mult = ratioMultiplier or 1,
            onUpdate = callback
        }
        Lerp.Lerpers[tag or #Lerp.Lerpers] = this
        return this
    end
}

local p = onUpdate
function onUpdate(el)
    for tag, lerp in next, Lerp.Lerpers, nil do
        lerp.From = Math.lerp(lerp.From, lerp.Goal, lerp.Ratio or el * lerp.Mult)
        if lerp.onUpdate ~= nil then lerp.onUpdate(lerp.From) end
    end
    if p ~= nil then p(el) end
end

return setmetatable(Lerp, {
    __call = function(t, ...)
        return t.setStatus(...)
    end,
    __index = function(t, k)
        return rawget(t, 'Lerpers')[k]
    end
})