local Class = require 'cherlex.Class'
local Math = require 'cherlex.math.Math'
local Ease = require 'cherlex.tweens.Ease'
local function switchCase(var, cases)
    for _, __ in pairs(cases) do
        if var == _ then
            return __
        end
    end
    return cases.default
end

local function setSafeMetatable(value, metatable)
    local isProtected = true
    
    pcall(function()
      debug.setmetatable(value, {
        __metatable = "protected",
        __newindex = function()
          error("Attempt to modify a protected value", 2)
        end
      })
    end)
    
    local ok, err = pcall(function()
      debug.setmetatable(value, metatable)
    end)
    
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

---@class ColorValue:number Color Value
---[[ ]]---
---@field __type string Color Type
---@field public value integer Integer Value of the Color
---@field public red integer Red Value of the Color
---@field public green integer Green Value of the Color
---@field public blue integer Blue Value of the Color
---@field public alpha integer Alpha Value of the Color
---@field public redFloat integer Red Float of the Color
---@field public greenFloat integer Green Float of the Color
---@field public blueFloat integer Blue Float of the Color
---@field public alphaFloat integer Alpha Float of the Color
---@field public cyan integer Cyan Value of the Color
---@field public magenta integer Magenta Value of the Color
---@field public yellow integer Yellow Value of the Color
---@field public black integer Black Value of the Color
---@field public hue integer Color Hue in Degrees
---@field public saturation number Saturation Float of the Color
---@field public brightness number Brightness Float of the Color
---@field public lightness number Lightness Float of the Color
---[[ ]]---

---@class Harmony
---[[ ]]---
---@field original ColorValue
---@field warmer ColorValue
---@field colder ColorValue
---[[ ]]---

---@class TridacHarmony
---[[ ]]---
---@field color1 ColorValue
---@field color2 ColorValue
---@field color3 ColorValue
---[[ ]]---

---@class Color:Class A Color Class
---[[                                                ]]---
---@field public TRANSPARENT integer Transparent Color
---@field public WHITE integer White Color
---@field public GRAY integer Gray Color
---@field public BLACK integer Black Color
---@field public CYAN integer Cyan Color
---@field public BLUE integer Blue Color
---@field public GREEN integer Green Color
---@field public LIME integer Lime Color
---@field public YELLOW integer Yellow Color
---@field public ORANGE integer Orange Color
---@field public RED integer Red Color
---@field public PINK integer Pink Color
---@field public MAGENTA integer Magenta Color
---@field public PURPLE integer Purple Color
---[[                                               ]]---
local Color = Class()

local idxMeta = Color.__class.__newindex
Color.__class.__newindex = function(t, k, v) idxMeta(t, k, (type(v) == 'number' and bit.tobit(v) or v)) end

Color.TRANSPARENT = 0x00000000

Color.WHITE = 0xFFffffff
Color.GRAY = 0xFF808080
Color.BLACK = 0xFF000000

Color.CYAN = 0xFF00FFFF
Color.BLUE = 0xFF0000FF
Color.GREEN = 0xFF008000
Color.LIME = 0xFF00FF00
Color.YELLOW = 0xFFFFFF00
Color.ORANGE = 0xFFFFA500
Color.RED = 0xFFFF0000
Color.PINK = 0xFFFFC0CB
Color.MAGENTA = 0xFFFF00FF
Color.PURPLE = 0xFF800080

---@param hexString string Hex String
---@return integer 32-bit Color Integer
function Color.fromString(hexString) -- (Convert String to 32-bit Color)
    if not string.find(hexString, '0x') then
        hexString = '0xFF'..hexString
    end
    return bit.tobit(tonumber(hexString))
end

---@param RGB table<string, integer> RGB Table
---@return ColorValue @Color Table
function Color.fromRGB(RGB) -- (Convert RGB To Color)
    local color = Color()
    color.red = RGB.r or RGB.R or RGB.Red or RGB.RED or RGB.red or 255
    color.green = RGB.g or RGB.G or RGB.Green or RGB.GREEN or RGB.green or 255
    color.blue = RGB.b or RGB.B or RGB.Blue or RGB.BLUE or RGB.blue or 255
    color.alpha = RGB.a or RGB.A or RGB.Alpha or RGB.ALPHA or RGB.alpha or 255
    return color
end

