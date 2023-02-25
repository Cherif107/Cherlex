local Object = require 'cherlex.Object'
---@class Mouse:Object yes
local Mouse = Object(true, 'flixel.FlxG', false, false, 'mouse')
Mouse._set('getPosition', function(result)
    local Point = require 'cherlex.math.Point'
    result = result or Point.get()
    return result.set(Mouse.x, Mouse.y)
end)
Mouse._set('overlaps', function(object, camera)
    return object.overlapsPoint(Mouse.getPosition(), true, camera)
end)

return Mouse