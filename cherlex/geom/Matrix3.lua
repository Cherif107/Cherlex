local Vector2 = require 'cherlex.geom.Vector2'

---@class Matrix3Value
---@field public a number
---@field public b number
---@field public c number
---@field public d number
---@field public tx number
---@field public ty number
---@class Matrix3 a Matrix3 class
--[[
    [ a, b, tx ]
	[ c, d, ty ]
	[ 0, 0,  1 ]
]]--
local Matrix3 = {}
---@return Matrix3Value
Matrix3 = {
    new = function(a, b, c, d, tx, ty)
        local this = {}
        ---@type Matrix3Value
        this = {
            a = a or 1,
            b = b or 0,
            c = c or 0,
            d = d or 1,
            tx = tx or 0,
            ty = ty or 0,

            clone = function()
                return Matrix3.new(this.a, this.b, this.c, this.d, this.tx, this.ty)
            end,
            concat = function(m3)
                local a1 = this.a*m3.a + this.b*m3.c
                this.b = this.a*m3.b + this.b*m3.d
                this.a = a1
                
                local c1 = this.c*m3.a + this.d*m3.c
                this.d = this.c*m3.b + this.d*m3.d
                this.c = c1

                local tx1 = this.tx*m3.a + this.ty*m3.c + m3.tx
                this.ty = this.tx*m3.b + this.ty*m3.d + m3.ty
                this.tx = tx1
            end,
            copyColumnFrom = function(col, vector4)
                if col > 2 then error('Column '..col..' out of bounds (2)')
                elseif col == 0 then this.a, this.b = vector4.x, vector4.y
                elseif col == 1 then this.c, this.d = vector4.x, vector4.y
                else this.tx, this.ty = vector4.x, vector4.y
                end
            end,
            copyColumnTo = function(col, vector4)
                if col > 2 then error('Column '..col..' out of bounds (2)')
                elseif col == 0 then vector4.x, vector4.y, vector4.z = this.a, this.b, 0
                elseif col == 1 then vector4.x, vector4.y, vector4.z = this.c, this.d, 0
                else vector4.x, vector4.y, vector4.z = this.tx, this.ty, 1
                end
            end,

            copyRowFrom = function(row, vector4)
                if row > 2 then error('Row '..row..' out of bounds (2)')
                elseif row == 0 then this.a, this.c, this.tx = vector4.x, vector4.y, vector4.z
                elseif row == 1 then this.b, this.d, this.ty = vector4.x, vector4.y, vector4.z
                end
            end,
            copyRowTo = function(row, vector4)
                if row > 2 then error('Row '..row..' out of bounds (2)')
                elseif row == 0 then vector4.x, vector4.y, vector4.z = this.a, this.c, this.tx
                elseif row == 1 then vector4.x, vector4.y, vector4.z = this.b, this.d, this.ty
                else vector4.setTo(0, 0, 1)
                end
            end,

            createBox = function(scaleX, scaleY, rotation, TX, TY)
                rotation, TX, TY = rotation or 0, TX or 0, TY or 0
                if rotation ~= 0 then
                    local cr, sr = math.cos(rotation), math.sin(rotation)
                    this.a, this.b = cr*scaleX, sr*scaleY
                    this.c, this.d = -sr*scaleX, cr*scaleY
                else
                    this.a, this.b = scaleX, 0
                    this.c, this.d = 0, scaleY
                end
                this.tx, this.ty = TX, TY
            end,
            createGradientBox = function(width, height, rotation, TX, TY)
                rotation, TX, TY = rotation or 0, TX or 0, TY or 0
                this.a = width / 1638.4
                this.d = height / 1638.4
                if rotation ~= 0 then
                    local cr, sr = math.cos(rotation), math.sin(rotation)
                    this.b, this.c = sr*this.d, -sr*this.a
                    this.a, this.d = this.a * cr, this.d * cr
                else
                    this.b, this.c = 0, 0
                end
                this.tx, this.ty = this.tx+width/2, this.ty+height/2
            end,
            equals = function(matrix3)
                return (matrix3~=nil and this.tx==matrix3.tx and this.ty==matrix3.ty and this.a==matrix3.a and this.b==matrix3.b and this.c==matrix3.c and this.d==matrix3.d);
            end,

            copyFrom = function(m3)
                this.a, this.b = m3.a, m3.b
                this.c, this.d = m3.c, m3.d
                this.tx, this.ty = m3.tx, m3.ty
            end,

            deltaTransformVector = function(v2, res)
                res = res or Vector2()
                res.x = v2.x*this.a+v2.y*this.c
                res.y = v2.x*this.b+v2.y*this.d
                return res
            end,
            identity = function()
                this.a, this.b, this.c, this.d, this.tx, this.ty = 1, 0, 0, 1, 0, 0
            end,
            invert = function()
                local norm = this.a*this.d-this.b*this.c 
                if norm == 0 then
                    this.a, this.b, this.c, this.d = 0, 0, 0, 0
                    this.tx, this.ty = -this.tx, -this.ty
                else
                    norm = 1/norm
                    local a1 = this.d*norm
                    this.d = this.a*norm
                    this.a = a1
                    this.b = this.b*-norm
                    this.d = this.d*-norm

                    local tx1 = -this.a*this.tx-this.c*this.ty
                    this.ty = -this.b*this.tx-this.d*this.ty
                    this.tx = tx1
                end
                return this
            end,
            rotate = function(theta)
                local ct, st = math.cos(theta), math.sin(theta)

                local a1 = this.a*ct-this.b*st
                this.b = this.a*st+this.b*ct
                this.a = a1

                local c1 = this.c*ct-this.d*st
                this.d = this.c*st+this.d*ct
                this.c = c1

                local tx1 = this.tx*ct-this.ty*st
                this.b = this.tx*st+this.ty*ct
                this.tx = tx1
            end,
            scale = function(sx, sy)
                this.a, this.b = this.a*sx, this.b*sy
                this.c, this.d = this.c*sx, this.d*sy
                this.tx, this.ty = this.tx*sx, this.ty*sy
            end,
            setRotation = function(theta, scale)
                scale = scale or 1
                this.a = math.cos(theta) * scale
                this.b = math.sin(theta) * scale
                this.c, this.d = -this.c, this.a
            end,
            setTo = function(a, b, c, d, tx, ty)
                this.a, this.b, this.c, this.d, this.tx, this.ty = a, b, c, d, tx, ty
            end,
            transformVector = function(pos, res)
                res = res or Vector2()
                res.x = pos.x*this.a+pos.y*this.c+this.tx
                res.y = pos.y*this.b+pos.y*this.d+this.ty
                return res
            end,
            translate = function(dx, dy)
                this.tx = this.tx + dx
                this.ty = this.ty + dy
            end
        }
        if Matrix3.additional ~= nil then Matrix3.additional(this) end
        return setmetatable(this, {
            __tostring = function(t)
                return 'Matrix3:\n['..t.a..', '..t.b..', '..t.tx..']\n'..'['..t.c..', '..t.d..', '..t.ty..']\n'..'[0, 0, 1]'
            end
        })
    end
}

return setmetatable(Matrix3, {__call = function(tbl, ...) return Matrix3.new(...) end})