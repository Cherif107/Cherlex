local Base64 = {}
Base64.chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="

function Base64.decodeCharacter(char)
    local index = string.find(Base64.chars, char, 1, true)
    return index - 1
end
function Base64.encodeCharacter(byte)
    local index = byte + 1
    return string.sub(Base64.chars, index, index)
end

function Base64.decode(str)
    local decoded = ""
    local padding = 0

    str = str:gsub("=", "")
    padding = #str % 4

    if padding == 1 then
        return nil, "Invalid padding"
    elseif padding == 2 then
        str = str .. "=="
    elseif padding == 3 then
        str = str .. "="
    end

    -- Convert each group of 4 Base64 characters to 3 bytes
    for i = 1, #str, 4 do
        local b1 = Base64.decodeCharacter(str:sub(i, i))
        local b2 = Base64.decodeCharacter(str:sub(i + 1, i + 1))
        local b3 = Base64.decodeCharacter(str:sub(i + 2, i + 2))
        local b4 = Base64.decodeCharacter(str:sub(i + 3, i + 3))

        local byte1 = bit.lshift(b1, 2) + bit.rshift(b2, 4)
        local byte2 = bit.lshift(bit.band(b2, 15), 4) + bit.rshift(b3, 2)
        local byte3 = bit.lshift(bit.band(b3, 3), 6) + b4

        decoded = decoded .. string.char(byte1, byte2, byte3)
    end

    return decoded
end

function Base64.encode(str)
    local encoded = ""

    -- Convert each group of 3 bytes to 4 Base64 characters
    for i = 1, #str, 3 do
        local byte1 = string.byte(str, i)
        local byte2 = string.byte(str, i + 1)
        local byte3 = string.byte(str, i + 2)

        local b1 = bit.rshift(byte1, 2)
        local b2 = bit.lshift(bit.band(byte1, 3), 4) + bit.rshift(byte2 or 0, 4)
        local b3 = bit.lshift(bit.band(byte2 or 0, 15), 2) + bit.rshift(byte3 or 0, 6)
        local b4 = bit.band(byte3 or 0, 63)

        encoded = encoded .. Base64.encodeCharacter(b1) .. Base64.encodeCharacter(b2)
        if byte2 ~= nil then
            encoded = encoded .. Base64.encodeCharacter(b3)
        else
            encoded = encoded .. "="
        end
        if byte3 ~= nil then
            encoded = encoded .. Base64.encodeCharacter(b4)
        else
            encoded = encoded .. "="
        end
    end

    return encoded
end

return Base64
