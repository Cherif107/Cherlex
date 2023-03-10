local json = {}
function string.at(self, x) return self:sub(x, x) end
function string.split(self, split)
    split = split or '%s'
    local t={}
    for str in self:gmatch("([^"..split.."]+)") do table.insert(t, str) end
    return t
end
function string.tobool(self) if self == 'true' then return true elseif self == 'false' then return false else return self end end
function string.checkToNumber(self) if type(self) == 'string' then if tonumber(self) ~= nil then return tonumber(self) else return self end else return self end end

function json.value(value)
    if tonumber(value) ~= nil then value = tonumber(value)
    elseif value == 'true' then value = true
    elseif value == 'false' then value = false
    elseif value == 'null' then value = nil
    elseif value:sub(-1) == '"' and value:sub(1, 1) == '"' then value = value:sub(2):sub(1, -2) end
    return value
end

function json.parse(str)
    print(str)
    str = str:gsub('\n', ''):gsub(' ', ''):sub(2):sub(1, -2)
    print(str)
    local returnThis = {}
    local sepFields = str:split(',')
    for i = 1, #sepFields do
        local sepValues = sepFields[i]:split(':')
        local field = (sepValues[2] ~= nil and sepValues[1]:gsub('"', '') or i)
        local value = (sepValues[2] ~= nil and sepFields[i]:sub(#field+4) or sepFields[1])
        returnThis[field] = ((not string.find(value, '{') and not string.find(value, ']')) and json.value(value) or json.parse(value))
    end
    return returnThis
end

--- quick json parser that i made

local Dialogue = {
    allowStart = true,
    hasEnded = false,
    BF = {},
    DAD = {}
}