---@param RGB table<string, number> RGB Float Table
---@return ColorValue @Color Table
function Color.fromRGBFloat(RGB)
    local color = Color()
    color.redFloat = RGB.r or RGB.R or RGB.Red or RGB.RED or RGB.red or 1
    color.greenFloat = RGB.g or RGB.G or RGB.Green or RGB.GREEN or RGB.green or 1
    color.blueFloat = RGB.b or RGB.B or RGB.Blue or RGB.BLUE or RGB.blue or 1
    color.alphaFloat = RGB.a or RGB.A or RGB.Alpha or RGB.ALPHA or RGB.alpha or 1
    return color
end

---@param Cyan number Cyan Float between 0 and 1
---@param Magenta number Magenta Float between 0 and 1
---@param Yellow number Yellow Float between 0 and 1
---@param Black number Black Float between 0 and 1
---@param Alpha number Alpha Float between 0 and 1
---@return ColorValue @Color Table
function Color.fromCMYK(Cyan, Magenta, Yellow, Black, Alpha)
    return Color().setCMYK(Cyan, Magenta, Yellow, Black, Alpha or 1)
end

---@param Hue integer Hue Integer between 0 and 360
---@param Saturation number Saturation Float between 0 and 1
---@param Brightness number Brightness Float between 0 and 1
---@param Alpha number Alpha Float between 0 and 1 or between 0 and 255
---@return ColorValue @Color Table
function Color.fromHSB(Hue, Saturation, Brightness, Alpha)
    return Color().setHSB(Hue, Saturation, Brightness, Alpha or 1)
end

---@param Hue integer Hue Integer between 0 and 360
---@param Saturation number Saturation Float between 0 and 1
---@param Lightness number Lightness Float between 0 and 1
---@param Alpha number Alpha Float between 0 and 1 or between 0 and 255
---@return ColorValue @Color Table
function Color.fromHSL(Hue, Saturation, Lightness, Alpha)
    return Color().setHSL(Hue, Saturation, Lightness, Alpha or 1)
end

---@param color ColorValue|integer|string Color To Parse
---@return integer 32-bit Color Integer
function Color.parseColor(color) -- (Converts all Kinds of colors to 32-bit Integer)
    if type(color) == "table" then
        if color.__type == "Color" then
            return color.value
        else
            return Color.fromRGB(color).value
        end
    end
    if type(color) == "string" then
        return Color.fromString(color)
    end
    return bit.tobit(color)
end

---@param color ColorValue|integer|string Color To Parse
---@return ColorValue @Color Table
function Color.normalize(color)
    return Color(Color.parseColor(color))
end

---@param Color1 ColorValue|integer|string Color to start From
---@param Color2 ColorValue|integer|string Color to interpolate To
---@param Factor? number How much to Shift Color1 towards Color2
---@return ColorValue @Color Table
function Color.interpolate(Color1, Color2, Factor)
    Factor = Factor or 0.5
    local PColor1, PColor2 = Color.normalize(Color1), Color.normalize(Color2)
    local RGB = {
        r = math.floor((PColor2.red - PColor1.red) * Factor + PColor1.red),
        g = math.floor((PColor2.green - PColor1.green) * Factor + PColor1.green),
        b = math.floor((PColor2.blue - PColor1.blue) * Factor + PColor1.blue),
        a = math.floor((PColor2.alpha - PColor1.alpha) * Factor + PColor1.alpha),
    }
    return Color.fromRGB(RGB)
end
---@return ColorValue
function Color.blend(Color1, Color2) return Color.interpolate(Color1, Color2, 0.5) end

---@param Color1 ColorValue|integer|string Left Color
---@param Color2 ColorValue|integer|string Right Color
---@param Steps integer how many colors the gradient should have
---@param ease Ease Ease function
---@return table<integer, ColorValue>
function Color.gradient(Color1, Color2, Steps, ease)
    ease = ease or Ease.linear
    local gradientArray = {}
    for s = 1, Steps do
        gradientArray[s] = Color.interpolate(Color1, Color2, ease(s/(Steps-1)))
    end
    return gradientArray
end

---@return table<integer, ColorValue>
function Color.getHSBColorWheel(Alpha)
    local c = {}
    for a = 0, 360 do
        c[a] = Color.fromHSB(a, 1, 1, Alpha)
    end
    return c
end

---@return table<integer, ColorValue>
function Color.getLightColorWheel(Alpha)
    local c = {}
    for a = 0, 360 do
        c[a] = Color.fromHSB(a, a/360, a/360, Alpha)
    end
    return c
