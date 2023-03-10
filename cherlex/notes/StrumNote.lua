local Sprite = require 'cherlex.Sprite'
local Game = require 'cherlex.Game'

local function switch(m, f)
    for x, fun in pairs(f) do
        if x == m then return fun() end
    end
end

---@class StrumNote:Sprite a class for making strum notes
local StrumNote = Sprite:copy()

StrumNote.field('texture', 'NOTE_assets', nil, function(v, t) return v, t.reloadNote() end)
StrumNote.field('resetAnim', 0)
StrumNote.field('noteData', 0)
StrumNote.field('direction', 90)
StrumNote.field('downScroll', false)
StrumNote.field('player', 'boyfriend')

---@return StrumNote
StrumNote.new = function (x, y, noteData, player)
    local this = Sprite.new(nil, x, y)
    this.noteData = noteData or 0
    this.player = player or 'boyfriend'

    this._set('playNoteAnim', function(anim, force)
        this.animation.play(anim, force)
        this.centerOffsets()
        this.centerOrigin()

        if this.animation.fieldIsNull('curAnim') or this.animation.curAnim.name == 'static' then
            if this.animation.curAnim.name == 'confirm' then
                this.centerOrigin()
            end
        end
    end)
    this._set('reloadNote', function()
        local lastAnim = nil
        if not this.animation.fieldIsNull('curAnim') then
            lastAnim = this.animation.curAnim.name
        end

        this.frames = this.texture

        this.antialiasing = Game.ClientPrefs.globalAntialiasing
        this.setGraphicSize(math.floor(this.width * 0.7))

        switch(math.abs(this.noteData), {
            [0] = function()
                this.animation.addByPrefix('static', 'arrowLEFT')
                this.animation.addByPrefix('pressed', 'left press', 24, false)
                this.animation.addByPrefix('confirm', 'left confirm', 24, false)
                this.animation.addByPrefix('purple', 'arrowLEFT')
            end,
            [1] = function()
                this.animation.addByPrefix('static', 'arrowDOWN');
                this.animation.addByPrefix('pressed', 'down press', 24, false);
                this.animation.addByPrefix('confirm', 'down confirm', 24, false);
                this.animation.addByPrefix('blue', 'arrowDOWN')
            end,
            [2] = function()
                this.animation.addByPrefix('static', 'arrowUP');
                this.animation.addByPrefix('pressed', 'up press', 24, false);
                this.animation.addByPrefix('confirm', 'up confirm', 24, false);
                this.animation.addByPrefix('green', 'arrowUP')
            end,
            [3] = function()
                this.animation.addByPrefix('static', 'arrowRIGHT');
                this.animation.addByPrefix('pressed', 'right press', 24, false);
                this.animation.addByPrefix('confirm', 'right confirm', 24, false);
                this.animation.addByPrefix('red', 'arrowRIGHT')
        
            end
        })

        this.updateHitbox()
        if lastAnim ~= nil then
            this.playNoteAnim(lastAnim, true)
        end
    end)
    this.update = function(el)
		if this.resetAnim > 0 then
			this.resetAnim = this.resetAnim - el
			if this.resetAnim <= 0 then
				this.playNoteAnim('static');
				this.resetAnim = 0;
            end
		end

		if(this.animation.curAnim.name == 'confirm') then
			this.centerOrigin();
        end
    end

    if (Game.SONG.arrowSkin ~= nil and #Game.SONG.arrowSkin > 1) then
        this.texture = Game.SONG.arrowSkin
    end
    this.texture = 'NOTE_assets'

    return this
end

return StrumNote