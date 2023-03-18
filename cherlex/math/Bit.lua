local Bit = {}

local function Bit_get(x, n)
    return (x % (2^(n+1)) >= 2^n)
end

local function Bit_set(x, n, v)
    if v then
        return Bit.bor(x, 2^n)
    else
        return Bit.band(x, Bit.bnot(2^n))
    end
end
function Bit.band(x, y)
    local z = 0
    for i = 0, 31 do
        if Bit_get(x, i) and Bit_get(y, i) then
            z = z + 2^i
        end
    end
    return z
end
function Bit.bor(x, y)
    local z = 0
    for i = 0, 31 do
        if Bit_get(x, i) or Bit_get(y, i) then
            z = z + 2^i
        end
    end
    return z
end
function Bit.bxor(x, y)
    local z = 0
    for i = 0, 31 do
        if Bit_get(x, i) ~= Bit_get(y, i) then
            z = z + 2^i
        end
    end
    return z
end
function Bit.bnot(x)
    local z = 0
    for i = 0, 31 do
        if not Bit_get(x, i) then
            z = z + 2^i
        end
    end
    return z
end
function Bit.lshift(x, n)
    return math.floor(x * 2^n)
end
function Bit.rshift(x, n)
    return math.floor(x / 2^n)
end
function Bit.rol(x, n)
    n = n % 32
    return Bit.bor(Bit.lshift(x, n), Bit.rshift(x, 32-n))
end
function Bit.ror(x, n)
    n = n % 32
    return Bit.bor(Bit.rshift(x, n), Bit.lshift(x, 32-n))
end
function Bit.tobit(x)
    return Bit.band(x, 0xffffffff)
end
function Bit.tohex(n)
    local hexChars = "0123456789abcdef"
    local hex = ""
    for i = 7, 0, -1 do
        local nibble = Bit.band(Bit.rshift(n, i * 4), 0x0f)
        hex = hex .. string.sub(hexChars, nibble+1, nibble+1)
    end
    return "0x" .. hex
end

return Bit
