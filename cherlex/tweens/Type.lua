---@class Type a tween type class (more like an enum)
local Type = {
    PERSIST = 1,
    ONESHOT = 2,
    BACKWARD = 3,
    LOOPING = 4,
    PINGPONG = 5,
}
return Type