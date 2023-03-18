local Object = require 'cherlex.Object'
local Color = require 'cherlex.util.Color'

---@class Text:Object A Lua Text Class 
local Text = Object:copy()

Text.field('originClass', Text)
Text.field('font', 'vcr.ttf', function(t) return t.get('font') end, function(v, t) t.setTextFont(v) return v end)
Text.new = function(text, width, x, y, size, color, font)
    local this = Object.new()
    this.allowAdd = true

    local function tuna()
        makeLuaText(this.name, text, width, x, y)
        if size ~= nil then this.size = size end
        if color ~= nil then this.setTextColor(color) end
        if font ~= nil then this.font = font end
    end
    this._set('kill', function() this.checkForWaitingField(function() removeLuaText(this.name, false) end) end)
    this._set('destroy', function() this.checkForWaitingField(function() removeLuaText(this.name, true) end) this.destroyObject() end)
    this._set('isNotMade', makeLuaText == nil)
    this._set('add', function(onTop)
        if this.isNotMade then tuna() end
        addLuaText(this.name, onTop)
        this.isNotMade = false
        this.onAdd()
        this.isAdded = true
    end)
    this._set('setTextFont', function(font)
        return this.checkForWaitingField(function() setTextFont(this.name, font) end)
    end)
    this._set('setTextColor', function(color)
        return this.checkForWaitingField(function() setTextColor(this.name, Color(color).hex) end)
    end)
    this._set('screenCenter', function(axes)
        return this.checkForWaitingField(function() screenCenter(this.name, axes) end)
    end)
    this._set('getPixel32', function(x, y)
        return Color(getPixelColor(this.name, x, y))
    end)
    this._set('setGraphicSize', function(width, height)
        this.checkForWaitingField(function() setGraphicSize(this.name, width, height) end)
    end)
    if not this.isNotMade then tuna() end
    return this
end
return Text