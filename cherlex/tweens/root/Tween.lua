local Class = require 'cherlex.Class'
local Type = require 'cherlex.tweens.Type'
local Ease = require 'cherlex.tweens.Ease'
-- local Stage = require 'cherlex.Event'

---@class TweenValue
---@field public started boolean if the Tween has started or not
---@field public finished boolean if the Tween is finished or not
---@field public paused boolean if the Tween is paused or not
---@field allowFinish boolean a boolean that makes you choose if the tween stops or not
---@field index integer The Index of the tween in the tween array
---@field public secondsSinceStart number seconds since the Tween has started
---@field public tweenCount integer how many times the Tween has played
---@field public scale number a value between 0 and 1
---@field public duration number Tween duration
---@field public ease Ease Tween Ease
---@field public type Type Tween Type
---@field backwards boolean Checks if the tween will play backwards

---@class Tween_Root:Class Main Tween Class
local Tween_Root = Class()
Tween_Root.tweens = {}

Tween_Root.field('started', false)
Tween_Root.field('finished', false)
Tween_Root.field('paused', false)
Tween_Root.field('allowFinish', true)
Tween_Root.field('index', '?')
Tween_Root.field('secondsSinceStart', 0)
Tween_Root.field('tweenCount', 0)
Tween_Root.field('scale', 0)
Tween_Root.field('duration', 0)
Tween_Root.field('ease', Ease.linear)
Tween_Root.field('type', Type.PERSIST)
Tween_Root.field('backwards', false)

---@param Duration number Tween Duration
---@param Options table<string, any> Tween Options
---@param TweenUpdate function Tween update function
---@return TweenValue
Tween_Root.new = function(Duration, Options, TweenUpdate)
    Options = Options or {}
    ---@type TweenValue
    local this = Tween_Root.create()

    this.index = #Tween_Root.tweens+1
    this.duration = Duration or 0
    this.ease = Options.ease or Ease.linear
    this.type = Options.type or Type.PERSIST
    this.backwards = Options.Type == Type.BACKWARD

    this.onComplete = Options.onComplete
    this.onCancel = Options.onCancel
    this.onStop = Options.onStop
    this.onStart = Options.onStart
    this.onPause = Options.onPause
    this.onResume = Options.onResume
    this.onUpdate = Options.onUpdate

    this.update = TweenUpdate
    this.replay = function() this.secondsSinceStart = 0 this.finished = false end
    this.pause = function() this.paused = true if this.onPause ~= nil then this.onPause() end end
    this.resume = function() this.paused = false if this.onResume ~= nil then this.onResume() end end
    this.start = function() this.started = true if this.onStart ~= nil then this.onStart() end end
    this.stop = function()
        this.finished = true
        if this.onStop ~= nil then this.onStop() end
        if this.type == Type.ONESHOT then Tween_Root.tweens[this.index] = nil this = nil end
    end
    this.cancel = function()
        this.finished = true
        if this.onCancel ~= nil then this.onCancel() end
        if this.type == Type.ONESHOT then Tween_Root.tweens[this.index] = nil this = nil end
    end

    Tween_Root.tweens[this.index] = this
    return this
end

local o = onUpdate
onUpdate = function(el) 
    if o then o(el) end
    for _, tween in next, Tween_Root.tweens, nil do
        if not tween.finished and not tween.paused and tween.started then
            tween.secondsSinceStart = math.min(tween.secondsSinceStart + el, tween.duration)
            tween.scale = tween.ease(math.max((tween.secondsSinceStart), 0) / tween.duration)

            if tween.backwards then tween.scale = 1-tween.scale end
            if tween.update ~= nil then tween.update(tween, tween.scale, el) end
            if tween.onUpdate ~= nil then tween.onUpdate(tween, el) end

            if tween.secondsSinceStart >= tween.duration then
                if tween.type == Type.PINGPONG then
                    tween.secondsSinceStart = 0
                    tween.backwards = not tween.backwards
                    tween.tweenCount = tween.tweenCount + 1
                elseif tween.type == Type.LOOPING then
                    tween.secondsSinceStart = 0
                    tween.tweenCount = tween.tweenCount + 1
                else
                    if tween.allowFinish then
                        tween.tweenCount = tween.tweenCount + 1
                        tween.finished = true
                    end
                end
                if tween.onComplete ~= nil then
                    tween.onComplete(tween)
                end
                if tween.allowFinish then
                    if tween.type == Type.ONESHOT then
                        Tween_Root[_] = nil
                    end
                end
            end
        end
    end
end

return Tween_Root