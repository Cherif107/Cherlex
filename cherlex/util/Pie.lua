-- CODE BY SHADOW MARIO, DO NOT FORGET TO CREDIT
-- MAYBE ASK FOR HIS PERMISSION BEFORE YOU USE THIS (I DID)
local allowStart = false
local dialogueShit = {}
local dialogueSenpai = {}
local dialogueSenpaiAngry = {}
local dialogueSenpaiAngry2 = {}
local dialogueSenpaiSad = {}
local dialogueSenpaiGotit = {}
local dialogueSenpaiHuh = {}
local dialogueSenpaiIdea = {}
local dialogueSenpaiScritchScratch = {}
local dialogueSenpaiThink = {}
local dialogueBF = {}
local dialogueBFANGRY = {}
local dialogueBFUHH = {}
--DONT FORGET TO ADD THE PORTRAIT ABOVE AS WELL (ITS LIKE THE JSON OF THE PORTRAIT)

function onStartCountdown()
	if not allowStart and isStoryMode then
		doReturn = false
		startSenpaiCutscene('senpai', 'senpai');
		playMusic('Lunchbox', 1, true)
		doReturn = true
		
		if doReturn then
			setProperty('boyfriend.stunned', true)
			setProperty('inCutscene', true)
			return Function_Stop
		end
	end
	return Function_Continue
end

function onSongStart()
	if isStoryMode then
		setProperty('fakeN1.offset.y', -62)
		setProperty('fakeN2.offset.y', -62)
	else
		setProperty('fakeN1.offset.y', -67)
		setProperty('fakeN2.offset.y', -72)
	end
end

dialogueLineName = ''
dialogueLineType = ''
dialogueSound = 'pixelText'
dialogueSoundClick = 'clickText'

curDialogue = 0

