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
    str = str:gsub('\n', ''):gsub(' ', ''):sub(2):sub(1, -2)
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

---@class StringUtil a simple string util class
local StringUtil = {}
StringUtil = {
    at = function(string, position) return string:sub(position, position) end,
    split = function(string, split)
        split = split or '%s'
        local t={}
        for str in string:gmatch("([^"..split.."]+)") do table.insert(t, str) end
        return t
    end,
    amountOf = function(string, of)
        return #StringUtil.split(string, of)-1
    end,
    multiFind = function(string, s)
        for _, x in next, s, nil do
            local a, b = string.find(x)
            if a ~= nil then return a, b end
        end
    end,
    rfind = function (subject, tofind, startIdx, endIdx)
        startIdx = startIdx or 0
        endIdx = endIdx or #subject
        subject = subject:sub(startIdx+1, endIdx):reverse()
        tofind = tofind:reverse()
        local idx = subject:find(tofind)
        return idx and #subject - #tofind - idx + startIdx + 1 or -1
    end,
    table = function(tbl, edible, optimize, bracket) -- leave the other 2 options empty if you dont know what you're doing
        edible, bracket = edible or '', bracket or false
        optimize = (optimize == nil and true or optimize)
        local collapse, deform, returnThis = {'[', ']'}, '"', '{\n'
        for _, v in pairs(tbl) do
            if type(_) == 'string' then if not string.find(_, ' ') and not bracket then collapse = {'', ''} deform = '' else collapse = {'[', ']'} deform = '"' end end
            if type(v) ~= 'table' then
                if type(v) == 'string' then v = string.gsub(('"'..v..'"'), '\n', '\\n') end
                returnThis = returnThis.. (optimize and (edible ..'  ') or '')..collapse[1]..(type(_) == 'number' and _ or deform.._..deform)..collapse[2]..' = '..tostring(v)..',\n'
            else
                returnThis = returnThis.. (optimize and (edible ..'  ') or '')..collapse[1]..(type(_) == 'number' and _ or deform.._..deform)..collapse[2]..' = '..StringUtil.table(v, optimize and (edible..'  ') or '', optimize, bracket)..',\n'
            end
        end
        return (string.find(returnThis, ',', #returnThis - 2) and returnThis:sub(1, #returnThis - 2) or returnThis)..'\n'..(optimize and (edible) or '')..'}'
    end,
    json = json.parse -- a very simple json parser
}

return StringUtil