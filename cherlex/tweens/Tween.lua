local TweenVariable = require 'cherlex.tweens.Variable'
local TweenNumber = require 'cherlex.tweens.Number'
local TweenColor = require 'cherlex.tweens.Color'
local CircularMotion = require 'cherlex.motion.Circular'
local LinearMotion = require 'cherlex.motion.Linear'

---@class Tween a Tween callback table 
---@field tween TweenVariable Tween Variable function
---@field num TweenNumber Tween Number function
---@field number TweenNumber Tween Number function
---@field color TweenColor Tween Color function
---@field circularMotion CircularMotion Circular Motion Tween
---@field linearMotion LinearMotion Linear Motion Tween
local Tween = {
    tween = TweenVariable,
    num = TweenNumber,
    number = TweenNumber,
    color = TweenColor,
    circularMotion = CircularMotion,
    linearMotion = LinearMotion
}

return Tween