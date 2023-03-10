local Pool = require 'cherlex.util.Pool'
local Math = require 'cherlex.math.Math'
local Angle = require 'cherlex.math.Angle'
local Class = require 'cherlex.class'

---@class Point a Point Class
local Point = Class()

Point.pool = Pool(Point)
Point.allowPool = true

Point.get = function(x, y)
    if Point.allowPool then
        local point = Point.pool.get().set(x or 0, y or 0)
        point._inPool = false
        return point
    end
    return Point(x or 0, y or 0)
end
Point.weak = function(x, y)
    local point = Point.get(x, y)
    if Point.allowPool then
        point._weak = true
    end
    return point
end

Point.field('_inPool', false)
Point.field('_weak', false)
Point.field('x', 0, nil, function(v, t) if t.onSetX ~= nil then t.onSetX(v) end return v end)
Point.field('y', 0, nil, function(v, t) if t.onSetY ~= nil then t.onSetY(v) end return v end)


Point.field('rx', 0, function(t) return -t.y end)
Point.field('ry', 0, function(t) return t.x end)

Point.field('lx', 0, function(t) return t.y end)
Point.field('ly', 0, function(t) return -t.x end)

Point.field('dx', 0, function(t) return (t.isZero() and 0 or t.x/t.length) end)
Point.field('dy', 0, function(t) return (t.isZero() and 0 or t.y/t.length) end)

Point.field('radians', 0, function(this) return Angle.angleFromOrigin(this.x, this.y, false) end, function(v, this)
    local len = this.length
    this.x = len*math.cos(v)
    this.y = len*math.sin(v)
    return v
end)
Point.field('degrees', 0, function(this) return this.radians*Angle.DEG end, function(v, this) this.radians = v*Angle.DEG end)

Point.field('lengthSquared', 0, function(this) return this.x^2+this.y^2 end)
Point.field('length', 0, function(t) return math.sqrt(t.lengthSquared) end, function(v, this)
    if not this.isZero() then
        local a = this.radians
        this.x = v*math.cos(a)
        this.y = v*math.sin(a)
    end
    return v
end)

Point.field('type', 'Point', nil, 'never')

