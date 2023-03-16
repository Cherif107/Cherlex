local Sprite = require 'cherlex.Sprite'
local Math = require 'cherlex.math.Math'

return function(size, x1, y1, x2, y2, color)
    local width = Math.distance(x1, y1, x2, y2)
    local spr = Sprite('', ((x1+x2)/2-width/2), ((y1+y2)/2-size/2)).makeGraphic(width, size, color)
    spr.angle = Math.angleBetween(x1, y1, x2, y2)
    spr._set('update', function(_x1, _y1, _x2, _y2)
        local width = Math.distance(_x1, _y1, _x2, _y2)
        spr.setGraphicSize(width, spr.height)
        spr.angle = Math.angleBetween(_x1, _y1, _x2, _y2)
        spr.x, spr.y = ((_x1+_x2)/2-width/2), ((_y1+_y2)/2-spr.height/2)
        return spr
    end)  
    return spr
end