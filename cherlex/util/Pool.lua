---@class Pool naur not me copying flixel

local function indexOf(tbl, v)
    for k, v_ in pairs(tbl) do if v == v_ then return k end end
    return -1
end

return function(Class)
    local this = {}
    this = {
        _Pool = {},
        _Class = Class,

        _Count = 0,

        get = function()
            if this._Count == 0 then
                return this._Class()
            end
            return this._Pool[this._Count]
        end,

        put = function(Object)
            if Object ~= nil then
                local i = indexOf(this._Pool, Object)
                if i == -1 or i >= this._Count then
                    this._Count = this._Count+1
                    this._Pool[this._Count] = Object
                end
            end
        end,

        putUnsafe = function(Object)
            if Object ~= nil then
                this._Count = this._Count+1
                this._Pool[this._Count] = Object
            end
        end,

        clear = function()
            this._Count = 0
            local op = this._Pool
            this._Pool = {}
            return op
        end,

        preAllocate = function(n)
            while (n > 0) do
                n = n-1
                this._Count = this._Count+1
                this._Pool[this._Count] = this._Class()
            end
        end
    }
    return setmetatable(this, {__len = function(tbl) return tbl._Count end})
end