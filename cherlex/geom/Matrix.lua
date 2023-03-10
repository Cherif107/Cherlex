local Matrix3 = require 'cherlex.geom.Matrix3'
local Math = require 'cherlex.math.Math'

---@class Matrix:Matrix3 Matrix3 but with some extra stuff
local Matrix = Matrix3
Matrix.additional = function(this)
    this.to3DString = function(roundPixels)
        if roundPixels then
            return 'Matrix3D('..this.a..', '..this.b..', 0, 0, '..this.c..', '..this.d..', 0, 0, 0, 0, 1, 0, '..math.floor(this.tx)..', '..math.floor(this.ty)..', 0, 1)'
        else
            return 'Matrix3D('..this.a..', '..this.b..', 0, 0, '..this.c..', '..this.d..', 0, 0, 0, 0, 1, 0, '..this.tx..', '..this.ty..', 0, 1)'
        end
    end
    this.toMozString = function()
        return 'Matrix('..this.a..', '..this.b..', '..this.c..', '..this.d..', '..this.tx..'px, '..this.ty'px)'
    end
    this.toArray = function(transpose)
        local array = {}
        array[1] = this.a
        array[2] = transpose and this.b or this.c
        array[3] = transpose and 0 or this.tx
        array[4] = transpose and this.c or this.b
        array[5] = this.d
        array[6] = transpose and this.tx or 0
        array[7] = transpose and this.ty or 0
        array[8] = 1
        return array
    end
    this.cleanValues = function()
        local function clean(x) return Math.tround(x*1000)/1000 end
        this.a, this.b = clean(this.a), clean(this.b)
        this.c, this.d = clean(this.c), clean(this.d)
        this.tx, this.ty = clean(this.tx), clean(this.ty)
    end
    this.toMatrix3 = function()
        return Matrix3(this.a, this.b, this.c, this.d, this.tx, this.ty)
    end
    this.transformX = function(px, py)
        return px*this.a+py*this.c+this.tx
    end
    this.transformY = function(px, py)
        return px*this.b+py*this.d+this.ty
    end
    this.translateTransformed = function(px, py)
        this.tx = this.transformX(px, py)
        this.ty = this.transformY(px, py)
    end
    this.transformPoint = function(point) -- math.Point
        local px, py = point.x, point.y
        point.x = this.transformX(px, py)
        point.y = this.transformY(px, py)
    end
    this.transformInverseY = function(px, py)
        local norm = this.a*this.d-this.b*this.c
        if norm == 0 then return -this.ty
        else return (1/norm) * (this.a*(py-this.ty)+this.b*(this.tx-px))
        end
    end
    this.transformInverseX = function(px, py)
        local norm = this.a*this.d-this.b*this.c
        if norm == 0 then return -this.tx
        else return (1/norm) * (this.c*(this.ty-py)+this.d*(px-this.tx))
        end
    end
    this.transformInversePoint = function(point)
        local norm = this.a*this.d-this.b*this.c
        if norm == 0 then point.x = -this.tx point.y = -this.ty
        else
            local px = (1/norm) * (this.c*(this.ty-point.y)+this.d*(point.x-this.tx))
            point.y = (1/norm) * (this.a*(point.y-this.ty)+this.b*(this.tx-point.x))
            point.x = px
        end
    end
    this.rotateWithTrig = function(sin, cos)
        local a1 = this.a*cos - this.b*sin
        this.b = this.a*sin + this.b*cos
        this.a = a1

        local c1 = this.c*cos - this.d*sin
        this.d = this.c*sin + this.d*cos
        this.c = c1

        local tx1 = this.tx*cos - this.ty*sin
        this.ty = this.tx*sin + this.ty*cos
        this.tx = tx1
        return this
    end
    this.rotateBy180 = function()
        this.setTo(-this.a, -this.b, -this.c, -this.d, -this.tx, -this.ty)
        return this
    end
    this.rotateByPositive90 = function()
        this.setTo(-this.b, this.a, -this.d, this.c, -this.ty, this.tx)
        return this
    end
    this.rotateByNegative90 = function()
        this.setTo(this.b, -this.a, this.d, -this.c, this.ty, -this.tx)
        return this
    end
end
return Matrix