local Sprite = require 'cherlex.Sprite'
local Point = require 'cherlex.math.Point'
local Color = require 'cherlex.util.Color'

---@class Particle:Sprite
local Particle = Sprite:copy()

Particle.field('lifespan', 0)
Particle.field('age', 0)
Particle.field('percent', 0)
Particle.field('_delta', 0)
Particle.field('autoUpdateHitbox', false)
Particle.field('velocityRange', {start = Point.get(), fin = Point.get(), active = true})
Particle.field('angularVelocityRange', {start = 0, fin = 0, active = true})
Particle.field('scaleRange', {start = Point.get(1, 1), fin = Point.get(1, 1), active = true})
Particle.field('colorRange', {start = Color.WHITE, fin = Color.WHITE, active = true})
Particle.field('dragRange', {start = Point.get(), fin = Point.get(), active = true})
Particle.field('accelerationRange', {start = Point.get(), fin = Point.get(), active = true})
Particle.field('elasticityRange', {start = 0, fin = 0, active = true})
Particle.field('alphaRange', {start = 1, fin = 1, active = true})
Particle.field('onKill', function () end)

Particle.new = function(x, y)
    local this = Sprite(nil, x, y)

    local pastDestroy = this.destroy
    this.destroy = function()
        this.velocityRange = nil
        this.scaleRange = nil
        this.dragRange = nil
        this.angularVelocityRange = nil

        this.alphaRange = nil
        this.colorRange = nil
        this.accelerationRange = nil
        this.elasticityRange = nil
        this.update = nil
        pastDestroy()
    end
    this.update = function(elapsed)
        if this.age < this.lifespan then
            this.age = this.age + elapsed
        end
        
        if this.age >= this.lifespan and this.lifespan ~= 0 then
            this.kill()
            if this.onKill ~= nil and this.exists then this.onKill(this) end
        else
            this._delta = elapsed / this.lifespan
            this.percent = this.age / this.lifespan
        
            if this.velocityRange.active then
                this.velocity.x = this.velocity.x + (this.velocityRange.fin.x - this.velocityRange.start.x) * this._delta
                this.velocity.y = this.velocity.y + (this.velocityRange.fin.y - this.velocityRange.start.y) * this._delta
            end
        
            if this.angularVelocityRange.active then
                this.angularVelocity = this.angularVelocity + (this.angularVelocityRange.fin - this.angularVelocityRange.start) * this._delta
            end
        
            if this.scaleRange.active then
                this.scale.x = this.scale.x + (this.scaleRange.fin.x - this.scaleRange.start.x) * this._delta
                this.scale.y = this.scale.y + (this.scaleRange.fin.y - this.scaleRange.start.y) * this._delta
                if this.autoUpdateHitbox then
                    this.updateHitbox()
                end
            end
        
            if this.alphaRange.active then
                this.alpha = this.alpha + (this.alphaRange.fin - this.alphaRange.start) * this._delta
            end
        
            if this.colorRange.active then
                this.color = Color.interpolate(this.colorRange.start, this.colorRange.fin, this.percent)
            end
        
            if this.dragRange.active then
                this.drag.x = this.drag.x + (this.dragRange.fin.x - this.dragRange.start.x) * this._delta
                this.drag.y = this.drag.y + (this.dragRange.fin.y - this.dragRange.start.y) * this._delta
            end
        
            if this.accelerationRange.active then
                this.acceleration.x = this.acceleration.x + (this.accelerationRange.fin.x - this.accelerationRange.start.x) * this._delta
                this.acceleration.y = this.acceleration.y + (this.accelerationRange.fin.y - this.accelerationRange.start.y) * this._delta
            end
        
            if this.elasticityRange.active then
                this.elasticity = this.elasticity + (this.elasticityRange.fin - this.elasticityRange.start) * this._delta
            end
        end        
    end
    this._set('reset', function (x, y)
        this.age = 0
        this.x, this.y = x, y
    end)
    return this
end

return Particle