end

---[[ Instace Fields ]]---

Color.field('value', Color.BLACK)
Color.field('red', 0, function(t) return bit.band(bit.rshift(t.value, 16), 0xff) end, function(v, t)
    t.value = bit.bor(bit.band(t.value, 0xff00ffff), bit.lshift(t.boundChannel(v), 16))
    return v
end)
Color.field('green', 0, function(t) return bit.band(bit.rshift(t.value, 8), 0xff) end, function(v, t)
    t.value = bit.bor(bit.band(t.value, 0xffff00ff), bit.lshift(t.boundChannel(v), 8))
    return v
end)
Color.field('blue', 0, function(t) return bit.band(t.value, 0xff) end, function(v, t)
    t.value = bit.bor(bit.band(t.value, 0xffffff00), t.boundChannel(v))
    return v
end)
Color.field('alpha', 0, function(t) return bit.band(bit.rshift(t.value, 24), 0xff) end, function(v, t)
    t.value = bit.bor(bit.band(t.value, 0x00ffffff), bit.lshift(t.boundChannel(v), 24))
    return v
end)

Color.field('cyan', 0, function(t) return (1 - t.redFloat - t.black)/t.brightness end, function(v, t) t.cyan = t.setCMYK(v, t.magenta, t.yellow, t.black) return v end)
Color.field('magenta', 0, function(t) return (1 - t.greenFloat - t.black)/t.brightness end, function(v, t) t.magenta = t.setCMYK(t.cyan, v, t.yellow, t.black) return v end)
Color.field('yellow', 0, function(t) return (1 - t.blueFloat - t.black)/t.brightness end, function(v, t) t.yellow = t.setCMYK(t.cyan, t.magenta, v, t.black) return v end)
Color.field('black', 0, function(t) return 1-t.brightness end, function(v, t) t.cyan = t.setCMYK(t.cyan, t.magenta, t.yellow, v) return v end)

Color.field('redFloat', 0, function(t) return t.red/255 end, function(v, t) t.red = Math.round(v*255) return v end)
Color.field('greenFloat', 0, function(t) return t.green/255 end, function(v, t) t.green = Math.round(v*255) return v end)
Color.field('blueFloat', 0, function(t) return t.blue/255 end, function(v, t) t.blue = Math.round(v*255) return v end)
Color.field('alphaFloat', 0, function(t) return t.alpha/255 end, function(v, t) t.alpha = Math.round(v*255) return v end)

Color.field('saturation', 0, function(t) return (t.maxColor()-t.minColor())/t.brightness end, function(v, t) t.setHSB(t.hue, v, t.brightness, t.alphaFloat) return v end)
Color.field('brightness', 0, function(t) return t.maxColor() end, function(v, t) t.setHSB(t.hue, t.saturation, v, t.alphaFloat) return v end)
Color.field('lightness', 0, function(t) return (t.maxColor()+t.minColor())/2 end, function(v, t) t.setHSL(t.hue, t.saturation, v, t.alphaFloat) return v end)
Color.field('hue', 0, function(t)
    local hueRad = math.atan2(3^0.5 * (t.greenFloat-t.blueFloat), 2 * t.redFloat - t.greenFloat - t.blueFloat)
    local hue = 0
    if hueRad ~= 0 then
        hue = 180 / math.pi * math.atan2(3^0.5 * (t.greenFloat - t.blueFloat), 2 * t.redFloat - t.greenFloat - t.blueFloat)
    end
    return (hue < 0 and hue + 360 or hue)
end, function(v, t)
    t.setHSB(v, t.saturation, t.brightness, t.alphaFloat)
    return v
end)

Color.field('hex', '?', function(t) return '0x'..bit.tohex(t.value) end, 'never')
Color.field('info', '?', function(t) return t.getInfo() end, 'never')
Color.instance.__tostring = function(t) return t.info end
Color.instance.__add = function(t, v) 
    v = Color.normalize(v)
    t = Color.normalize(t)
    return Color.fromRGB({ r = t.red + v.red, g = t.green + v.green, b = t.blue + v.blue})
end
Color.instance.__sub = function(t, v) 
    v = Color.normalize(v)
    t = Color.normalize(t)
    return Color.fromRGB({ r = t.red - v.red, g = t.green - v.green, b = t.blue - v.blue})
