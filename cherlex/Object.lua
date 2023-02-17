local Class = require 'cherlex.Class'
local StringUtil = require 'cherlex.util.StringUtil'
local Color = require 'cherlex.util.Color'
local File  = require 'cherlex.util.File'

---@class Object:Class An Object Class For Property Parsing
local Object = Class()

---@param object Object|string
---@param key string
Object.parseObjectString = function(object, key)
    if object == '' then return key end
    if key == '' then return object end
    if type(object) == "table" then object = object.__name end
    if type(key) == 'number' then
        return object..'['..key..']'
    end
    return object..'.'..key
end
Object.checkForWaitingField = function(t, func)
    if makeLuaSprite == nil or (not t.isAdded and t.allowAdd) then
        table.insert(t.__waitingFields, func)
    else
        return func()
    end
end

Object.instance.__newindex = function(t, k, v)
    if Object.__statics[k] ~= nil and rawget(t, '_')[k] == nil and Object.__objectFields.__setters[k] == nil then
        error('Cannot Access Static Field ('..k..') from a Class instance')
    else
        if Object.__objectFields.__setters[k] ~= nil then
            local x = Object.__objectFields.__setters[k](v, t)
            if x ~= nil then rawget(t, '_')[k] = x end
        else
            if Object.__objectFields.__onInit[k] ~= nil then
                rawget(t, '_')[k] = v
            else
                rawget(t, 'set')(k, v)
            end
        end
    end
end
Object.instance.__index = function(t, k)
    if Object.__statics[k] ~= nil and rawget(t, '_')[k] == nil and Object.__objectFields.__getters[k] == nil then
        error('Cannot Access Static Field ('..k..') from a Class instance')
    else
        if Object.__objectFields.__getters[k] ~= nil then
            return Object.__objectFields.__getters[k](t)
        end
        if Object.__objectFields.__onInit[k] ~= nil then
            return rawget(t, '_')[k]
        end
        if rawget(t, 'get')(k) == Object.parseObjectString(t.name, k) then
            return Object(Object.parseObjectString(t.name, k), t.classObject, t.classLibrary, t.fromPlayState)
        else
            return rawget(t, 'get')(k)
        end
    end
end

Object.field('name', 'boyfriend')
Object.field('classObject', false)
Object.field('fromPlayState', false)
Object.field('classLibrary', '')

Object.field('isAdded', false)
Object.field('allowAdd', false)
Object.field('__waitingFields', {})

Object.field('camera', 'camGame', nil, function(v, t) t.checkForWaitingField(function() setObjectCamera(t.name, v) end) return v end)
Object.field('color', Color.WHITE, function(t) return Color(rawget(t, 'get')('color')) end, function(v, t) t.checkForWaitingField(function() rawget(t, 'set')('color', Color.parseColor(v)) end) return v end)
Object.field('blend', 'NORMAL', nil, function(v, t) t.checkForWaitingField(function() setBlendMode(t.name, v) end) return v end)

