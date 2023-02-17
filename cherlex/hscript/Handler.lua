local File = require 'cherlex.util.File'
local Stage = require 'cherlex.Event'
local HScript = require 'cherlex.hscript.hscript'

for f, v in pairs(Stage.functions) do
    Stage.set(f, function(...)
        HScript.call(f, ...)
    end, 'HSCRIPT_CALLBACK_HANDLER')
end

---@class Handler a very simple hscript handler
return function(filePath)
    local text = File.getContent(filePath)
    HScript.execute(text)
    return text
end