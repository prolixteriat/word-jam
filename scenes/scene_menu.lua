
-- -----------------------------------------------------------------------------------

local composer = require( "composer" )
local col = require( "data.colors" )
local hi = require( "game.highscores" )
local opt = require( "game.options" )
local sfx = require( "lib.sfx")
local snd = require( "game.sounds" )
local widget = require( "widget" )

-- -----------------------------------------------------------------------------------

local TAG = "scene_menu.lua"

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------

local filePath = "scenes/img/"

-- -----------------------------------------------------------------------------------
-- Local functions
-- -----------------------------------------------------------------------------------

local function gotoGame()
    snd.playSound( snd.sounds.click )
    composer.gotoScene( "scenes.scene_game", { time=800, effect="crossFade" } )
end

local function gotoHighScores()
    snd.playSound( snd.sounds.click )
    composer.gotoScene( "scenes.scene_highscores", { time=800, effect="crossFade" } )
end

local function gotoInstructions()
    snd.playSound( snd.sounds.click )
    composer.gotoScene( "scenes.scene_instructions", { time=800, effect="crossFade" } )
end

local function gotoOptions()
    snd.playSound( snd.sounds.click )
    composer.gotoScene( "scenes.scene_options", { time=800, effect="crossFade" } )
end

-- -----------------------------------------------------------------------------------
-- create a single letter tile

local ox, oy = display.screenOriginX, display.screenOriginY
local c, r   = 0, 0 -- counters for current column and row for title letters
local tileSize      -- forward declaration

local function makeLetter( letter )
      	
    local squareGroup = display.newGroup()
    local width, height = tileSize, tileSize  	

    squareGroup.x = ox + c*width + tileSize
    squareGroup.y = oy + 180 + r*height + r  
   	
   	squareGroup.width  = width - 2
   	squareGroup.height = height - 2
  	--   make background rectangle
  	local space = display.newRoundedRect(0, 0, width-2, height-2, width * 0.10)
  	space:setFillColor( unpack(col.colIvory) ) 
  	--   make text character
  	piece = display.newText(letter, 0, 0, opt.defaultFont, 70)
  	piece:setFillColor( unpack(col.colTileText) ) 
  	squareGroup:insert( space )
  	squareGroup:insert( piece )
  	return squareGroup
  end

-- -----------------------------------------------------------------------------------
-- create tiles representing a single word

local function makeWord( group, word )

	for k, v in string.gmatch( word, "." ) do 
		c = c + 1
		local tile = makeLetter( k )
		group:insert( tile )
	end
end

-- -----------------------------------------------------------------------------------
-- Setup scene background for menu and instructions scenes

local function showBackground( sceneGroup )

	--[[	
	tileSize = display.actualContentWidth / 6 

	  c = -1
    makeWord( sceneGroup, "WORD")
    c = 0
    r = r + 1.5
    makeWord( sceneGroup, "JAM")
	--]]
    

	local background = display.newImageRect( sceneGroup, filePath .. "background.jpg", 900, 1600 )
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    tileSize = display.actualContentWidth / 6 

    c = -1
    makeWord( sceneGroup, "WORD")
    c = 0
    r = r + 1.5
    makeWord( sceneGroup, "JAM")
    
end

-- -----------------------------------------------------------------------------------
-- Show first run message

local function showFirstRun()

	local options = {
    	isModal = true,
    	effect  = "fade",
    	time    = 400,
    	params  = {
    				helpID = "firstRun"
    			  }
	}
 	composer.showOverlay( "scenes.helpoverlay", options )
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
-- create()

function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	showBackground( sceneGroup )
	snd.initAudio()
	opt.initScores()
	opt.loadGameOptions()
	hi.loadHighScores()
	
	local fontSize = opt.defaultFontSize
	local textY = display.contentCenterY + fontSize 

	playButton = widget.newButton({
		defaultFile = filePath .. "buttons/play.png",
		overFile = filePath .. "buttons/play-over.png",
		-- width = 380, height = 200,
		width = 285, height = 150,
		x = display.contentCenterX, 
		y = textY,
		onRelease = gotoGame
	})

	sceneGroup:insert( playButton )

 	sfx.bounce( playButton, 0.05, 1000 )
 	
	local textColour = { 0.8, 0.8, 0.1 }
    textY = playButton.y + playButton.height + fontSize * 2
    fontSize = fontSize * 0.8
	local highScoresButton = display.newText( sceneGroup, "High Score", display.contentCenterX, textY, opt.defaultFont, fontSize )
	highScoresButton:setFillColor( unpack(textColour) )	

	textY = textY + fontSize * 3
    local optionsButton = display.newText( sceneGroup, "Options", display.contentCenterX, textY, opt.defaultFont, fontSize )
    optionsButton:setFillColor( unpack(textColour) )	

    textY = textY + fontSize * 3
    local instructionsButton = display.newText( sceneGroup, "Instructions", display.contentCenterX, textY, opt.defaultFont, fontSize )
    instructionsButton:setFillColor( unpack(textColour) )	

	-- playButton:addEventListener( "tap", gotoGame )
    highScoresButton:addEventListener( "tap", gotoHighScores )	
	optionsButton:addEventListener( "tap", gotoOptions )
    instructionsButton:addEventListener( "tap", gotoInstructions )
end

-- -----------------------------------------------------------------------------------
-- show()

function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
		if( hi.highScore.gameCount == 0 ) then 
			showFirstRun()
		end
	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end

-- -----------------------------------------------------------------------------------
-- hide()

function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end

-- -----------------------------------------------------------------------------------
-- destroy()

function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
	snd.disposeAudio()
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene

-- -----------------------------------------------------------------------------------