dialogueOpened = false
dialogueStarted = false
dialogueEnded = false
dialogueGone = false
targetText = 'blah blah coolswag'
function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'start senpai dialogue' then
		allowStart = true
		addLuaSprite('bgFade', true)
		makeAnimatedLuaSprite('portraitLeft', 'weeb/senpaiPortrait', -20, 40)
		pixelThingie('portraitLeft', 5.4, true)
		addAnimationByPrefix('portraitLeft', 'enter', 'Senpai Portrait Enter', 24, false)
		setProperty('portraitLeft.visible', false)
		
		makeAnimatedLuaSprite('portraitLeft2', 'weeb/pixelUI/dialogueBox-senpaiMad', -20, 40)
		pixelThingie('portraitLeft2', 5.4, true)
		addAnimationByPrefix('portraitLeft2', 'enter', 'SENPAI ANGRY IMPACT SPEECH', 24, false)
		setProperty('portraitLeft2.visible', false)
		
		makeAnimatedLuaSprite('portraitLeft3', 'weeb/pixelUI/dialogueBox-senpaiAngry', -20, 40)
		pixelThingie('portraitLeft3', 5.4, true)
		addAnimationByPrefix('portraitLeft3', 'enter', 'SENPAI ANGRY IMPACT SPEECH', 24, false)
		setProperty('portraitLeft3.visible', false)
		
		makeAnimatedLuaSprite('portraitLeft4', 'weeb/pixelUI/dialogueBox-senpaiSad', -20, 40)
		pixelThingie('portraitLeft4', 5.4, true)
		addAnimationByPrefix('portraitLeft4', 'enter', 'SENPAI ANGRY IMPACT SPEECH', 24, false)
		setProperty('portraitLeft4.visible', false)
		
		makeAnimatedLuaSprite('portraitLeft5', 'weeb/SenpaiGotit', 150, 105);
		pixelThingie('portraitLeft5', 5.4, true);
		addAnimationByPrefix('portraitLeft5', 'enter', 'Senpai Portrait Enter', 24, false);
		setProperty('portraitLeft5.visible', false);
		
		makeAnimatedLuaSprite('portraitLeft6', 'weeb/SenpaiHuh', 150, 130);
		pixelThingie('portraitLeft6', 5.4, true);
		addAnimationByPrefix('portraitLeft6', 'enter', 'Senpai Portrait Enter', 24, false);
		setProperty('portraitLeft6.visible', false);
		
		makeAnimatedLuaSprite('portraitLeft7', 'weeb/Senpaiidea', 150, 105);
		pixelThingie('portraitLeft7', 5.4, true);
		addAnimationByPrefix('portraitLeft7', 'enter', 'Senpai Portrait Enter', 24, false);
		setProperty('portraitLeft7.visible', false);
		
		makeAnimatedLuaSprite('portraitLeft8', 'weeb/Senpaiscritchstracth', 140, 110);
		pixelThingie('portraitLeft8', 5.4, true);
		addAnimationByPrefix('portraitLeft8', 'enter', 'Senpai Portrait Enter', 24, false);
		setProperty('portraitLeft8.visible', false);
		
		makeAnimatedLuaSprite('portraitLeft9', 'weeb/SenpaiThink', 150, 105);
		pixelThingie('portraitLeft9', 5.4, true);
		addAnimationByPrefix('portraitLeft9', 'enter', 'Senpai Portrait Enter', 24, false);
		setProperty('portraitLeft9.visible', false);
		
		makeAnimatedLuaSprite('portraitRight', 'weeb/bfPortrait', -20, 40)
		pixelThingie('portraitRight', 5.4, true)
		addAnimationByPrefix('portraitRight', 'enter', 'Boyfriend portrait enter', 24, false)
		setProperty('portraitRight.visible', false)
		
		makeAnimatedLuaSprite('portraitRight2', 'weeb/bfangry', -20, 40)
		pixelThingie('portraitRight', 5.4, true)
		addAnimationByPrefix('portraitRight', 'enter', 'Portrait Enter', 24, false)
		setProperty('portraitRight.visible', false)
		
		makeAnimatedLuaSprite('portraitRight3', 'weeb/bfwhat', -20, 40)
		pixelThingie('portraitRight', 5.4, true)
		addAnimationByPrefix('portraitRight', 'enter', 'Portrait Enter', 24, false)
		setProperty('portraitRight.visible', false)
		
		----------------------------------------------------------------------------------------------------------------------------------------------------PASTE PORTRAITS ABOVE
		
		if dialogueLineType == 'thorns' then
			spiritImage = 'weeb/spiritFaceForward'
			makeLuaSprite('spiritUgly', spiritImage, 320, 170)
			pixelThingie('spiritUgly', 6, false)
		end
		
		if dialogueLineType == 'thorns' then
			boxImage = 'weeb/pixelUI/dialogueBox-evil'
			
			makeAnimatedLuaSprite('dialogueBox', boxImage, -20, 45)
			addAnimationByPrefix('dialogueBox', 'normalOpen', 'Spirit Textbox spawn', 24, false)
			addAnimationByIndices('dialogueBox', 'normal', 'Spirit Textbox spawn instance 1', '11', 24)
		elseif dialogueLineType == 'roses' then
			boxImage = 'weeb/pixelUI/dialogueBox-senpaiMad'
			
			makeAnimatedLuaSprite('dialogueBox', 'weeb/pixelUI/dialogueBox-senpaiMad', -20, 45)
			addAnimationByPrefix('dialogueBox', 'normalOpen', 'SENPAI ANGRY IMPACT SPEECH', 24, false)
			addAnimationByIndices('dialogueBox', 'normal', 'SENPAI ANGRY IMPACT SPEECH instance 1', '4', 24)
			addAnimationByPrefix('dialogueBox', 'noPortrait', 'SENPAI ANGRY NS', 24, false)
		else
			makeAnimatedLuaSprite('dialogueBox', 'weeb/pixelUI/dialogueBox-pixel', -20, 45)
			addAnimationByPrefix('dialogueBox', 'normalOpen', 'Text Box Appear', 24, false)
			addAnimationByIndices('dialogueBox', 'normal', 'Text Box Appear instance 1', '4', 24)
		end
		pixelThingie('dialogueBox', 5.4, true)
		
		screenCenter('dialogueBox', 'x')
		screenCenter('portraitLeft', 'x')
		
		handImage = 'weeb/pixelUI/hand_textbox'
		
		makeLuaSprite('handSelect', handImage, 1042, 590)
		pixelThingie('handSelect', 5.4, true)
		setProperty('handSelect.visible', false)
		
		makeLuaText('dropText', '', screenWidth * 0.6, 242, 502)
		setTextFont('dropText', 'pixel.otf')
		setTextColor('dropText', 'D89494')
		setTextBorder('dropText', 0, 0)
		setTextSize('dropText', 32)
		setTextAlignment('dropText', 'left')
		addLuaText('dropText')
		
		makeLuaText('swagDialogue', '', screenWidth * 0.6, 240, 500)
		setTextFont('swagDialogue', 'pixel.otf')
		setTextColor('swagDialogue', '3F2021')
		setTextBorder('swagDialogue', 0, 0)
		setTextSize('swagDialogue', 32)
		setTextAlignment('swagDialogue', 'left')
		addLuaText('swagDialogue')
		
		if dialogueLineType == 'thorns' then
			setTextColor('dropText', '000000')
			setTextColor('swagDialogue', 'FFFFFF')
		end
		
	elseif tag == 'remove black' then
		setProperty('senpaiBlack.alpha', getProperty('senpaiBlack.alpha') - 0.15)
	elseif tag == 'increase bg fade' then
		newAlpha = getProperty('bgFade.alpha') + (1 / 5) * 0.7
		if newAlpha > 0.7 then
			newAlpha = 0.7
		end
		setProperty('bgFade.alpha', newAlpha)
	elseif tag == 'add dialogue letter' then
		setTextString('swagDialogue', string.sub(targetText, 0, (loops - loopsLeft)))
		playSound(dialogueSound, 0.8)
		
		if loopsLeft == 0 then
			--debugPrint('Text finished!')
			setProperty('handSelect.visible', true)
			dialogueEnded = true
		end
	elseif tag == 'end dialogue thing' then
		newAlpha = loopsLeft / 5
		cancelTimer('increase bg fade')
		setProperty('bgFade.alpha', newAlpha * 0.7)
		setProperty('dialogueBox.alpha', newAlpha)
		setProperty('swagDialogue.alpha', newAlpha)
		setProperty('dropText.alpha', newAlpha)
		setProperty('handSelect.alpha', newAlpha)
	elseif tag == 'start countdown thing' then
		allowStart = true
		removeLuaSprite('bgFade')
		removeLuaSprite('dialogueBox')
		removeLuaSprite('dialogueBox2')
		removeLuaSprite('handSelect')
		removeLuaText('swagDialogue')
		removeLuaText('dropText')
		setProperty('inCutscene', false)
		setProperty('boyfriend.stunned', false)
		startCountdown()
		dialogueGone = true
		
		removeLuaSprite('spiritUgly')
	elseif tag == 'make senpai visible' then
		setProperty('senpaiEvil.alpha', getProperty('senpaiEvil.alpha') + 0.15)
		if loopsLeft == 0 then
			playSound('Senpai_Dies')
			objectPlayAnimation('senpaiEvil', 'die')
			runTimer('start flash', 3.2)
		end
	elseif tag == 'start flash' then
		cameraFade('other', 'FFFFFF', 1.6, true)
	end
