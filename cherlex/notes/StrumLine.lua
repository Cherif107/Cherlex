local Game = require 'cherlex.Game'
local Class = require 'cherlex.Class'
local StrumNote = require 'cherlex.notes.StrumNote'

---@class StrumLine:Class
local StrumLine = Class()

StrumLine.field('x', 0)
StrumLine.field('y', 0)
StrumLine.field('player', 'boyfriend')
StrumLine.field('notes', {})

StrumLine.new = function(x, y, noteType, player)
    local this = StrumLine.create()
    this.player = player

    this.add = function(t)
        for i = 1, #this.notes do
            this.notes[i].add(t)
        end
    end
    
    for i = 0, 3 do
        local strumArrow = StrumNote(x+(80*(i)), y, i, player)
        strumArrow.downScroll = Game.ClientPrefs.downScroll
        strumArrow.camera = 'other'
        this.notes[i+1] = strumArrow
    end
    return this
end

return StrumLine