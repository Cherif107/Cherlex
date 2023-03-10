local Save = require 'cherlex.save.Save'
---@class System lua System (Test)

local System = {
    save = Save('SystemData')
}
return System