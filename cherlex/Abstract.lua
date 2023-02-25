local Abstract = {}

function Abstract.setSafeMetatable(value, metatable)
    local isProtected = true
    
    -- Check if the value can be protected
    pcall(function()
      debug.setmetatable(value, {
        __metatable = "protected",
        __newindex = function()
          error("Attempt to modify a protected value", 2)
        end
      })
    end)
    
    -- Check if the metatable can be set safely
    local ok, err = pcall(function()
      debug.setmetatable(value, metatable)
    end)
    
    -- Restore the original metatable if the metatable couldn't be set safely
    if not ok then
      debug.setmetatable(value, nil)
      isProtected = false
    end
    
    return isProtected
end
local function getLocalId(threadLevel, condition)
    local i = 1
    while true do
        local name, value = debug.getlocal(1 + threadLevel, i)
        if name == '(*temporary)' or not name then
            break
        end
        if value == condition then
            return i
        end
        i = i + 1
    end
end
function Abstract.Abstractify(x)
    return setmetatable(
        x,
        {
            __newindex = function(t, k, v)
                local localId = getLocalId(2, t)
                if not localId then
                    local preEnv = getfenv(2)
                    for k2, v2 in pairs(preEnv) do
                        if v2 == t then
                            preEnv[k2] = v
                            break
                        end
                    end
                else
                    debug.setlocal(2, localId, v)
                end
            end
        }
    )
end

