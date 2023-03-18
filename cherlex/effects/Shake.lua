local Class = require 'cherlex.Class'
local Stage = require 'cherlex.Event'

---@class Shake:Class
local Shake = Class('Shake')

Shake.shakers = {}
Shake.new = function(Object, intensity, duration, onComplete, axes)
    local this = Shake.create()
    this._time = 0
    this.axes = string.upper(axes or 'xy')
    this.intensity = intensity or 5
    this.duration = duration or 0.5
    this.onComplete = onComplete
    this.object = Object

    this.start = function(force)
        if not force and this._time > 0 then
            return
        end
        this.reset(this.intensity, this.duration, this.onComplete, this.axes)
    end
    this.reset = function(intensity, duration, onComplete, axes)
        this.intensity = intensity or 5
        this.duration = duration or 0.5
        this.onComplete = onComplete
        this.axes = string.upper(axes or 'xy')
        this._time = this.duration
        this.offsets = {
            x = this.object.x,
            y = this.object.y
        }
    end
    table.insert(Shake.shakers, this)
    return this
end
Shake.update = function(el)
    for i = 1, #Shake.shakers do
        local this = Shake.shakers[i]
        if this then
            if this._time <= 0 then
                return
            end

            this._time = this._time - el
            if this._time > 0 then
                if this.axes ~= 'Y' then
                    this.object.offset.x = math.random(-this.intensity, this.intensity)
                end
                if this.axes ~= 'X' then
                    this.object.offset.y = math.random(-this.intensity, this.intensity)
                end
            else
                this.object.offset.x = 0
                this.object.offset.y = 0
                if this.onComplete ~= nil then
                    this.onComplete(this)
                end
                if Shake.shakers[i] == this then
                    Shake.shakers[i] = nil
                end
            end
        end
    end 
end

return Shake