end

isEnding = false
function onUpdate(elapsed)
	if dialogueGone then
		return
	end
	
	if getProperty('dialogueBox.animation.curAnim.name') == 'normalOpen' and getProperty('dialogueBox.animation.curAnim.finished') then
		objectPlayAnimation('dialogueBox', 'normal')
		dialogueOpened = true
	end
	
	if dialogueOpened and not (dialogueStarted) then
		startDialogueThing()
		objectPlayAnimation('portraitLeft', 'enter', true)
		dialogueStarted = true
	end
	
	if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.ENTER') == true then
		if dialogueEnded then
			curDialogue = curDialogue + 1
			if curDialogue > table.maxn(dialogueShit) then
				if not isEnding then
					removeLuaSprite('portraitLeft')
					removeLuaSprite('portraitLeft2')
					removeLuaSprite('portraitLeft3')
					removeLuaSprite('portraitLeft4')
					removeLuaSprite('portraitLeft5')
					removeLuaSprite('portraitLeft6')
					removeLuaSprite('portraitLeft7')
					removeLuaSprite('portraitLeft8')
					removeLuaSprite('portraitLeft9')
					removeLuaSprite('portraitRight')
					removeLuaSprite('portraitRight2')
					removeLuaSprite('portraitRight3')
					runTimer('end dialogue thing', 0.2, 5)
					runTimer('start countdown thing', 1.5)
					soundFadeOut(nil, 1.5)
					isEnding = true
					playSound(dialogueSoundClick, 0.8)
				end
			else
				startDialogueThing()
				playSound(dialogueSoundClick, 0.8)
			end
		elseif dialogueStarted then
			cancelTimer('add dialogue letter')
			onTimerCompleted('add dialogue letter', string.len(targetText), 0)
			playSound(dialogueSoundClick, 0.8)
		end
	end
	setTextString('dropText', getTextString('swagDialogue'))
