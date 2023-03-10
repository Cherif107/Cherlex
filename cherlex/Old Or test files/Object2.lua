local Class = require 'cherlex.Class'
local Color = require 'cherlex.util.Color'

---@class Object2:Class An Object Class For Property Parsing
local Object = Class()

---@param object Object2|string
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
            debugPrint('hello dear')
            return Object(Object.parseObjectString(t.name, k), t.classObject, t.classLibrary)
        else
            return rawget(t, 'get')(k)
        end
    end
end

Object.field('name', 'boyfriend')
Object.field('classObject', false)
Object.field('classLibrary', '')

Object.field('isAdded', false)
Object.field('allowAdd', false)
Object.field('__waitingFields', {})

Object.field('camera', 'camGame', nil, function(v, t) t.checkForWaitingField(function() setObjectCamera(t.name, v) end) return v end)
Object.field('color', Color.WHITE, function(t) return Color(rawget(t, 'get')('color')) end, function(v, t) t.checkForWaitingField(function() rawget(t, 'set')('color', Color.parseColor(v)) end) return v end)
Object.field('blend', 'NORMAL', nil, function(v, t) t.checkForWaitingField(function() setBlendMode(t.name, v) end) return v end)

---@return Object2
Object.new = function(Name, ClassObject, ClassLibrary)
    ---@type Object2
    local this = Object.create()
    this.name = Name or 'boyfriend'
    this.classObject = ClassObject
    this.classLibrary = ClassLibrary

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
        local cam = (camera == nil and Game.camera or Game[camera])
        result.set(this.x, this.y)
        return result.substract(cam.scroll.x*this.scrollFactor.x, cam.scroll.y*this.scrollFactor.y)
    end)
    this._set('overlaps', function(object) return objectsOverlap(this.__name, type(object) == 'table' and object.__name or object) end)
    return this
end

return Object