end
Color.instance.__mul = function(t, v) 
    v = Color.normalize(v)
    t = Color.normalize(t)
    return Color.fromRGB({ r = t.redFloat * v.redFloat, g = t.greenFloat * v.greenFloat, b = t.blueFloat * v.blueFloat})
end

---[[ Create a Class Instace Function ]]---

---@param color string|integer|table<string, number> Color Float
---@return ColorValue
Color.new = function(color)
    color = color or Color.BLACK

    ---@type ColorValue
    local this = Color.create()
    this.__type = 'Color' 
    this.value = Color.parseColor(color)

    ---@param red integer Red Value (between 0 and 255)
    ---@param green integer Green Value (between 0 and 255)
    ---@param blue integer Blue Value (between 0 and 255)
    ---@param alpha integer Alpha Value (between 0 and 255)
    ---@return ColorValue Returns "this"
    this.setRGB = function(red, green, blue, alpha) -- set Color RGB
        this.red, this.green = red or 0, green or 0
        this.blueFloat, this.alpha = blue or 0, alpha or 255
        return this
    end
    ---@param red number Red Float (between 0 and 1)
    ---@param green number Green Float (between 0 and 1)
    ---@param blue number Blue Float (between 0 and 1)
    ---@param alpha number Alpha Float (between 0 and 1)
    ---@return ColorValue Returns "this"
    this.setRGBFloat = function(red, green, blue, alpha) -- set Color RGB Float
        this.redFloat, this.greenFloat = red or 0, green or 0
        this.blueFloat, this.alphaFloat = blue or 0, alpha or 1
        return this
    end
    this.boundChannel = function(value) -- 
        return (value > 0xff and 0xff or value < 0 and 0 or value)
    end
    this.maxColor = function()
        return math.max(this.red, this.blue, this.green)
    end
    this.minColor = function()
        return math.min(this.red, this.blue, this.green)
    end
    this.setHSChromaMatch = function(Hue, Saturation, Chroma, Match, Alpha)
        Hue = Hue % 360
        local hueD = Hue / 60
        local mid = Chroma * (1 - math.abs(hueD % 2 - 1)) + Match
        Chroma = Chroma + Match

        switchCase(math.floor(hueD), {
            [0] = function() return this.setRGBFloat(Chroma, mid, Match, Alpha) end,
            function() return this.setRGBFloat(mid, Chroma, Match, Alpha) end,
            function() return this.setRGBFloat(Match, Chroma, mid, Alpha) end,
            function() return this.setRGBFloat(Match, mid, Chroma, Alpha) end,
            function() return this.setRGBFloat(mid, Match, Chroma, Alpha) end,
            function() return this.setRGBFloat(Chroma, Match, mid, Alpha) end,
            default = function() return this end
        })()
        return this
    end
    ---@param Hue integer Hue Value (between 0 and 360)
    ---@param Saturation number Saturation Float (between 0 and 1)
    ---@param Brightness number Brightness Float (between 0 and 1)
    ---@param Alpha number Alpha Float (between 0 and 1)
    ---@return ColorValue Returns "this"
    this.setHSB = function (Hue, Saturation, Brightness, Alpha)
        local chroma = Brightness * Saturation
        local match = Brightness - chroma
        return this.setHSChromaMatch(Hue, Saturation, chroma, match, Alpha)
    end
    ---@param Hue integer Hue Value (between 0 and 360)
    ---@param Saturation number Saturation Float (between 0 and 1)
    ---@param Lightness number Lightness Float (between 0 and 1)
    ---@param Alpha number Alpha Float (between 0 and 1)
    ---@return ColorValue Returns "this"turn this.setHSChromaMatch(Hue, Saturation, chroma, match, Alpha)
    this.setHSL = function(Hue, Saturation, Lightness, Alpha)
        local chroma = (1 - math.abs(2 * Lightness - 1)) * Saturation
        local match = Lightness - chroma/2
        return this.setHSChromaMatch(Hue, Saturation, chroma, match, Alpha)
    end
    ---@param Cyan number Cyan Value (between 0 and 1)
    ---@param Magenta number Magenta Float (between 0 and 1)
    ---@param Yellow number Yellow Float (between 0 and 1)
    ---@param Black number Black Float (between 0 and 1)
    ---@param Alpha number Alpha Float (between 0 and 1)
    ---@return ColorValue Returns "this"
    this.setCMYK = function(Cyan, Magenta, Yellow, Black, Alpha)
        Black = Black or 0
        this.redFloat = (1 - (Cyan or 0)) * (1 - Black)
        this.greenFloat = (1 - (Magenta or 0)) * (1 - Black)
        this.blueFloat = (1 - (Yellow or 0)) * (1 - Black)
        this.alphaFloat = (Alpha or 1)
        return this
    end
    this.getInfo = function()
        return 
            "Alpha: "..this.alpha..' | Red: '..this.red..' | Green: '..this.green..' | Blue: '..this.blue..'\n'..
            "Hue: "..Math.roundDecimal(this.hue, 2)..' | Saturation: '..Math.roundDecimal(this.saturation, 2)..'\n'..
            "Brightness: "..Math.roundDecimal(this.brightness, 2)..' | Lightness:'..Math.roundDecimal(this.lightness, 2)
    end
    this.getInverted = function()
        local a = this.alpha
        local o = Color.WHITE-this
        o.alpha = a
        return o
    end
    this.getLightened = function(Factor)
        Factor = Math.bound((Factor or 0.2), 0, 1)
        local o = Color.new(this.value)
        o.lightness = o.lightness + (1-this.lightness)*Factor
        return o
    end
    this.getDarkened = function(Factor)
        Factor = Math.bound((Factor or 0.2), 0, 1)
        local o = Color.new(this.value)
        o.lightness = o.lightness * (1-Factor)
        return o
    end
    this.to24Bit = function()
        return bit.band(this.value, 0xffffff)
    end
    ---@return TridacHarmony
    this.getTridacHarmony = function()
        local t1 = Color.fromHSB(Math.wrap(math.floor(this.hue)+120, 0, 359), this.saturation, this.brightness, this.alphaFloat)
        local t2 = Color.fromHSB(Math.wrap(math.floor(t1.hue)+120, 0, 359), this.saturation, this.brightness, this.alphaFloat)
        return {color1 = this, color2 = t1, color3 = t2}
    end
    ---@return Harmony
    this.getSplitComplementHarmony = function(Threshold)
        Threshold = Threshold or 30
        local opp = Math.wrap(math.floor(this.hue)+180, 0, 350)
        local war = Color.fromHSB(Math.wrap(opp-Threshold, 0, 350), this.saturation, this.brightness, this.alphaFloat)
        local col = Color.fromHSB(Math.wrap(opp+Threshold, 0, 350), this.saturation, this.brightness, this.alphaFloat)
        return {original = this, warmer = war, colder = col}
    end
    ---@return Harmony
    this.getAnalogousHarmony = function(Threshold)
        Threshold = Threshold or 30
        local war = Color.fromHSB(Math.wrap(math.floor(this.hue)-Threshold, 0, 350), this.saturation, this.brightness, this.alphaFloat)
        local col = Color.fromHSB(Math.wrap(math.floor(this.hue)+Threshold, 0, 350), this.saturation, this.brightness, this.alphaFloat)
        return {original = this, warmer = war, colder = col}
    end
    ---@return ColorValue
    this.getComplementHarmony = function()
        return Color.fromHSB(Math.wrap(math.floor(this.hue)+180, 0, 350), this.brightness, this.saturation, this.alphaFloat)
    end

    -- ---@type ColorValue
    -- local thisNUM = this.value
    -- setSafeMetatable(thisNUM, {
    --     __newindex = function(t, k, v)
    --         if k == 'self' then
    --             local localId = getLocalId(2, t)
    --             if not localId then
    --                 local preEnv = getfenv(2)
    --                 for k2, v2 in pairs(preEnv) do
    --                     if v2 == t then
    --                         preEnv[k2] = v
    --                         break
    --                     end
    --                 end
    --             else
    --                 debug.setlocal(2, localId, v)
    --             end
    --         end
    --         this[k] = v
    --     end,
    --     __index = function(t, k)
    --         if k == 't' then return debug.getmetatable(t).t end
    --         return this[k]
    --     end,
    --     t = this
    -- })

    -- -- local meta = getmetatable(this)
    -- -- local ndx = meta.__newindex
    -- -- meta.__newindex = function (t, k, v)
    -- --     if k == 'value' then
    -- --         thisNUM.self = v
    -- --     end
    -- --     ndx(t, k, v)
    -- -- end
    -- -- setmetatable(this, meta)
    -- -- return thisNUM
    return this
end

return Color