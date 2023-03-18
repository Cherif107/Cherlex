local File = require 'cherlex.util.File'
local StringUtil = require 'cherlex.util.StringUtil'

---@class Save a class to save Variables/Data
local Save = {
    new = function(name)
        name = name or 'SystemData'
        if not File.exists('cherlex/save/'..name..'.lua') then
            local f = io.open('cherlex/save/'..name..'.lua', 'w')
            f:write('local Save = {}\nreturn Save')
            f:close()
        end
        local defaultTable = getDataTable(name)
        local this = {}
        this = {
            data = setmetatable(getDataTable(name), {
                __index = function(t, k)
                    if rawget(t, k) == nil then
                        return getDataTable(this.name)[k]
                    end
                    return rawget(t, k)
                end
            }),
            flush = function()
                local f = io.open('cherlex/save/'..this.name..'.lua', 'wb')
                f:write('local Save = '..StringUtil.table(this.data)..'\n\nreturn Save')
                f:close()
                return true
            end,
            name = name
        }
        return setmetatable(this, {__index = function(tbl, k)
            if k == 'data' then
                if rawget(tbl, 'data') ~= getDataTable(this.name) then
                    tbl['data'] = getDataTable(this.name)
                end
            end
        end})
    end
}
function getDataTable(name) 
    return dofile('cherlex/save/'..name..'.lua')
end

return setmetatable(Save, {__call = function(t, n) return Save.new(n) end})