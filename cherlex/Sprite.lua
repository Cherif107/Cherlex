 local Object = require 'cherlex.Object'
local Color = require 'cherlex.util.Color'

---@class Sprite:Object
local Sprite = Object:copy()

Sprite.field('originClass', Sprite)
Sprite.field('animated', false)
Sprite.field('frames', '?', function(t) return t.get('graphic.key') end, function(v, t) t.loadFrames(v) return v end)
Sprite.field('image', '?', function(t) return t.get('graphic.key') end, function(v, t) t.loadGraphic(v) return v end)

Sprite.new = function(path, x, y, animated)
    local this = Object.new()
    this.allowAdd = true
    this.animated = animated or false

    this._set('isNotMade', makeLuaSprite == nil)

    if not this.isNotMade then
        local func = (this.animated and makeAnimatedLuaSprite or makeLuaSprite)
        func(this.name, path, x, y)
    end
    this._set('kill', function() this.checkForWaitingField(function() removeLuaSprite(this.name, false) this.__waitingFields = {} end) end)
    this._set('destroy', function() this.checkForWaitingField(function() removeLuaSprite(this.name, true) end) this.destroyObject() end)
    this._set('add', function(onTop)
        if this.isNotMade then
            if this.animated then makeAnimatedLuaSprite(this.name, path, x, y) else makeLuaSprite(this.name, path, x, y) end
        end
        this.onAdd()
        addLuaSprite(this.name, onTop)
        this.isNotMade = false
        this.isAdded = true
    end)

    this._set('makeGraphic', function(width, height, color)
        this.checkForWaitingField(function() makeGraphic(this.name, width, height, Color(color).hex) end)
        this.animated = false
        return this
    end)
    this._set('loadGraphic', function(image)
        this.checkForWaitingField(function() loadGraphic(this.name, image) end)
        this.animated = false
        return this
    end)
    this._set('loadFrames', function(image)
        this.checkForWaitingField(function() loadFrames(this.name, image) end)
        this.animated = true
        return this
    end)
    this._set('screenCenter', function(axes)
        this.checkForWaitingField(function() screenCenter(this.name, axes) end)
    end)
    this._set('setGraphicSize', function(width, height)
        this.checkForWaitingField(function() setGraphicSize(this.name, width, height) end)
    end)

    this._set('addAnimation', function(name, frames, frameRate, loop)
        this.checkForWaitingField(function() addAnimation(this.name, name, frames, frameRate, loop) end)
    end)
    this._set('addAnimationByPrefix', function(name, prefix, frameRate, loop)
        this.checkForWaitingField(function() addAnimationByPrefix(this.name, name, prefix, frameRate, loop) end)
    end)
    this._set('addAnimationByIndices', function(name, prefix, indices, frameRate)
        this.checkForWaitingField(function() addAnimationByIndices(this.name, name, prefix, indices, frameRate) end)
    end)
    this._set('playAnim', function(name, forced, reversed, startFrame)
        this.checkForWaitingField(function() playAnim(this.name, name, forced, reversed, startFrame) end)
    end)

    this._set('animation', setmetatable({
        add = this.addAnimation,
        addByPrefix = this.addAnimationByPrefix,
        addByIndices = this.addAnimationByIndices,
        play = this.playAnim
    }, {
        __index = function (t, idx)
            if rawget(t, idx) ~= nil then return rawget(t, idx) end
            return Object(this.name..'.animation')[idx]
        end,
        __newindex = function (t, idx, v)
            Object(this.name..'.animation')[idx] = v
        end
    })) -- wawa

    return this
end

return Sprite
