---@class Static used for Point 
local StaticStorage = function(Class, elements)
    local this = {}
    this = {
        add = function(field)
            if not this.initializedFields[field] then
                this[field] = {
                    initialize = function()
                        this[field] = Class()
                        this.initializedFields[field] = true
                        return this[field]
                    end,
                    uninitialize = function()
                        if not this.initializedFields[field] then
                            table.remove(this, field)
                            this.initializedFields[field] = false
                            this.add(field)
                        end
                    end
                }
                this[field].init = this[field].initialize
            end
        end,
        initializedFields = {}
    }
    if elements ~= nil then
        for _, v in next, elements, nil do
            this.add(v)
        end
    end
    return this
end
return StaticStorage