local Class = {}

function table.copy(tbl)
    local t = {}
    for f, v in next, tbl, nil do
        t[f] = type(v) == 'table' and table.copy(v) or v
    end
    return setmetatable(t, getmetatable(tbl))
end
---@return Class
Class.new = function(name)
    ---@class Class yes finally i made this so i can resist the urge to make a metatable again
    ---@field private __statics table<any, any> Class Static Fields
    ---@field private __objectFields table<string, table<any, function|any>> get/set/default Fields for class instances
    ---@field __class table<string, function> Class Metatable
    ---@field instance table<string, function> Class Instance Metatable
    ---@field public create function Initializes Instance fields and returns Instance
    ---@field public new function Runs create() and gives you the ability to add fields to the Instance and add Arguments
    local class = {}
    class = {
        __type = name or 'Class',
        __statics = {},
        __objectFields = {
            __setters = {},
            __getters = {},
            __onInit = {} -- default
        },
        instance = {
            __index = function(t, k)
                if class.__statics[k] ~= nil and rawget(t, '_')[k] == nil and class.__objectFields.__getters[k] == nil then
                    error('Cannot Access Static Field ('..k..') from a Class instance')
                else
                    if class.__objectFields.__getters[k] ~= nil then
                        return class.__objectFields.__getters[k](t)
                    end
                    return rawget(t, '_')[k] == nil and rawget(t, k) or rawget(t, '_')[k]
                end
            end,
            __newindex = function(t, k, v)
                if class.__statics[k] ~= nil and rawget(t, '_')[k] == nil and class.__objectFields.__setters[k] == nil then
                    error('Cannot Access Static Field ('..k..') from a Class instance')
                else
                    if class.__objectFields.__setters[k] ~= nil then
                        local x = class.__objectFields.__setters[k](v, t)
                        if x ~= nil then rawget(t, '_')[k] = x end
                    end
                    if rawget(t, '_')[k] == nil then
                        rawset(t, k, v)
                    else
                        rawget(t, '_')[k] = v
                    end
                end
            end
        },
        __class = {
            __index = function(t, k)
                if rawget(t, '__statics')[k] ~= nil then return rawget(t, '__statics')[k] end
                return rawget(t, k)
            end,
            __newindex = function(t, k, v)
                rawget(t, '__statics')[k] = v
            end,
            __call = function(t, ...)
                return t.new(...)
            end
        },
        create = function()
            local this = {_ = {}}
            for field, value in next, class.__objectFields.__onInit, nil do
                this._[field] = value
            end
            this.copy = function() return table.copy(this) end
            this.originClass = class
            return setmetatable(this, class.instance)
        end,
        new = function(...) return class.create() end,
        field = function(field, value, get, set)
            class.__objectFields.__onInit[field] = value
            if get ~= nil then class.__objectFields.__getters[field] = get end
            if set ~= nil then class.__objectFields.__setters[field] = set end
            if get == 'never' then class.__objectFields.__getters[field] = function(...) return nil end end
            if set == 'never' then class.__objectFields.__setters[field] = function(...) return nil end end
            return true
        end,
        ---@return Class
        copy = function(name)
            local t = table.copy(class)
            t.__type = name or t.__type
            return t
        end,
        isInstance = function(v)
            return class == v.originClass
        end
    }
    setmetatable(class, class.__class)
    return class
end
return Class.new