---@class Event Modern Functions or whatever
local Event = {}
Event = {
    functions = setmetatable({
        onCreate = {onCreate or nil},
        onUpdate = {onUpdate or nil},
        onDestroy = {onDestroy or nil},

        onCountdownStarted = {onCountdownStarted or nil},
        onCountdownTick = {onCountdownTick or nil},

        onStartCountdown = {onStartCountdown or nil},
        onSongStart = {onSongStart or nil},
        onEndSong = {onEndSong or nil},

        onCreatePost = {onCreatePost or nil},
        onUpdatePost = {onUpdatePost or nil},

        onStepHit = {onStepHit or nil},
        onSectionHit = {onSectionHit or nil},
        onBeatHit = {onBeatHit or nil},

        onSpawnNote = {onSpawnNote or nil},
        onGhostTap = {onGhostTap or nil},
        onKeyRelease = {onKeyRelease or nil},
        onKeyPress = {onKeyPress or nil},
        
        goodNoteHit = {goodNoteHit or nil},
        opponentNoteHit = {opponentNoteHit or nil},
        
        noteMiss = {noteMiss or nil},
        noteMissPress = {noteMissPress or nil},

        onMoveCamera = {onMoveCamera or nil},
        
        onEvent = {onEvent or nil},
        eventEarlyTrigger = {eventEarlyTrigger or nil},

        onPause = {onPause or nil},
        onResume = {onResume or nil},
        
        onNextDialogue = {onNextDialogue or nil},
        onSkipDialogue = {onSkipDialogue or nil},

        onRecalculateRating = {onRecalculateRating or nil},

        onGameOver = {onGameOver or nil},
        onGameOverStart = {onGameOverStart or nil},
        onGameOverConfirm = {onGameOverConfirm or nil},

        onTweenCompleted = {onTweenCompleted or nil},
        onSoundFinished = {onSoundFinished or nil},
        onTimerCompleted = {onTimerCompleted or nil},
    }, {
        __newindex = function(t, k, v)
            if t[k] ~= nil then
                table.insert(t[k], v)
            else
                error('Event Error: Callback ('..k..') Does Not Exist')
            end
        end
    }),
    set = function(Function, NewCallBack, Tag)
        if Event.functions[Function] == nil then
            error('Event Error: Callback ('..Function..') Does Not Exist')
        else
            Tag = Tag or #Event.functions[Function] + 1
            Event.functions[Function][Tag] = NewCallBack 
        end
    end,
    remove = function(Function, Tag)
        if Event.functions[Function] == nil then
            error('Event Error: Callback ('..Function..') Does Not Exist')
        else
            Event.functions[Function][Tag] = nil
        end
    end,
    __callFunc = function(Function, ...)
        if Event.functions[Function] == nil then
            error('Event Error: Callback ('..Function..') Does Not Exist')
        else
            if #Event.functions[Function] > 0 then
                for index, func in pairs(Event.functions[Function]) do
                    func(...)
                end
            end
        end
    end
}

setmetatable(Event, {
    __newindex = function(t, k, v)
        local f = rawget(t, 'functions')
        if f[k] ~= nil then
            table.insert(f[k], v)
            return
        end
        rawset(t, k, v)
    end
})

function onCreate()
    Event.__callFunc('onCreate')
end
function onUpdate(elapsed)
    Event.__callFunc('onUpdate', elapsed)
end
function onDestroy()
    Event.__callFunc('onDestroy')
end

function onCountdownStarted()
    Event.__callFunc('onCountdownStarted')
end
function onCountdownTick(counter)
    Event.__callFunc('onCountdownTick', counter)
end

function onStartCountdown()
    Event.__callFunc('onStartCountdown')
end
function onSongStart()
    Event.__callFunc('onSongStart')
end
function onEndSong()
    Event.__callFunc('onEndSong')
end

function onCreatePost()
    Event.__callFunc('onCreatePost')
end
function onUpdatePost(elapsed)
    Event.__callFunc('onUpdatePost', elapsed)
end

function onStepHit()
    Event.__callFunc('onStepHit')
end
function onSectionHit()
    Event.__callFunc('onSectionHit')
end
function onBeatHit()
    Event.__callFunc('onBeatHit')
end

function onSpawnNote(id, noteData, noteType, isSustainNote)
    Event.__callFunc('onSpawnNote', id, noteData, noteType, isSustainNote)
end
function onGhostTap(noteData)
    Event.__callFunc('onGhostTap', noteData)
end
function onKeyRelease(key)
    Event.__callFunc('onKeyRelease', key)
end
function onKeyPress(key)
    Event.__callFunc('onKeyPress', key)
end

function goodNoteHit(id, noteData, noteType, isSustainNote)
    Event.__callFunc('goodNoteHit', id, noteData, noteType, isSustainNote)
end
function opponentNoteHit(id, noteData, noteType, isSustainNote)
    Event.__callFunc('opponentNoteHit', id, noteData, noteType, isSustainNote)
end

function noteMiss(id, noteData, noteType, isSustainNote)
    Event.__callFunc('noteMiss', id, noteData, noteType, isSustainNote)
end
function noteMissPress(noteData)
    Event.__callFunc('noteMissPress', noteData)
end

function onMoveCamera(focus)
    Event.__callFunc('onMoveCamera', focus)
end

function onEvent(name, value1, value2)
    Event.__callFunc('onEvent', name, value1, value2)
end
function eventEarlyTrigger(name)
    Event.__callFunc('eventEarlyTrigger', name)
end

function onPause()
    Event.__callFunc('onPause')
end
function onResume()
    Event.__callFunc('onResume')
end

function onNextDialogue(dialogueCount)
    Event.__callFunc('onNextDialogue', dialogueCount)
end
function onSkipDialogue(dialogueCount)
    Event.__callFunc('onSkipDialogue', dialogueCount)
end

function onRecalculateRating()
    Event.__callFunc('onRecalculateRating')
end

function onGameOver()
    Event.__callFunc('onGameOver')
end
function onGameOverStart()
    Event.__callFunc('onGameOverStart')
end
function onGameOverConfirm()
    Event.__callFunc('onGameOverConfirm')
end

function onTweenCompleted(tag)
    Event.__callFunc('onTweenCompleted', tag)
end
function onTimerCompleted(tag, loops, loopsLeft)
    Event.__callFunc('onTimerCompleted', tag, loops, loopsLeft)
end
function onSoundFinished(tag)
    Event.__callFunc('onSoundFinished', tag)
end

return Event