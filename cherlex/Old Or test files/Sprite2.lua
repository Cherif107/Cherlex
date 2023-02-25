local Object = require 'cherlex.Object2'
local Color = require 'cherlex.util.Color'

---@class Sprite2:Object2
local Sprite = Object:copy()

Sprite.field('animated', false)
Sprite.field('frames', '?', function(t) return t.get('graphic.key') end, function(v, t) t.loadFrames(v) return v end)
Sprite.field('image', '?', function(t) return t.get('graphic.key') end, function(v, t) t.loadGraphic(v) return v end)

Sprite.new = function(tag, path, x, y, animated)
    local this = Object.new(tag)
    this.allowAdd = true
    this.animated = animated or false

    this._set('isNotMade', makeLuaSprite == nil)
    this._set('add', function(onTop)
        if this.isNotMade then
            if this.animated then makeAnimatedLuaSprite(this.name, path, x, y) else makeLuaSprite(this.name, path, x, y) end
        end
        addLuaSprite(this.name, onTop)
        this.isNotMade = false
        this.onAdd()
        this.isAdded = true
    end)

    this._set('makeGraphic', function(width, height, color)
        this.checkForWaitingField(function() makeGraphic(this.name, width, height, Color(color).hex) end)
        this.animated = false
    end)
    this._set('loadGraphic', function(image)
        this.checkForWaitingField(function() loadGraphic(this.name, image) end)
        this.animated = false
    end)
    this._set('loadFrames', function(image)
        this.checkForWaitingField(function() loadFrames(this.name, image) end)
        this.animated = true
    end)
    this._set('screenCenter', function(axes)
        this.checkForWaitingField(function() screenCenter(this.name, axes) end)
    end)
    this._set('getPixel32', function(x, y)
        return Color(getPixelColor(this.name, x, y))
    end)
    this._set('setGraphicSize', function(width, height)
        this.checkForWaitingField(function() setGraphicSize(this.name, width, height) end)
    end)

    if not this.isNotMade then
        local func = (this.animated and makeAnimatedLuaSprite or makeLuaSprite)
        func(tag, path, x, y)
    end
    return this
end

return Sprite