
-- -----------------------------------------------------------------------------------

local board = require( "game.board" )
local col = require( "data.colors" )
local composer = require( "composer" )
local dbg = require( "lib.debugging" )
local hlp = require( "lib.helper" )
local hi = require( "game.highscores" )
local menu = require( "scenes.menubar" )
local opt = require( "game.options" )
local over = require( "scenes.gameover" )
local sfx = require( "lib.sfx" )
local snd = require( "game.sounds" )
local widget = require( "widget" )
local words = require( "data.words" )

widget.setTheme( opt.widgetTheme )

-- -----------------------------------------------------------------------------------

local TAG = "scene_game.lua"

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- forward declarations 

local clockTime
local scoreGroup
local scoreHoriz
local scoreVerti
local scoreScore 
local scoreWords
local scrollFoundWords
local textFoundWords

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
-- Callback function called by board object ins response to a change in score.

local function updateScore( event )
    
    local phase = event.phase
	    
	-- only update if in the culling phase
    if( phase == "culling" ) then 
	    scoreHoriz.text = opt.score.numHorizontal
	    scoreScore.text = opt.score.score
	    scoreVerti.text = opt.score.numVertical
	    
	    -- re-populate the found words table to ensure most recent word is top of the list
	    local w = ""
	   	for i, v in ipairs( opt.score.foundWords ) do
	   		w = w .. v .. "\n"
	   	end
	   	textFoundWords.text = w
	   	scrollFoundWords:scrollTo( "top", { time = 400 } )

	   	hi.saveHighScores()
	end         
end

-- -----------------------------------------------------------------------------------
-- Callback function called by board object to update time text.

local function updateTime( event )

	local secs = event.secs
	 
    -- convert it to minutes and seconds
    local minutes = math.floor( secs / 60 )
    local seconds = secs % 60
	local timeDisplay = string.format( "%01d:%02d", minutes, seconds )
	     
    -- don't attempt to update if clockTime has not been created
    if( clockTime ) then 
    	clockTime.text = timeDisplay
    	if( secs == 10 ) then 
    		clockTime:setFillColor( 1, 0, 0 )
	   	end
    end
end

-- -----------------------------------------------------------------------------------
-- return the height/width of a single tile

local function getTileSize()

	local s = 0
	if( display.actualContentWidth < (display.actualContentHeight / 2) ) then 
		-- print(" opt 1")
		s = display.actualContentWidth / (opt.gameOptions.tileCount + 1)
	else
		-- print(" opt 1")
		s = display.actualContentHeight / (opt.gameOptions.tileCount + 8)
	end
	return s
end

-- -----------------------------------------------------------------------------------
-- Scene functions
-- -----------------------------------------------------------------------------------
-- handle game over

function scene:gameOver( reason )

-- Options table for the overlay scene "pause.lua"
	local options = {
    	isModal = true,
    	effect = "fade",
    	time = 400,
	}
 
	composer.showOverlay( "scenes.gameover", options )
	snd.playTimer( false )
	snd.playSound( snd.sounds.gameOver )
end

-- -----------------------------------------------------------------------------------
-- start a new game 

function scene:restartGame()

	opt.initScores()
	opt.restart = false
	if( clockTime ) then 
		clockTime:setFillColor( 1 )
		if( opt.gameOptions.timeLimit == 0 ) then 
			clockTime.text = ""
		end
	end
	board:restart( opt.gameOptions.tileCount, getTileSize() )
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
-- create()

