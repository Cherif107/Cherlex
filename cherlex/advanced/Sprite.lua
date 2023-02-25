-- local import = require 'import'
-- local Point = import 'math.Point'
-- ---@class AdvancedSprite an advanced sprite class
-- local AdvancedSprite = function(tag, path, x, y, animated)
--     local func = animated and makeAnimatedLuaSprite or makeLuaSprite
--     local this = {
--         __type = 'Sprite',
--         __animated = animated,
--         __tag = tag,
--         getters = {
--             x = function() return getProperty(tag..'.x') end,
--             y = function() return getProperty(tag..'.y') end,
--             scale = function() Point(getProperty(tag..'.scale.x'), getProperty(tag..'.scale.y')) return end,
--             origin = function() Point(getProperty(tag..'.origin.x'), getProperty(tag..'.origin.y')) return end,
--         }
--     }
-- end


-- nvm i gave up