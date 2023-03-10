local function contains(t, k)
    for i, o in pairs(t) do
        if k == i then
            return true
        end
    end
end
---@class Vector3D a vector3d class
local Vector3D = {}
Vector3D.new = function(x, y, z, w)
    local this = {}
    this = {
        w = w or 0,
        x = x or 0,
        y = y or 0,
        z = z or 0,
        add = function(vector)
            return Vector3D.new(this.x+vector.x, this.y+vector.y, this.z+vector.z)
        end,
        subtract = function(vector)
            return Vector3D.new(this.x-vector.x, this.y-vector.y, this.z-vector.z)
        end,
        clone = function()
            return Vector3D.new(this.x, this.y, this.z, this.w)
        end,
        dotProduct = function(vector)
            return this.x*vector.x + this.y*vector.y + this.z*vector.z
        end,
        angleBetween = function(vector)
            return Vector3D.angleBetween(this, vector)
        end,
        copyFrom = function(vector)
            this.x, this.y, this.z = vector.x, vector.y, vector.z
        end,
        crossProduct = function(vector)
            return Vector3D.new(this.y*vector.z - this.z * vector.y, this.x*vector.z - this.z * vector.x, this.x*vector.y - this.y * vector.x, 1)
        end,
        decrementBy = function(vector)
            this.x, this.y, this.z = this.x-vector.x, this.y-vector.y, this.z-vector.z
        end,
        incrementBy = function(vector)
            this.x, this.y, this.z = this.x+vector.x, this.y+vector.y, this.z+vector.z
        end,
        negate = function()
            this.x, this.y, this.z = -this.x, -this.y, -this.z
        end,
        project = function()
            this.x, this.y, this.z = this.x/this.w, this.y/this.w, this.z/this.w
        end,
        scaleBy = function(float)
            this.x, this.y, this.z = this.x*float, this.y*float, this.z*float
        end,
        setTo = function(xa, ya, za)
            this.x, this.y, this.z = xa, ya, za
        end,
        normalize = function()
            local l = this.length
            if l ~= 0 then
                this.x = this.x/l
                this.y = this.y/l
                this.z = this.z/l
            end
            return l
        end,
        equals = function(vector, allFour)
            return this.x == vector.x and this.y == vector.y and this.z == vector.z and (not allFour or this.w == vector.w)
        end,
        nearEquals = function(vector, tolerance, allFour)
            tolerance = tolerance or 0
            return math.abs(this.x-vector.x) < tolerance and 
                   math.abs(this.y-vector.y) < tolerance and 
                   math.abs(this.z-vector.z) < tolerance and
                   (not allFour or math.abs(this.w-vector.w) < tolerance)
        end,
    }
    local gettersnSetters = {}
    gettersnSetters = {
        length = {get = function() return gettersnSetters.lengthSquared.get()^0.5 end},
        lengthSquared = {get = function() return this.x^2+this.y^2+this.z^2 end}
    }
    return setmetatable(this, {
        __index = function(t, k)
            if contains(gettersnSetters, k) then
                return gettersnSetters[k].get()
            end
            return rawget(t, k)
        end,
        __tostring = function(t) return 'Vector3D(x: '..t.x..', y: '..t.y..', z: '..t.z..')' end
    })
end

Vector3D.X_AXIS = Vector3D.new(1, 0, 0)
Vector3D.Y_AXIS = Vector3D.new(0, 1, 0)
Vector3D.Z_AXIS = Vector3D.new(0, 0, 1)

function Vector3D.angleBetween(a, b)
    local la, lb, dot = a.length, b.length, a.dotProduct(b)
    if la ~= 0 then dot = dot / la end
    if lb ~= 0 then dot = dot / lb end
    return math.acos(dot)
end

function Vector3D.distance(a, b)
    local x, y, z = b.x-a.x, b.y-a.y, b.z-a.z
    return math.sqrt(x^2+y^2+z^2)
end

return setmetatable(Vector3D, {__call = function(t, ...) return Vector3D.new(...) end})