local Class = require 'cherlex.Class'

local Test = Class()
Test.field('asparagussy', 1, function()
    return 1+1
end, function(v)
    debugPrint('lelepons')
end)
Test.pussy = 5
Test.new = function(arg1)
    local this = Test.create()
    return this
end

return Test