Point.new = function(x, y)
    x = x or 0
    y = y or 0
    local this = Point.create()
    this.set = function(x, y)
        this.x = x
        this.y = y
        return this
    end
    this.set(x, y)

    this.put = function()
        if Point.allowPool then
            if not this._inPool then
                this._inPool = true
                this._weak = false
                Point.pool.putUnsafe(this)
            end
        end
    end
    this.putWeak = function() if this._weak then this.put() end end
    this.equals = function(point)
        local res = Math.equals(this.x, point.x) and Math.equals(this.y, point.y)
        point.putWeak()
        return res
    end
    this.add = function(x, y)
        this.x = this.x + x
        this.y = this.y + y
        return this
    end
    this.substract = function(x, y)
        this.x = this.x - x
        this.y = this.y - y
        return this
    end
    this.scale = function(x, y)
        y = y or x
        this.x = this.x * x
        this.y = this.y * y
        return this
    end
    this.addPoint = function(point)
        this.add(point.x, point.y)
        point.putWeak()
        return this
    end
    this.substractPoint = function(point)
        this.substract(point.x, point.y)
        point.putWeak()
        return this
    end
    this.scalePoint = function(point)
        this.scale(point.x, point.y)
        point.putWeak()
        return this
    end
    this.addNew = function(point)
        return this.clone().addPoint(point)
    end
    this.substractNew = function(point)
        return this.clone().substractPoint(point)
    end
    this.scaleNew = function(point)
        return this.clone().scalePoint(point)
    end
    this.copyFrom = function(point)
        this.set(point.x, point.y)
        point.putWeak()
        return this
    end
    this.copyTo = function(point)
        point = point or Point.get()
        return point.set(this.x, this.y)
    end
    this.clone = function(p)
        return this.copyTo(p)
    end
    this.isZero = function()
        return math.abs(this.x) < Math.EPSILON and math.abs(this.y) < Math.EPSILON
    end
    this.zero = function()
        this.x = 0
        this.y = 0
        return this
    end
    this.normalize = function()
        if this.isZero() then
            return this
        end
        return this.scale(1/this.length)
    end
    this.isNormalized = function()
        return math.abs(this.lengthSquared-1) < Math.EPSILON^2
    end

    this.floor = function()
        this.x = math.floor(this.x)
        this.y = math.floor(this.y)
        return this
    end
    this.ceil = function()
        this.x = math.ceil(this.x)
        this.y = math.ceil(this.y)
        return this
    end
    this.round = function()
        this.x = Math.tround(this.x)
        this.y = Math.tround(this.y)
        return this
    end

    this.inCoords = function(x, y, width, height)
        return Math.pointInCoords(this.x, this.y, x, y, width, height)
    end
    this.inObject = function(Object)
        return Math.pointInObject(this.x, this.y, Object)
    end

    this.rotateByRadians = function(rads)
        local s, c = math.sin(rads), math.cos(rads)
        local sx = this.x

        this.x = sx*c-this.y*s
        this.y = sx*s+this.y*c

        return this
    end
    this.rotateByDegrees = function(degs)
        return this.rotateByRadians(degs * Angle.RAD)
    end
    this.rotateWithTrig = function(sin, cos)
        local tx = this.x 
        this.x = tx*cos - this.y*sin
        this.y = tx*sin + this.y*cos
        return this
    end

    this.setPolarRadians = function(length, radians)
        this.x = length * math.cos(radians)
        this.y = length * math.sin(radians)
        return this
    end
    this.setPolarDegrees = function(length, degrees)
        return this.setPolarRadians(length, degrees*Angle.RAD)
    end

    this.rightNormal = function(point)
        point = point or Point.get()
        point.set(-this.y, this.x)
        return this
    end
    this.leftNormal = function(point)
        point = point or Point.get()
        point.set(this.y, -this.x)
        return this
    end

    this.negate = function()
        this.x = this.x*-1
        this.y = this.y*-1
        return this
    end
    this.negateNew = function()
        return this.clone().negate()
    end
    this.projectTo = function(p, proj)
        local dp = this.dotProductWeak(p)
        local ls = p.lengthSquared
        proj = proj or Point.get()
        proj.set(dp * p.x / ls, dp * p.y / ls)
        p.putWeak()
        return proj
    end
    this.projectToNormalizedWeak = function(p, proj)
        local dp = this.dotProductWeak(p)
        proj = proj or Point.get()
        return proj.set(dp*p.x, dp*p.y)
    end
    this.projectToNormalized = function(p, proj)
        proj = this.projectToNormalizedWeak(p, proj)
        proj.putWeak()
        return proj
    end

    this.perpProductWeak = function(p)
        return this.lx*p.x+this.ly*p.y
    end
    this.perpProduct = function(p)
        local ghost = this.perpProductWeak(p)
        p.putWeak()
        return ghost
    end

    this.ratioWeak = function(a, b, p)
        if this.isParallelWeak(p) then
            return Math.NaN
        end
        if (this.lengthSquared < Math.EPSILON^2 or p.lengthSquared < Math.EPSILON^2) then
            return Math.NaN
        end
        Point._point1 = b.clone(Point._point1)
        Point._point1.subtract(a.x, a.y)
        return Point._point1.perpProductWeak(p)/this.perpProductWeak(p)
    end
    this.ratio = function(a, b, p)
        local ratio = this.ratioWeak(a, b, p)
        a.putWeak()
        b.putWeak()
        p.putWeak()
        return ratio
    end

    this.findIntersection = function(a, b, p, i)
        local t = this.ratioWeak(a, b, p)
        i = i or Point.get()
        if Math.isNaN(t) then
            i.set(Math.NaN, Math.NaN)
        else
            i.set(a.x+t*this.x, a.y+t*this.y)
        end
        a.putWeak()
        b.putWeak()
        p.putWeak()
        return i
    end
    this.findIntersectionInBounds = function(a, b, p, i)
        i = i or Point.get()
        local t1 = this.ratioWeak(a, b, p)
        local t2 = p.ratioWeak(b, a, this)
        if (not Math.isNaN(t1) and not Math.isNaN(t2) and t1 > 0 and t1 <= 1 and t2 > 0 and t2 <= 1) then
            i.set(a.x+t1*this.x, a.y+t1*this.y)
        else
            i.set(Math.NaN, Math.NaN)
        end
        a.putWeak()
        b.putWeak()
        p.putWeak()
        return i
    end

    this.truncate = function(max)
        this.length = math.min(max, this.length)
        return this
    end
    this.radiansBetween = function(point)
        local rads = math.acos(this.dotProductWeak(point)/(this.length*point.length))
        point.putWeak()
        return rads
    end
    this.degreesBetween = function(point)
        return this.radiansBetween(point)*Angle.DEG
    end

    this.sign = function(a, b)
        local signF1 = (a.x-this.x)*(b.y-this.y)-(a.y-this.y)*(b.x-this.x)
        a.putWeak()
        b.putWeak()
        return (signF1 == 0 and 0 or Math.tround(signF1/math.abs(signF1)))
    end

    this.distSquared = function(p)
        local dx, dy = p.x - this.x, p.y - this.y
        p.putWeak()
        return dx^2+dy^2
    end
    this.dist = function(p)
        return this.distSquared(p)^0.5
    end

    this.bounce = function(normal, bounceCeOff)
        local d = (1+(bounceCeOff or 1))*this.dotProductWeak(normal)
        this.x = this.x - d*normal.x
        this.y = this.y - d*normal.y
        normal.putWeak()
        return this
    end
    this.bounceWithFriction = function(normal, bounceCeOff, friction)
        bounceCeOff, friction = bounceCeOff or 1, friction or 0
        local p1 = this.projectToNormalizedWeak(normal.rightNormal(Point._point3), Point._point1)
        local p2 = this.projectToNormalizedWeak(normal, Point._point2)
        local BX, BY = -p2.x, -p2.y
        local FX, FY = p1.x, p1.y
        this.x = BX*bounceCeOff+FX*friction
        this.y = BY*bounceCeOff+FY*friction
        normal.putWeak()
        return this
    end
    this.isValid = function()
        return (not Math.NaN(this.x) and not Math.NaN(this.y) and Math.isFinite(this.x) and Math.isFinite(this.y))
    end
    this.pivotRadians = function(pivot, radians)
        Point._point1.copyFrom(pivot).substractPoint(this)
        Point._point1.radians = Point._point1.radians * radians
        this.set(Point._point1.x + pivot.x, Point._point1.y + pivot.y)
        pivot.putWeak()
        return this
    end
    this.pivotDegrees = function(pivot, degrees)
        return this.pivotRadians(pivot, math.rad(degrees))
    end

    this.distanceTo = function(point)
        local dx, dy = this.x-point.x, this.y-point.y
        point.putWeak()
        return Math.vectorLength(dx, dy)
    end
    this.radiansTo = function(point)
        return Angle.angleFromOrigin(point.x-this.x, point.y-this.y, false)
    end
    this.degreesTo = function(point)
        return Angle.angleFromOrigin(point.x-this.x, point.y-this.y, true)
    end

    this.radiansFrom = function(point)
        return point.radiansTo(this)
    end
    this.degreesFrom = function(point)
        return point.degreesTo(this)
    end

    this.dotProductWeak = function(point)
        return this.x*point.x+this.y*point.y
    end
    this.dotProduct = function(point)
        local ret = this.dotProductWeak(point)
        point.putWeak()
        return ret
    end
    this.dotProductWithNormalizing = function(point)
        local n = point.clone(Point._point1).normalize()
        point.putWeak()
        return this.dotProductWeak(n)
    end
    this.dot = this.dotProduct
    this.isPerpendicular = function(p)
        return math.abs(this.dotProduct(p)) < Math.EPSILON^2
    end
    this.crossProductLengthWeak = function(p)
        return this.x * p.y - this.y * p.x
    end
    this.crossProductLength = function(p)
        local c = this.crossProductLengthWeak(p)
        p.putWeak()
        return c
    end
    this.isParallelWeak = function(p)
        return math.abs(this.crossProductLengthWeak(p)) < Math.EPSILON^2
    end
    this.isParallel = function(p)
        local c = this.isParallelWeak(p)
        p.putWeak()
        return c
    end
    return this
end

for i = 1, 3 do
    ---@type Point
    Point['_point'..i] = Point()
end
Point.instance.__add = function(this, point)
    local res = Point.get(this.x + point.x, this.y + point.y)
    this.putWeak()
    point.putWeak()
    return res
end
Point.instance.__sub = function(this, point)
    local res = Point.get(this.x - point.x, this.y - point.y)
    this.putWeak()
    point.putWeak()
    return res
end
Point.instance.__mul = function(this, float)
    local res = Point.get(this.x * float, this.y * float)
    this.putWeak()
    return res
end
Point.instance.__div = function(this, float)
    local res = Point.get(this.x / float, this.y / float)
    this.putWeak()
    return res
end
Point.instance.__tostring = function(this)
    return '(x: '..this.x..' | y: '..this.y..')'
end

return Point