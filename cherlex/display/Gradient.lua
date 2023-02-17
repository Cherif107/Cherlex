local Matrix = require 'cherlex.geom.Matrix'
local Color = require 'cherlex.util.Color'
local Angle = require 'cherlex.math.Angle'

---@class Gradient
local Gradient = {
    createGradientMatrix = function(width, height, colors, chunksize, rotation)
        chunksize, rotation = chunksize or 1, rotation or 90
        local gradientMatrix = Matrix()
        local rot = rotation*Angle.RAD
        local alpha = {}
        local ratio = {}

        gradientMatrix.createGradientBox(width, height/chunksize, rot, 0, 0)
        for c = 1, #colors do colors[c] = Color.normalize(colors[c]) end -- normalize colors
        for a = 1, #colors do alpha[a] = colors[a].alphaFloat end
        if #colors == 2 then ratio[1], ratio[2] = 0, 255 else
            local spread = math.floor(255/(#colors-1))
            table.insert(ratio, 0)
            for r = 1, #colors-1 do
                table.insert(ratio, r*spread)
            end
            table.insert(ratio, 255)
        end
        return {matrix = gradientMatrix, alpha = alpha, ratio = ratio}
    end,

}

return Gradient