function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
   	
   	-- menu bar
   	menubar = menu.createMenuBar( sceneGroup )

    -- board
	local tileSize = getTileSize()
	board = board.new( self, updateScore, updateTime, 
					  { rows = opt.gameOptions.tileCount, cols = opt.gameOptions.tileCount, width = tileSize, height = tileSize } )
	sceneGroup:insert( board )

	-- scores
	scoreGroup = display.newGroup()
	sceneGroup:insert( scoreGroup )
	local fontSize = 50
	local border = 30
	local textX = display.screenOriginX + border 
	-- local textY = display.screenOriginY + (opt.gameOptions.tileCount + 3.5) *tileSize -- original
	
	local oy = display.screenOriginY + (opt.gameOptions.tileCount + 1.5) *tileSize
	-- local textY = display.screenOriginY + (opt.gameOptions.tileCount + 2.5) *tileSize 
	local textColor = col.colIvory
    
    local textY = oy + fontSize * 4 
	local textHoriz  = display.newText( scoreGroup, "Horizontal: ", textX, textY, opt.defaultFont, fontSize )
	textHoriz.anchorX, textHoriz.anchorY = 0, 0
	scoreHoriz = display.newText( scoreGroup, "0", textHoriz.x + textHoriz.width + 10, textY, opt.defaultFont, fontSize )
	scoreHoriz.anchorX, scoreHoriz.anchorY = 0, 0
	scoreHoriz:setFillColor( unpack(textColor) )	

	-- textY = textY + fontSize * 2  -- original
    textY = textY + fontSize * 1.5
    local textVerti  = display.newText( scoreGroup, "Vertical: ", textX, textY, opt.defaultFont, fontSize )
	textVerti.anchorX, textVerti.anchorY = 0, 0
	scoreVerti = display.newText( scoreGroup, "0", textHoriz.x + textHoriz.width + 10, textY, opt.defaultFont, fontSize )
    scoreVerti.anchorX, scoreVerti.anchorY = 0, 0
    scoreVerti:setFillColor( unpack(textColor) )	

	-- textY = textY - fontSize * 4  -- original
	textY = textY - fontSize * 3
	local textScore  = display.newText( scoreGroup, "Score: ", textX, textY, opt.defaultFont, fontSize )
	textScore.anchorX, textScore.anchorY = 0, 0
	scoreScore = display.newText( scoreGroup, "0", textHoriz.x + textHoriz.width + 10, textY, opt.defaultFont, fontSize )
    scoreScore.anchorX, scoreScore.anchorY = 0, 0
    scoreScore:setFillColor( unpack(textColor) )	
    
	-- found words
    scrollFoundWords = widget.newScrollView 
    	{
	        left = display.contentCenterX + 100,
	        top = scoreScore.y,
	        width = display.actualContentWidth / 3,
	        height = menubar.menu.y - menubar.menu.height - scoreScore.y,
        	hideBackground = false,
        	backgroundColor = col.colGroup,
        	horizontalScrollDisabled = true,
        	verticalScrollDisabled = false,
    }
    textFoundWords = display.newText( "", 0, 0, scrollFoundWords.width, scrollFoundWords.height * 4, opt.defaultFont, 40 )
    textFoundWords.anchorX, textFoundWords.anchorY = 0, 0
    textFoundWords:setFillColor( unpack(col.colIvory) )
    scrollFoundWords:insert( textFoundWords )
    sceneGroup:insert( scrollFoundWords )

	-- timer
	local f = 72
	local x = textVerti.x
	local y = menubar.menu.y - menubar.menu.height - f
	-- reposition timer if overlap with scores
	if( y <= scoreVerti.y ) then 
		x = scoreVerti.x + 100
	end
	clockTime = display.newText( {text="", x=x, y=y, font=opt.defaultFont, fontSize=f, align="left"} )
	clockTime.anchorX, clockTime.anchorY = 0, 0
	clockTime:setFillColor( 1 )
	sceneGroup:insert( clockTime )	
end

-- -----------------------------------------------------------------------------------
-- show()

function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
		if( board:getStatus() == "ended" or opt.restart ) then 
			scene:restartGame()
		end
	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		board:play()
	end
end

-- -----------------------------------------------------------------------------------
-- hide()

function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		if( board:getStatus() ~= "ended" ) then 
			board:pause()
		end
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		
		-- dbgButton:removeEventListener( "tap" )
	end
end

-- -----------------------------------------------------------------------------------
-- destroy()

function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end

-- -----------------------------------------------------------------------------------
-- Test functions
-- -----------------------------------------------------------------------------------

function scene:debug()
	
	board:testInjectWord()
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