end

function startDialogueThing()
	reloadDialogue()
	runTimer('add dialogue letter', 0.04, string.len(targetText))
end

----------------------------------------------------------------------------------------------------------------------------------------------------PORTRAIT CODE 1 BELOW

function reloadDialogue()
    curCharacterSenpai = dialogueSenpai[curDialogue]
	curCharacterSenpaiAngry = dialogueSenpaiAngry[curDialogue]
	curCharacterSenpaiAngry2 = dialogueSenpaiAngry2[curDialogue]
	curCharacterSenpaiSad = dialogueSenpaiSad[curDialogue]
	curCharacterSenpaiGotit = dialogueSenpaiGotit[curDialogue]
	curCharacterSenpaiHuh = dialogueSenpaiHuh[curDialogue]
	curCharacterSenpaiIdea = dialogueSenpaiIdea[curDialogue]
	curCharacterSenpaiScritchScratch = dialogueSenpaiScritchScratch[curDialogue]
	curCharacterSenpaiThink = dialogueSenpaiThink[curDialogue]
	curCharacterBF = dialogueBF[curDialogue]
	curCharacterBFANGRY = dialogueBFANGRY[curDialogue]
	curCharacterBFUHH = dialogueBFUHH[curDialogue]
	targetText = dialogueShit[curDialogue]
	
	----------------------------------------------------------------------------------------------------------------------------------------------------PORTRAIT CODE 1 ABOVE
	
	setTextString('dropText', '')
	setTextString('swagDialogue', '')
	setProperty('handSelect.visible', false)
	dialogueEnded = false
	
	
	----------------------------------------------------------------------------------------------------------------------------------------------------PORTRAIT CODE 2 BELOW
	
	if curCharacterSenpai then
		setProperty('portraitLeft.visible', false)
        setProperty('portraitLeft2.visible', false)
        setProperty('portraitLeft3.visible', false)
        setProperty('portraitLeft4.visible', false)
        setProperty('portraitLeft5.visible', false)
        setProperty('portraitLeft6.visible', false)
        setProperty('portraitLeft7.visible', false)
        setProperty('portraitLeft8.visible', false)
        setProperty('portraitLeft9.visible', false)
		setProperty('portraitRight.visible', false)
		setProperty('portraitRight2.visible', false)
		setProperty('portraitRight3.visible', false)
		if getProperty('portraitLeft.visible') == false then
			setProperty('portraitLeft.visible', true)
		end
		objectPlayAnimation('portraitLeft', 'enter')
		
		
	elseif curCharacterSenpaiAngry then
		setProperty('portraitLeft.visible', false)
        setProperty('portraitLeft2.visible', false)
        setProperty('portraitLeft3.visible', false)
        setProperty('portraitLeft4.visible', false)
        setProperty('portraitLeft5.visible', false)
        setProperty('portraitLeft6.visible', false)
        setProperty('portraitLeft7.visible', false)
        setProperty('portraitLeft8.visible', false)
        setProperty('portraitLeft9.visible', false)
		setProperty('portraitRight.visible', false)
		setProperty('portraitRight2.visible', false)
		setProperty('portraitRight3.visible', false)
		setProperty('dialogueBox.visible', false)
		if getProperty('portraitLeft2.visible') == false then
			setProperty('portraitLeft2.visible', true)
		end
		objectPlayAnimation('portraitLeft', 'enter')
		
		
	elseif curCharacterSenpaiAngry2 then
		setProperty('portraitLeft.visible', false)
        setProperty('portraitLeft2.visible', false)
        setProperty('portraitLeft3.visible', false)
        setProperty('portraitLeft4.visible', false)
        setProperty('portraitLeft5.visible', false)
        setProperty('portraitLeft6.visible', false)
        setProperty('portraitLeft7.visible', false)
        setProperty('portraitLeft8.visible', false)
        setProperty('portraitLeft9.visible', false)
		setProperty('portraitRight.visible', false)
		setProperty('portraitRight2.visible', false)
		setProperty('portraitRight3.visible', false)
		setProperty('dialogueBox.visible', false)
		if getProperty('portraitLeft3.visible') == false then
			setProperty('portraitLeft3.visible', true)
		end
		objectPlayAnimation('portraitLeft', 'enter')
		
		
	elseif curCharacterSenpaiSad then
		setProperty('portraitLeft.visible', false)
        setProperty('portraitLeft2.visible', false)
        setProperty('portraitLeft3.visible', false)
        setProperty('portraitLeft4.visible', false)
        setProperty('portraitLeft5.visible', false)
        setProperty('portraitLeft6.visible', false)
        setProperty('portraitLeft7.visible', false)
        setProperty('portraitLeft8.visible', false)
        setProperty('portraitLeft9.visible', false)
		setProperty('portraitRight.visible', false)
		setProperty('portraitRight2.visible', false)
		setProperty('portraitRight3.visible', false)
		setProperty('dialogueBox.visible', false)
		if getProperty('portraitLeft4.visible') == false then
			setProperty('portraitLeft4.visible', true)
		end
		objectPlayAnimation('portraitLeft', 'enter')
		
		elseif curCharacterSenpaiGotit then
		setProperty('portraitLeft.visible', false)
        setProperty('portraitLeft2.visible', false)
        setProperty('portraitLeft3.visible', false)
        setProperty('portraitLeft4.visible', false)
        setProperty('portraitLeft5.visible', false)
        setProperty('portraitLeft6.visible', false)
        setProperty('portraitLeft7.visible', false)
        setProperty('portraitLeft8.visible', false)
        setProperty('portraitLeft9.visible', false)
		setProperty('portraitRight.visible', false)
		setProperty('portraitRight2.visible', false)
		setProperty('portraitRight3.visible', false)
		setProperty('dialogueBox.visible', true)
		if getProperty('portraitLeft5.visible') == false then
			setProperty('portraitLeft5.visible', true)
		end
		objectPlayAnimation('portraitLeft', 'enter')
		
		elseif curCharacterSenpaiHuh then
		setProperty('portraitLeft.visible', false)
        setProperty('portraitLeft2.visible', false)
        setProperty('portraitLeft3.visible', false)
        setProperty('portraitLeft4.visible', false)
        setProperty('portraitLeft5.visible', false)
        setProperty('portraitLeft6.visible', false)
        setProperty('portraitLeft7.visible', false)
        setProperty('portraitLeft8.visible', false)
        setProperty('portraitLeft9.visible', false)
		setProperty('portraitRight.visible', false)
		setProperty('portraitRight2.visible', false)
		setProperty('portraitRight3.visible', false)
		setProperty('dialogueBox.visible', true)
		if getProperty('portraitLeft6.visible') == false then
			setProperty('portraitLeft6.visible', true)
		end
		objectPlayAnimation('portraitLeft', 'enter')
		
		elseif curCharacterSenpaiIdea then
		setProperty('portraitLeft.visible', false)
        setProperty('portraitLeft2.visible', false)
        setProperty('portraitLeft3.visible', false)
        setProperty('portraitLeft4.visible', false)
        setProperty('portraitLeft5.visible', false)
        setProperty('portraitLeft6.visible', false)
        setProperty('portraitLeft7.visible', false)
        setProperty('portraitLeft8.visible', false)
        setProperty('portraitLeft9.visible', false)
		setProperty('portraitRight.visible', false)
		setProperty('portraitRight2.visible', false)
		setProperty('portraitRight3.visible', false)
		setProperty('dialogueBox.visible', true)
		if getProperty('portraitLeft7.visible') == false then
			setProperty('portraitLeft7.visible', true)
		end
		objectPlayAnimation('portraitLeft', 'enter')
		
		elseif curCharacterSenpaiScritchScratch then
		setProperty('portraitLeft.visible', false)
        setProperty('portraitLeft2.visible', false)
        setProperty('portraitLeft3.visible', false)
        setProperty('portraitLeft4.visible', false)
        setProperty('portraitLeft5.visible', false)
        setProperty('portraitLeft6.visible', false)
        setProperty('portraitLeft7.visible', false)
        setProperty('portraitLeft8.visible', false)
        setProperty('portraitLeft9.visible', false)
		setProperty('portraitRight.visible', false)
		setProperty('portraitRight2.visible', false)
		setProperty('dialogueBox.visible', true)
		setProperty('portraitRight3.visible', false)
		if getProperty('portraitLeft8.visible') == false then
			setProperty('portraitLeft8.visible', true)
		end
		objectPlayAnimation('portraitLeft', 'enter')
		
		elseif curCharacterSenpaiThink then
		setProperty('portraitLeft.visible', false)
        setProperty('portraitLeft2.visible', false)
        setProperty('portraitLeft3.visible', false)
        setProperty('portraitLeft4.visible', false)
        setProperty('portraitLeft5.visible', false)
        setProperty('portraitLeft6.visible', false)
        setProperty('portraitLeft7.visible', false)
        setProperty('portraitLeft8.visible', false)
        setProperty('portraitLeft9.visible', false)
		setProperty('portraitRight.visible', false)
		setProperty('portraitRight2.visible', false)
		setProperty('portraitRight3.visible', false)
		setProperty('dialogueBox.visible', true)
		if getProperty('portraitLeft9.visible') == false then
			setProperty('portraitLeft9.visible', true)
		end
		objectPlayAnimation('portraitLeft', 'enter')
		
	elseif curCharacterBF then
	setProperty('portraitLeft.visible', false)
        setProperty('portraitLeft2.visible', false)
        setProperty('portraitLeft3.visible', false)
        setProperty('portraitLeft4.visible', false)
        setProperty('portraitLeft5.visible', false)
        setProperty('portraitLeft6.visible', false)
        setProperty('portraitLeft7.visible', false)
        setProperty('portraitLeft8.visible', false)
        setProperty('portraitLeft9.visible', false)
	setProperty('portraitRight2.visible', false)
		setProperty('portraitRight3.visible', false)
	if getProperty('portraitRight.visible') == false then
		setProperty('portraitRight.visible', true)
		end
		if getProperty('dialogueBox.visible') == false then
			setProperty('dialogueBox.visible', true)
	
	objectPlayAnimation('portraitRight', 'enter', true)
	end
    elseif curCharacterBFANGRY then
	setProperty('portraitLeft.visible', false)
        setProperty('portraitLeft2.visible', false)
        setProperty('portraitLeft3.visible', false)
        setProperty('portraitLeft4.visible', false)
        setProperty('portraitLeft5.visible', false)
        setProperty('portraitLeft6.visible', false)
        setProperty('portraitLeft7.visible', false)
        setProperty('portraitLeft8.visible', false)
        setProperty('portraitLeft9.visible', false)
	setProperty('portraitRight2.visible', false)
		setProperty('portraitRight3.visible', false)
	if getProperty('portraitRight2.visible') == false then
		setProperty('portraitRight2.visible', true)
		end
		if getProperty('dialogueBox.visible') == false then
			setProperty('dialogueBox.visible', true)
	
	objectPlayAnimation('portraitRight', 'enter', true)
	end
    elseif curCharacterBFUHH then
	setProperty('portraitLeft.visible', false)
        setProperty('portraitLeft2.visible', false)
        setProperty('portraitLeft3.visible', false)
        setProperty('portraitLeft4.visible', false)
        setProperty('portraitLeft5.visible', false)
        setProperty('portraitLeft6.visible', false)
        setProperty('portraitLeft7.visible', false)
        setProperty('portraitLeft8.visible', false)
        setProperty('portraitLeft9.visible', false)
	setProperty('portraitRight2.visible', false)
		setProperty('portraitRight3.visible', false)
	if getProperty('portraitRight3.visible') == false then
		setProperty('portraitRight3.visible', true)
		end
		if getProperty('dialogueBox.visible') == false then
			setProperty('dialogueBox.visible', true)
	
	objectPlayAnimation('portraitRight', 'enter', true)
	end
