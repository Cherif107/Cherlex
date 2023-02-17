---@class Field a class that was gotten from Object for easier use

local function uhhhIdk(name, key)
    if type(key) == 'number' then
        return name..'['..key..']'
    end
    return name..'.'..key
end


local function newField(parent)
    return {
        __ignoreShit = true,
        __type = 'Field',
        __parent = parent,
        __name = parent,
        __fullname = parent,
        __finalName = parent,
        value = 0
    }
end

local function newFieldFromField(field, key)
    local this = {
        __type = 'Field',
        __parent = field.__name,
        __name = key,
        __fullname = uhhhIdk(rawget(field, '__fullname'), key),
        __finalName = uhhhIdk(rawget(field, '__finalName'), key),
        value = 0
    }
    rawset(field, '__finalName', uhhhIdk(rawget(field, '__finalName'), key))
    rawset(field, 'child', this)
    return this
end

local function isMulti(field)
    return rawget(field, 'child') ~= nil
end

local function getFinal(field, allowLastName)
    local finalTable = {}
    if isMulti(field) then
        finalTable = getFinal(rawget(field, "child"))
    else
        finalTable.name = rawget(field, "__finalName")
        finalTable.value = rawget(field, "value")
        finalTable.lastName = rawget(field, "__name")
    end
    return finalTable
end


local function finale(field, key, passFunc)
    local this = setmetatable(newFieldFromField(field, key), {
        __index = function(tbl, k)
            return finale(tbl, k, passFunc)
        end,
        __newindex = function(tbl, k, v)
            local finalValue = newFieldFromField(tbl, k)
            rawset(finalValue, 'value', v)
            rawset(tbl, 'child', finalValue)
            passFunc(getFinal(finalValue))
        end
    })
    return this
end


-- local f = test('oops')
-- f.x.a = 5

-- print(getFinal(f).name)

return setmetatable({
    get = getFinal
}, {__call = function(tbl, object, passFunc)
    local f = newField(object)
    return setmetatable(f, {__index = function(tbl, key) return finale(tbl, key, passFunc) end, __newindex = function(tbl, k, v)
        rawset(tbl, 'value', v)
        rawset(tbl, '__finalName', uhhhIdk(rawget(tbl, '__finalName'), k))
        passFunc(getFinal(tbl))
    end})
end})


-- shits a disaster