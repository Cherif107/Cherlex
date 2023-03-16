
local import = require("import")
local Color = import "util.Color"
local Field = import 'Field'
local Game = import 'Game'

local function contains(t, k)
    for i, o in pairs(t) do
        if k == i then
            return true
        end
    end
end

function string.split(self, split)
    split = split or '%s'
    local t={}
    for str in self:gmatch("([^"..split.."]+)") do table.insert(t, str) end
    return t
end

local function uhhhIdk(name, key)
    if name == '' then return key end
    if type(key) == 'number' then
        return name..'['..key..']'
    end
    return name..'.'..key
end

local function parse(f, name, isFromClass, classLib)
    if type(f) == "string" or f == nil then
        f = {
            __name = f or name or "boyfriend",
            __type = "Object",
        }
    end

    f.__isFromClass = isFromClass
    f.__classLib = classLib or ''
    f.__propWait = {}
    f.__camera = "camGame"
    f.ignoreProperty = {
        camera = {
            get = function()
                return f.__camera
            end,
            set = function(value)
                f.__camera = value
                setObjectCamera(f.__name, value)
            end
        }
    }
    f.specials = {
        camera = function(n, v) setObjectCamera(n, v) end,
        color = function(n, v) setMethod(rawget(f, '__isFromClass') and 'class' or '', n..'.color', Color.parseColor(v), f.__classLib) end,
        blendMode = function(n, v) setBlendMode(n, v) end,
    }
    f.updateHitbox = function() updateHitbox(name) end

    ---@param object Object the object that is overlapped
    ---@return boolean
    function f:overlaps(object)
        return objectsOverlap(f.__name, type(object) == 'table' and object.__name or object)
    end
    
    local p = onUpdate or nil -- i am myself and you are yourself
    onUpdate = function(el)
        for k, v in next, rawget(f, '__propWait'), nil do
            local _f = k:split('.')[#k:split('.')]
            if contains(rawget(f, 'specials'), _f) then
                rawget(f, 'specials')[_f](k:sub(1, -(#_f+2)), v)
            else
                setMethod(f.__isFromClass and 'class' or '', k, v, f.__classLib)
                rawget(f, '__propWait')[k] = nil
            end
        end
        if p ~= nil then p(el) end
    end

    return setmetatable(f, {
        __index = function(table, key)
            local t = rawget(f, '__isFromClass') and 'class' or ''
            if makeLuaSprite == nil then
                return Field(uhhhIdk(rawget(f, '__name'), key), function(v)
                    rawget(table, '__propWait')[v.name] = v.value
                end)
            else
                if getMethod(t, uhhhIdk(table.__name, key), rawget(f, '__classLib')) == uhhhIdk(table.__name, key) then
                    return parse({__name = uhhhIdk(table.__name, key), __type = "value"}, 'guh', isFromClass, classLib)
                else
                    return getMethod(t, uhhhIdk(table.__name, key), rawget(f, '__classLib'))
                end
            end
            return 0
        end,
        __newindex = function(table, key, value)
                rawget(table, '__propWait')[uhhhIdk(rawget(table, '__name'), key)] = value
            -- else
            --     setProperty(uhhhIdk(table.__name, key), value)
            -- end
        end
    })
end

function setMethod(type, name, value, classLib)
    if type == 'class' then
        setPropertyFromClass(classLib, name, value)
    else
        setProperty(name, value)
    end
end
function getMethod(type, name, classLib)
    if type == 'class' then
        return getPropertyFromClass(classLib, name)
    end
    return getProperty(name)
end


return parse