end
end

----------------------------------------------------------------------------------------------------------------------------------------------------PORTRAIT CODE 2 ABOVE

function startSenpaiCutscene(dialogueType, type)
	makeLuaSprite('bgFade', nil, -200, -200)
	makeGraphic('bgFade', screenWidth * 1.3, screenHeight * 1.3, 'B3DFD8')
	setProperty('bgFade.alpha', 0)
	setScrollFactor('bgFade', 0, 0)
	setObjectCamera('bgFade', 'hud')
	runTimer('increase bg fade', 0.83, 5)
	
	
	
	if type == 'senpai' then
		makeLuaSprite('senpaiBlack', nil, -100, -100)
		makeGraphic('senpaiBlack', screenWidth * 2, screenHeight * 2, '000000')
		setScrollFactor('senpaiBlack', 0, 0)
		addLuaSprite('senpaiBlack', true)
		runTimer('remove black', 0.3, 7)
	elseif type == 'thorns' then
		makeLuaSprite('senpaiBlack', nil, -100, -100)
		makeGraphic('senpaiBlack', screenWidth * 2, screenHeight * 2, 'FF1B31')
		setScrollFactor('senpaiBlack', 0, 0)
		addLuaSprite('senpaiBlack', true)
		
		assetName = 'weeb/senpaiCrazy'
		
		makeAnimatedLuaSprite('senpaiEvil', assetName, 0, 0)
		addAnimationByIndices('senpaiEvil', 'idle', 'Senpai Pre Explosion instance 1', '0', 24)
		addAnimationByPrefix('senpaiEvil', 'die', 'Senpai Pre Explosion', 24, false)
		scaleObject('senpaiEvil', 6, 6)
		setScrollFactor('senpaiEvil', 0, 0)
		screenCenter('senpaiEvil')
		setProperty('senpaiEvil.x', getProperty('senpaiEvil.x') + 300)
		setProperty('senpaiEvil.antialiasing', false)
		setProperty('senpaiEvil.alpha', 0)
		addLuaSprite('senpaiEvil', true)
		
		setProperty('camHUD.visible', false)
		runTimer('make senpai visible', 0.3, 7)
	end
	
	----------------------------------------------------------------------------------------------------------------------------------------------------DIALOGUE CODE BELOW
	
	dialogueLineName = dialogueType
	dialogueLineType = type
	if dialogueType == 'senpai' then
		dialogueShit[0] = 'a.'
		dialogueSenpai[0] = true
		dialogueShit[1] = 'b.'
		dialogueSenpaiAngry[1] = true
        dialogueShit[2] = 'c.'
		dialogueSenpaiAngry2[2] = true
        dialogueShit[3] = 'd.'
		dialogueSenpaiSad[3] = true
        dialogueShit[4] = 'e.'
		dialogueSenpaiGotit[4] = true
        dialogueShit[5] = 'f.'
		dialogueSenpaiHuh[5] = true
        dialogueShit[6] = 'g.'
		dialogueSenpaiIdea[6] = true
        dialogueShit[7] = 'h.'
		dialogueSenpaiScritchScratch[7] = true
        dialogueShit[8] = 'i.'
		dialogueSenpaiThink[8] = true
		
	end
	
	----------------------------------------------------------------------------------------------------------------------------------------------------DIALOGUE CODE ABOVE
	
	timerTime = 2 --stupid name
	if type == 'thorns' then
		timerTime = 9.2
	end
	runTimer('start senpai dialogue', timerTime)
end

function pixelThingie(tag, scale, doUpdateHitbox)
	if doUpdateHitbox then
		scaleObject(tag, scale, scale)
	else
		setProperty(tag..'.scale.x', scale)
		setProperty(tag..'.scale.y', scale)
	end
	setScrollFactor(tag, 0, 0)
	setObjectCamera(tag, 'hud')
	setProperty(tag..'.antialiasing', false)
	addLuaSprite(tag, true)
end