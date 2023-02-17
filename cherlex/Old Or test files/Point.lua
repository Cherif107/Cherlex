local Pool = require 'cherlex.util.Pool'
local Math = require 'cherlex.math.Math'
local Angle = require 'cherlex.math.Angle'
local StaticStorage = require 'cherlex.util.Static'

---@class PointOLD a point Class
local Point = {}

local function contains(t, k)
    for i, o in pairs(t) do
        if k == i then
            return true
        end
    end
end

function Point:new(X, Y)
    local this = {}
    this = {
        __type = 'Point',
        x = X or 0,
        y = Y or 0,

        staticPoints = StaticStorage(Point.new, {'point1', 'point2', 'point3'}),
        
        _pool = Pool(Point.new),
        _inPool = false,

        _weak = false,

        get = function(x, y)
            return Point.get(this, x, y)
        end,
        set = function(x, y)
            return Point.set(this, x, y)
        end,
        weak = function(x, y)
            return Point.weak(this, x, y)
        end,
        put = function()
            Point.put(this)
        end,
        putWeak = function()
            Point.putWeak(this)
        end,
        equals = function(point)
            return Point.equals(this, point)
        end,
        add = function(x, y)
            this.x = this.x + x
            this.y = this.y + y
            return this
        end,
        substract = function(x, y)
            this.x = this.x - x
            this.y = this.y - y
            return this
        end,
        scale = function(x, y)
            y = y or x
            this.x = this.x * x
            this.y = this.y * y
            return this
        end,
        
        addPoint = function(point)
            this.add(point.x, point.y)
            point.putWeak()
            return this
        end,
        substractPoint = function(point)
            this.substract(point.x, point.y)
            point.putWeak()
            return this
        end,
        scalePoint = function(point)
            this.scale(point.x, point.y)
            point.putWeak()
            return this
        end,

        addNew = function(point)
            return this.clone().addPoint(point)
        end,
        substractNew = function(point)
            return this.clone().substractPoint(point)
        end,
        scaleNew = function(point)
            return this.clone().scalePoint(point)
        end,

        copyFrom = function(point)
            this.set(point.x, point.y)
            point.putWeak()
            return this
        end,
        copyTo = function(point)
            point = point or this.get()
            return point.set(this.x, this.y)
        end,

        clone = function(p)
            return this.copyTo(p)
        end,

        isZero = function()
            return math.abs(this.x) < Math.EPSILON and math.abs(this.y) < Math.EPSILON
        end,
        zero = function()
            this.x = 0
            this.y = 0
            return this
        end,

        normalize = function()
            if this.isZero() then
                return this
            end
            return this.scale(1/this.length)
        end,
        isNormalized = function()
            return math.abs(this.lengthSquared-1) < Math.EPSILON^2
        end,

        floor = function()
            this.x = math.floor(this.x)
            this.y = math.floor(this.y)
            return this
        end,
        ceil = function()
            this.x = math.ceil(this.x)
            this.y = math.ceil(this.y)
            return this
        end,
        round = function()
            this.x = Math.tround(this.x)
            this.y = Math.tround(this.y)
            return this
        end,

        inCoords = function(x, y, width, height)
            return Math.pointInCoords(this.x, this.y, x, y, width, height)
        end,
        inObject = function(Object)
            return Math.pointInObject(this.x, this.y, Object)
        end,

        rotateByRadians = function(rads)
            local s, c = math.sin(rads), math.cos(rads)
            local sx = this.x

            this.x = sx*c-this.y*s
            this.y = sx*s+this.y*c

            return this
        end,
        rotateByDegrees = function(degs)
            return this.rotateByRadians(degs * Angle.RAD)
        end,
        rotateWithTrig = function(sin, cos)
            local tx = this.x 
            this.x = tx*cos - this.y*sin
            this.y = tx*sin + this.y*cos
            return this
        end,

        setPolarRadians = function(length, radians)
            this.x = length * math.cos(radians)
            this.y = length * math.sin(radians)
            return this
        end,
        setPolarDegrees = function(length, degrees)
            return this.setPolarRadians(length, degrees*Angle.RAD)
        end,

        rightNormal = function(point)
            point = point or this.get()
            point.set(-this.y, this.x)
            return this
        end,
        leftNormal = function(point)
            point = point or this.get()
            point.set(this.y, -this.x)
            return this
        end,

        negate = function()
            this.x = this.x*-1
            this.y = this.y*-1
            return this
        end,
        negateNew = function()
            return this.clone().negate()
        end,

        projectTo = function(p, proj)
            local dp = this.dotProductWeak(p)
            local ls = p.lengthSquared
            proj = proj or this.get()
            proj.set(dp * p.x / ls, dp * p.y / ls)
            p.putWeak()
            return proj
        end,
        projectToNormalizedWeak = function(p, proj)
            local dp = this.dotProductWeak(p)
            proj = proj or this.get()
            return proj.set(dp*p.x, dp*p.y)
        end,
        projectToNormalized = function(p, proj)
            proj = this.projectToNormalizedWeak(p, proj)
            proj.putWeak()
            return proj
        end,

        perpProductWeak = function(p)
            return this.lx*p.x+this.ly*p.y
        end,
        perpProduct = function(p)
            local ghost = this.perpProductWeak(p)
            p.putWeak()
            return ghost
        end,

        ratioWeak = function(a, b, p)
            if this.isParallelWeak(p) then
                return Math.NaN
            end
            if (this.lengthSquared < Math.EPSILON^2 or p.lengthSquared < Math.EPSILON^2) then
                return Math.NaN
            end
            this._point1 = b.clone(this._point1)
            this._point1.subtract(a.x, a.y)
            return this._point1.perpProductWeak(p)/this.perpProductWeak(p)
        end,
        ratio = function(a, b, p)
            local ratio = this.ratioWeak(a, b, p)
            a.putWeak()
            b.putWeak()
            p.putWeak()
            return ratio
        end,

        findIntersection = function(a, b, p, i)
            local t = this.ratioWeak(a, b, p)
            i = i or this.get()
            if Math.isNaN(t) then
                i.set(Math.NaN, Math.NaN)
            else
                i.set(a.x+t*this.x, a.y+t*this.y)
            end
            a.putWeak()
            b.putWeak()
            p.putWeak()
            return i
        end,
        findIntersectionInBounds = function(a, b, p, i)
            i = i or this.get()
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
        end,

        truncate = function(max)
            this.length = math.min(max, this.length)
            return this
        end,

        radiansBetween = function(point)
            local rads = math.acos(this.dotProductWeak(point)/(this.length*point.length))
            point.putWeak()
            return rads
        end,
        degreesBetween = function(point)
            return this.radiansBetween(point)*Angle.DEG
        end,

        sign = function(a, b)
            local signF1 = (a.x-this.x)*(b.y-this.y)-(a.y-this.y)*(b.x-this.x)
            a.putWeak()
            b.putWeak()
            return (signF1 == 0 and 0 or Math.tround(signF1/math.abs(signF1)))
        end,

        distSquared = function(p)
            local dx, dy = p.x - this.x, p.y - this.y
            p.putWeak()
            return dx^2+dy^2
        end,
        dist = function(p)
            return this.distSquared(p)^0.5
        end,

        bounce = function(normal, bounceCeOff)
            local d = (1+(bounceCeOff or 1))*this.dotProductWeak(normal)
            this.x = this.x - d*normal.x
            this.y = this.y - d*normal.y
            normal.putWeak()
            return
        end,
        bounceWithFriction = function(normal, bounceCeOff, friction)
            bounceCeOff, friction = bounceCeOff or 1, friction or 0
            local p1 = this.projectToNormalizedWeak(normal.rightNormal(this._point3), this._point1)
            local p2 = this.projectToNormalizedWeak(normal, this._point2)
            local BX, BY = -p2.x, -p2.y
            local FX, FY = p1.x, p1.y
            this.x = BX*bounceCeOff+FX*friction
            this.y = BY*bounceCeOff+FY*friction
            normal.putWeak()
            return this
        end,
        
        isValid = function()
            return (not Math.NaN(this.x) and not Math.NaN(this.y) and Math.isFinite(this.x) and Math.isFinite(this.y))
        end,

        pivotRadians = function(pivot, radians)
            this._point1.copyFrom(pivot).substractPoint(this)
            this._point1.radians = this._point1.radians * radians
            this.set(this._point1.x + pivot.x, this._point1.y + pivot.y)
            pivot.putWeak()
            return this
        end,
        pivotDegrees = function(pivot, degrees)
            return this.pivotRadians(pivot, math.rad(degrees))
        end,

        distanceTo = function(point)
            local dx, dy = this.x-point.x, this.y-point.y
            point.putWeak()
            return Math.vectorLength(dx, dy)
        end,
        radiansTo = function(point)
            return Angle.angleFromOrigin(point.x-this.x, point.y-this.y, false)
        end,
        degreesTo = function(point)
            return Angle.angleFromOrigin(point.x-this.x, point.y-this.y, true)
        end,

        radiansFrom = function(point)
            return point.radiansTo(this)
        end,
        degreesFrom = function(point)
            return point.degreesTo(this)
        end,

        dotProductWeak = function(point)
            return this.x*point.x+this.y*point.y
        end,
        dotProduct = function(point)
            local ret = this.dotProductWeak(point)
            point.putWeak()
            return ret
        end,
        dotProductWithNormalizing = function(point)
            local n = point.clone(this._point1).normalize()
            point.putWeak()
            return this.dotProductWeak(n)
        end,
        dot = this.dotProduct,
        isPerpendicular = function(p)
            return math.abs(this.dotProduct(p)) < Math.EPSILON^2
        end,
        crossProductLengthWeak = function(p)
            return this.x * p.y - this.y * p.x
        end,
        crossProductLength = function(p)
            local c = this.crossProductLengthWeak(p)
            p.putWeak()
            return c
        end,
        isParallelWeak = function(p)
            return math.abs(this.crossProductLengthWeak(p)) < Math.EPSILON^2
        end,
        isParallel = function(p)
            local c = this.isParallelWeak(p)
            p.putWeak()
            return c
        end,
    }
    local specialFields = {}
    specialFields = {
        length = {
            get = function() return math.sqrt(specialFields.lengthSquared.get()) end,
            set = function(v)
                if not this.isZero() then
                    local a = this.radians
                    this.x = v*math.cos(a)
                    this.y = v*math.sin(a)
                end
                return v
            end,
        },
        lengthSquared = {
            get = function() return this.x^2+this.y^2 end
        },
        _point1 = {
            get = function() return this.staticPoints.point1:init() end
        },
        _point2 = {
            get = function() return this.staticPoints.point2:init() end
        },
        _point3 = {
            get = function() return this.staticPoints.point3:init() end
        },
        degrees = {
            get = function() return this.radians*Angle.DEG end,
            set = function(v) this.radians = v*Angle.DEG return v end,
        },
        radians = {
            get = function() return Angle.angleFromOrigin(this.x, this.y, false) end,
            set = function(v)
                local len = this.length
                this.x = len*math.cos(v)
                this.y = len*math.sin(v)
                return v
            end,
        },
        rx = { get = function() return -this.y end},
        ry = { get = function() return this.x end},

        lx = { get = function() return this.y end},
        ly = { get = function() return -this.x end},

        dx = { get = function() return (this.isZero() and 0 or this.x/this.length) end },
        dy = { get = function() return (this.isZero() and 0 or this.y/this.length) end },
    }
    return setmetatable(this, {
        __index = function(tbl, k)
            if contains(specialFields, k) then
                return specialFields[k].get()
            end
            return rawget(tbl, k)
        end,
        __newindex = function(tbl, k, v)
            if contains(specialFields, k) then
                if specialFields[k].set ~= nil then
                    specialFields[k].set(v)
                    return
                end
            end
            rawset(tbl, k, v)
        end,
        __add = function(tbl, tbl2)
            local res = Point.get(tbl, tbl.x + tbl2.x, tbl.y + tbl2.y)
            tbl.putWeak()
            tbl2.putWeak()
            return res
        end,
        __sub = function(tbl, tbl2)
            local res = Point.get(tbl, tbl.x - tbl2.x, tbl.y - tbl2.y)
            tbl.putWeak()
            tbl2.putWeak()
            return res
        end,
        __mul = function(tbl, float)
            local res = Point.get(tbl, tbl.x * float, tbl.y * float)
            tbl.putWeak()
            return res
        end,
        __div = function(tbl, float)
            local res = Point.get(tbl, tbl.x / float, tbl.y / float)
            tbl.putWeak()
            return res
        end,
        __tostring = function(tbl)
            return Point.stringify(tbl)
        end
    })
end

function Point.set(point, x, y)
    point = point or Point.new(x, y)
    point.x, point.y = x, y
    return point
end

function Point.get(point, x, y)
    x, y = x or 0, y or 0
    point = point or Point.new(x, y)
    
    local p = point._pool.get().set(x, y)
    p._inPool = false
    return p
end

function Point.weak(point, x, y)
    x, y = x or 0, y or 0
    
    local p = point.get(x, y)
    p._weak = true
    return p
end

function Point.put(point)
    if not point._inPool then
        point._inPool = true
        point._weak = false
        point._pool.putUnsafe(point)
    end
end

function Point.putWeak(point)
    if point._weak then point.put() end
end

function Point.equals(point1, point2)
    local res = Math.equals(point1.x, point2.x) and Math.equals(point1.y, point2.y)
    point2.putWeak()
    return res
end

function Point.stringify(P)
    return '(x: '..P.x..' | y: '..P.y..')'
end

return setmetatable(Point, {__call = Point.new})