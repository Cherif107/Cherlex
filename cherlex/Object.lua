local Class = require 'cherlex.Class'
local StringUtil = require 'cherlex.util.StringUtil'
local Color = require 'cherlex.util.Color'
local File  = require 'cherlex.util.File'
local Stage = require 'cherlex.Event'

local jsonTable = StringUtil.json(File.getContent('cherlex.json'))

---@class Object:Class An Object Class For Property Parsing
local Object = Class()

---@param object Object|string
---@param key string
Object.parseObjectString = function(object, key)
    if object == '' then return key end
    if key == '' then return object end
    if type(object) == "table" then object = object.name end
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
    if Object.__statics[k] ~= nil and t._[k] == nil and Object.__objectFields.__setters[k] == nil then
        error('Cannot Access Static Field ('..k..') from a Class instance')
    else
        if Object.__objectFields.__setters[k] ~= nil then
            local x = Object.__objectFields.__setters[k](v, t)
            if x ~= nil then t._[k] = x end
        else
            if Object.__objectFields.__onInit[k] ~= nil then
                t._[k] = v
            else
                t.set(k, v)
            end
        end
    end
end

Object.instance.__index = function(t, k)
    if Object.__statics[k] ~= nil and t._[k] == nil and Object.__objectFields.__getters[k] == nil then
        error('Cannot Access Static Field ('..k..') from a Class instance')
    else
        if Object.__objectFields.__getters[k] ~= nil then
            return Object.__objectFields.__getters[k](t)
        end
        if Object.__objectFields.__onInit[k] ~= nil then
            return t._[k]
        end
        if t._get(k) ~= nil then
            return t._get(k)
        end
        if t.get(k) == Object.parseObjectString(t.name, k) then
            local o = Object(t.classObject, t.classLibrary, t.fromPlayState, true)
            o.name = Object.parseObjectString(t.name, k)
            o.originClass = nil
            return o
        else
            return t.get(k)
        end
    end
end

Object.objects = {}

Object.field('name', 'boyfriend')
Object.field('classObject', false)
Object.field('fromPlayState', false)
Object.field('classLibrary', '')

Object.field('isAdded', false)
Object.field('allowAdd', false)
Object.field('__waitingFields', {})

Object.field('update', -1)

Object.field('camera', 'camGame', nil, function(v, t) t.checkForWaitingField(function() setObjectCamera(t.name, v) end) return v end)
Object.field('order', nil, function(t) return getObjectOrder(t.name) end, function(v, t) t.checkForWaitingField(function() setObjectOrder(t.name, v) end) return v end)
Object.field('color', Color.WHITE, function(t) return Color(t.get('color')) end, function(v, t) t.checkForWaitingField(function() t.set('color', Color.parseColor(v)) end) return v end)
Object.field('blend', 'NORMAL', nil, function(v, t) t.checkForWaitingField(function() setBlendMode(t.name, v) end) return v end)

local oXC = _G.CHX_OBJ_TAG
---@return Object
Object.new = function(ClassObject, ClassLibrary, fromPlayState, isField, name)
    -- to prevent crashing
    if not isField and not fromPlayState and not ClassObject then
        --- generating Object Tag & current ID
        if not oXC  then
            _G.CHX_OBJ_COUNT = 0
            _G.CHX_OBJ_TAG = 'CHX_OBJ_'..StringUtil.random(10)
            oXC = 'yippeee'
        end
    end

    ---@type Object
    local this = Object.create()
    if name == nil then
        this.name = (fromPlayState and 'boyfriend' or _G.CHX_OBJ_TAG..'_'.._G.CHX_OBJ_COUNT)
    else
        this.name = name
    end
    this.classObject = ClassObject
    this.classLibrary = ClassLibrary
    this.fromPlayState = fromPlayState or false

    rawset(this, '_set', function(k, v) rawset(this, k, v) end)
    rawset(this, '_get', function(k) return rawget(this, k) end)
    this._set('set', function(key, v)
        if this.classObject then
            setPropertyFromClass(this.classLibrary, Object.parseObjectString(this.name, key), v)
        else
            this.checkForWaitingField(function() setProperty(Object.parseObjectString(this.name, key), v) end)
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
        return result.subtract(camera.scroll.x*this.scrollFactor.x, camera.scroll.y*this.scrollFactor.y)
    end)
    this._set('overlaps', function(object) return objectsOverlap(this.name, type(object) == 'table' and object.name or object) end)
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

        -- debugPrint(this.x, ':', point.x, ':', _point.x)
        debugPrint(this.y, ':', point.y, ':', _point.y)
        return (x >= _point.x and (x < _point.x + this.width) and (y >= _point.y) and (y < _point.y+this.height))
    end)

    this._set('objectScreenCenter', function(axes)
        axes = axes or 'XY'
        if axes == 'X' or axes == 'XY' then this.x = (screenWidth-this.width)/2 end
        if axes == 'Y' or axes == 'XY' then this.y = (screenHeight-this.height)/2 end
    end)
    this._set('centerOffsets', function(AdjustPosition)
        this.offset.x = (this.frameWidth - this.width) * 0.5;
		this.offset.y = (this.frameHeight - this.height) * 0.5;
		if (AdjustPosition) then
			this.x = this.x + this.offset.x;
			this.y = this.y + this.offset.y;
        end
    end)
    this._set('centerOrigin', function()
        this.origin.x = this.frameWidth * 0.5
        this.origin.y = this.frameHeight * 0.5
    end)

    this._set('updateHitbox', function(axes)
        updateHitbox(this.name)
    end)

    this._set('getPixel32', function(x, y)
        return Color(getPixelColor(this.name, x, y))
    end)
    this._set('fieldIsNull', function(field)
        return getProperty(Object.parseObjectString(this.name, field)) == nil
    end)

    --- [[ HSCRIPT ]] --
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
            this.pixels.lockPixels()
            for x = 0, object.width do
                for y = 0, object.height do
                    local f = object.getPixel32(x, y)
                    if (f.value ~= Color.TRANSPARENT or allowTransparent) then
                        if invert then f = f.getInverted() end
                        this.pixels.setPixel32(x, y, f, false)
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
            return this.drawPixelsFrom(this, false, true)
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
        this._set('drawGradient', function(width, height, colors, chunkSize, rotation, interpolate)
            interpolate = (interpolate or interpolate == nil)
            rotation = rotation or 90
            chunkSize = chunkSize or 1
            height, width = height or 0, width or 0
            local colorMap = '['
            if colors ~= {} then
                for i = 1, #colors-1 do
                    colorMap = colorMap..Color(colors[i]).hex..', '
                end
                colorMap = colorMap..Color(colors[#colors]).hex..']'
            else
                colorMap = '[]'
            end

            addHaxeLibrary('FlxGradient', 'flixel.util')
            runHaxeCode(tuna()..'.pixels = FlxGradient.createGradientBitmapData('..width..', '..height..', '..colorMap..', '..chunkSize..', '..rotation..', '..tostring(interpolate)..');')
        end)
    end

    this._set('destroyObject', function ()
        Object.objects[this.name] = nil
    end)
    -- [[ ]] --

    if not isField and not  fromPlayState and not ClassObject then
        _G.CHX_OBJ_COUNT = _G.CHX_OBJ_COUNT + 1
    end
    Object.objects[this.name] = this
    return this
end

Stage.set('onUpdate', function(el)
    for i, this in pairs(Object.objects) do
        if this.update ~= -1 then
            this.update(el)
        end
    end
end, 'ObjectUpdate')


return Object