---@return Object
Object.new = function(Name, ClassObject, ClassLibrary, fromPlayState)
    ---@type Object
    local this = Object.create()
    this.name = Name or 'boyfriend'
    this.classObject = ClassObject
    this.classLibrary = ClassLibrary
    this.fromPlayState = fromPlayState or false

    rawset(this, '_set', function(k, v) rawset(this, k, v) end)
    rawset(this, '_get', function(k) return rawget(this, k) end)
    this._set('set', function(key, v)
        if this.classObject then
            setPropertyFromClass(this.classLibrary, Object.parseObjectString(this.name, key), v)
        else
            setProperty(Object.parseObjectString(this.name, key), v)
        end
    end)
    this._set('get', function(key)
        if this.classObject then
            return getPropertyFromClass(this.classLibrary, Object.parseObjectString(this.name, key))
        end
        return getProperty(Object.parseObjectString(this.name, key))
    end)
    this._set('checkForWaitingField', function(func) return Object.checkForWaitingField(this, func) end)
    this._set('onAdd', function()
        for i = 1, #this.__waitingFields do
            this.__waitingFields[i]()
        end
        this.__waitingFields = {}
    end)
    this._set('getScreenPosition', function (result, camera)
        local Point = require 'cherlex.math.Point'
        local Game = require 'cherlex.Game'
        result = result or Point.get()
        camera = camera or Game.camera
        if type(camera) == 'string' then camera = Game[camera] end
        result.set(this.x, this.y)
        return result.substract(camera.scroll.x*this.scrollFactor.x, camera.scroll.y*this.scrollFactor.y)
    end)
    this._set('overlaps', function(object) return objectsOverlap(this.__name, type(object) == 'table' and object.__name or object) end)
    this._set('overlapsPoint', function(point, inScreenSpace, camera)
        local Point = require 'cherlex.math.Point'
        local Game = require 'cherlex.Game'
        if not inScreenSpace then
            return (point.x >= this.x and (point.x < this.x + this.width) and (point.y >= this.y) and (point.y < this.y+this.height))
        end
        camera = camera or Game.camera
        if type(camera) == 'string' then camera = Game[camera] end

        local x = point.x - camera.scroll.x
        local y = point.y - camera.scroll.y

        local _point = Point.get()
        this.getScreenPosition(_point, camera)
        point.putWeak()
        return (x >= _point.x and (x < _point.x + this.width) and (y >= _point.y) and (y < _point.y+this.height))
    end)

    this._set('objectScreenCenter', function(axes)
        axes = axes or 'XY'
        if axes == 'X' or axes == 'XY' then this.x = (screenWidth-this.width)/2 end
        if axes == 'Y' or axes == 'XY' then this.y = (screenHeight-this.height)/2 end
    end)
    this._set('updateHitbox', function(axes)
        updateHitbox(this.__name)
    end)

    this._set('getPixel32', function(x, y)
        return Color(getPixelColor(this.name, x, y))
    end)

    --- [[ HSCRIPT ]] --
    local jsonTable = StringUtil.json(File.getContent('cherlex.json'))
    if jsonTable.hscript then
        local function tuna(t)
            t = t or this
            return t.fromPlayState and 'game.'..t.name or 'game.getLuaObject("'..t.name..'")'
        end
        this._set('lockPixels', function()
            local f = tuna()
            runHaxeCode(f..'.pixels.lock();\n')
        end)
        this._set('unlockPixels', function()
            local f = this.fromPlayState and 'game.'..this.name or 'game.getLuaObject("'..this.name..'")'
            runHaxeCode(f..'.pixels.unlock();\n')
            return f
        end)
        this._set('setPixel32', function(x, y, color, lock)
            if lock == nil then lock = true end
            color = Color.normalize(color)

            local f = tuna()
            if lock then this.lockPixels() end
            runHaxeCode(f..'.pixels.setPixel32('..x..', '..y..', '..color.hex..');\n')
            if lock then this.unlockPixels() end

            return color
        end)
        this._set('drawPixelsFrom', function(object, allowTransparent, invert)
            this.lockPixels()
            for x = 0, object.width do
                for y = 0, object.height do
                    local f = object.getPixel32(x, y)
                    if (f.value ~= Color.TRANSPARENT or allowTransparent) then
                        if invert then f = f.getInverted() end
                        this.setPixel32(x, y, f, false)
                    end
                end
            end
            this.unlockPixels()
            return this
            -- this.lockPixels()
            -- (require 'cherlex.hscript.hscript'.execute(
            --     'for (x in 0...'..object.width..'){\n'..
            --         'for (y in 0...'..object.height..'){\n'..
            --             tuna(this)..'.pixels.setPixel32(x, y, '..(invert and 'game.callOnLuas("CALL_HSCRIPT_FROM_TABLE", [' or '')..tuna(object)..'.pixels.getPixel32(x, y)'..(invert and '])' or '')..');\n'..
            --         '}\n'..
            --     '}'
            -- ))
            -- this.unlockPixels()
        end)
        this._set('invert', function()
            this = this.drawPixelsFrom(this, false, true)
            return this
        end)
        this._set('fill', function(color, allowTransparent)
            this.lockPixels()
            for x = 0, this.width do
                for y = 0, this.height do
                    local f = this.getPixel32(x, y)
                    if (f.value ~= Color.TRANSPARENT or allowTransparent) then
                        this.setPixel32(x, y, Color.parseColor(color), false)
                    end
                end
            end
            this.unlockPixels()
            return this
        end)
        this._set('clear', function()
            local f = this.fromPlayState and 'game.'..this.name or 'game.getLuaObject("'..this.name..'")'
            runHaxeCode(f..'.graphic.bitmap.fillRect('..f..'.graphic.bitmap.rect, 0x0);')
        end)

        this._set('drawPolygon', function(vertices, color)
            local f = this.fromPlayState and 'game.'..this.name or 'game.getLuaObject("'..this.name..'")'

            local verticesArray = '['
            for i = 1, #vertices do
                verticesArray = verticesArray..'new FlxPoint('..vertices[i].x..', '..vertices[i].y..'), '
            end
            verticesArray = verticesArray:sub(1, -2)..']'

            addHaxeLibrary('FlxPoint', 'flixel.math')
            addHaxeLibrary('FlxSpriteUtil', 'flixel.util')
            runHaxeCode('FlxSpriteUtil.drawPolygon('..f..', '..verticesArray..','..Color(color).hex..');')
        end)
    end
    -- [[ ]] --

    return this
end

return Object