local ObjectA = require 'cherlex.Object'
local Mouse = require 'cherlex.input.Mouse'

local Object = function (a, b, c, d)
    return ObjectA(b, c, d, false, a)
end

---@class Game default game objects  (UNFINISHED)
local Game = setmetatable({
    boyfriend = Object('boyfriend', false, nil, true),
    gf = Object('gf', false, nil, true),
    dad = Object('dad', false, nil, true),

    timeBar = Object('timeBar', false, '', true),
    timeBarBG = Object('timeBarBG', false, nil, true),
    timeTxt = Object('timeTxt', false, nil, true),

    healthBar = Object('healthBar', false, nil, true),
    healthBarBG = Object('healthBarBG', false, nil, true),

    playerStrums = Object('playerStrums.members', false, nil, true),
    opponentStrums = Object('opponentStrums.members', false, nil, true),
    strumLineNotes = Object('strumLineNotes.members', false, nil, true),

    notes = Object('notes.members', false, nil, true),
    unspawnNotes = Object('unspawnNotes', false, nil, true),

    scoreTxt = Object('scoreTxt', false, nil, true),
    iconP1 = Object('iconP1', false, nil, true),
    iconP2 = Object('iconP2', false, nil, true),

    members = Object('members', false, nil, true),

    boyfriendGroup = Object('boyfriendGroup.members', false, nil, true),
    gfGroup = Object('gfGroup.members', false, nil, true),
    dadGroup = Object('dadGroup.members', false, nil, true),

    grpNoteSplashes = Object('grpNoteSplashes.members', false, nil, true),

    botplayTxt = Object('botplayTxt', false, nil, true),
    
    SONG = Object('SONG'),

    camGame = Object('camGame', false, nil, true),
    camHUD = Object('camHUD', false, nil, true),
    camOther = Object('camOther', false, nil, true),
    camFollow = Object('camFollow', false, nil, true),

    mouse = Mouse,
    camera = Object('camera', true, 'flixel.FlxG'),
    FlxG = Object('', true, 'flixel.FlxG'),
    Main = Object('', true, 'Main'),
    ClientPrefs = Object('', true, 'ClientPrefs'),
    Conductor = Object('', true, 'Conductor'),
    window = Object('application.window', true, 'openfl.Lib'),
}, {
    -- metatable for health strings floats and such
    __index = function(tbl, k)
        if rawget(tbl, k) ~= nil then return rawget(tbl, k) end
        return getProperty(k)
    end,
    __newindex = function(tbl, k, v)
        if rawget(tbl, k) ~= nil then return rawset(tbl, k, v) end
        return setProperty(k, v)
    end,
})

return Game