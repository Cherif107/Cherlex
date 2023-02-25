---@class File a file class
local File = {
    save = function(file, content)
        local f = io.open(file, 'wb')
        f:write(content)
        return f, f:close()
    end,
    getContent = function(file)
        local f = io.open(file):read '*all'
        return f
    end,
    exists = function(file)
        local f = io.open(file, 'r')
        if f ~= nil then f:close() end
        return f ~= nil
    end,
    getScriptPath = function ()
        return debug.getinfo(1, "S").source:match [[^@?(.*[\/])[^\/]-$]]
    end,
    getFileList = function(folder) -- deprecated
        local i, t, popen = 0, {}, io.popen
        for filename in popen('dir "' .. folder .. '" /b'):lines() do
            i = i + 1
            t[i] = filename
        end
        return t
    end
}

return File
-- yeah thats all not too much