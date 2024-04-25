
local composer = require( "composer" )
local hlp = require( "lib.helper" )

-- -----------------------------------------------------------------------------------

local TAG = "scene_instructions.lua"

local scene = composer.newScene()

local col = require( "data.colors" )
local dbg = require( "lib.debugging" )
local hlp = require( "lib.helper" )
local menu = require( "scenes.menubar" )
local opt = require( "game.options" )
local widget = require( "widget" )

-- -----------------------------------------------------------------------------------

local filePath = "scenes/img/"


-- -----------------------------------------------------------------------------------
-- Scene functions
-- -----------------------------------------------------------------------------------

function scene:showInstructions( group )

		local s = [[
The aim of the game is to form words by moving letter tiles within the game board.

Words may be formed horizontally or vertically.

Words must be formed of tiles of the same colour.

Words must meet the chosen requirement for the minimum number of letters.

Individual tiles may be moved unlimited times, or may be limited to a maximum number of moves.

Games may be limited to a set time or have an unlimited duration.

Each found word is awarded a score which is based upon the word itself and the selected game options. 

Use the Options menu to choose your preferred game settings.
	]]

	local border = 20
	
	local scrollView = widget.newScrollView 
    	{
	        width = display.actualContentWidth,
	        height = (display.actualContentHeight  * 0.8) - menubar.menu.height,
        	hideBackground = false,
        	backgroundColor = col.colGroup,
        	horizontalScrollDisabled = true,
        	verticalScrollDisabled = false
    }
	scrollView.x = display.contentCenterX
	scrollView.y = display.contentCenterY - menubar.menu.height   
    
    local w = display.actualContentWidth * 0.4
	local h = w * 439 / 438
	local boardImage1 = display.newImageRect(filePath .. "gameboard_1.png", w, h)
	boardImage1.x = border
	boardImage1.y = border
	boardImage1.anchorX, boardImage1.anchorY = 0, 0
    
    h = w * 469 / 473
    local boardImage2 = display.newImageRect(filePath .. "gameboard_2.png", w, h)
	-- boardImage2.x = boardImage1.x + boardImage1.width + border
	boardImage2.x = display.actualContentWidth - w - border
	boardImage2.y = border
	boardImage2.anchorX, boardImage2.anchorY = 0, 0

    textHelp = display.newText( s, border, boardImage1.y+boardImage1.height + border, scrollView.width - 2 * border, scrollView.height * 2, opt.defaultFont, 35 )
    textHelp.anchorX, textHelp.anchorY = 0, 0
    textHelp:setFillColor( unpack(col.colIvory) )
    scrollView:insert( boardImage1 )
    scrollView:insert( boardImage2 )
    scrollView:insert( textHelp )
    group:insert( scrollView )


	-- local txt  = display.newText( group, s, textX, textY, display.contentWidth - textX * 2, h, opt.defaultFont, fontSize, "left" )
	-- txt.anchorX, txt.anchorY = 0, 0
	-- txt:setFillColor( unpack(col.colIvory) )
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
-- create()

function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	menubar = menu.createMenuBar( sceneGroup )
	scene:showInstructions( sceneGroup )
end

-- -----------------------------------------------------------------------------------
-- show()

function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
		if( dbg.debug ) then 
			menubar.debug.isVisible = false
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
	menubar = nil
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

