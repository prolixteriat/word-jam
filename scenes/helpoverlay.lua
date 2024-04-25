
local composer = require( "composer" )
local col = require( "data.colors" )
local dbg = require( "lib.debugging" )
local opt = require( "game.options" )
local widget = require( "widget" )

-- -----------------------------------------------------------------------------------

local scene = composer.newScene()

local TAG = "helpoverlay.lua"

-- -----------------------------------------------------------------------------------

local helpText = {}
helpText.size = [[
Board Size:

Choose the number of tiles in each row and column of the board.

Note that the board size affects the values that can be selected for both the maximum number of tile colours and the minimum word length.
]]
helpText.time = [[
Time (mins):

Choose the duration of each game in minutes.

Note that choosing the '-' option means that each game has an unlimited duration.
]]
helpText.colors = [[
Tile Colours:

Choose the maximum number of tile colours to be used for each game board.

Words can only be formed from tiles of the same colour.

Note that the maximum permissible number of colours is one less than the board size.
]]
helpText.moves = [[
Letter Moves:

Choose the maximum number of moves which can be initiated by each tile. 
This value does not affect the number of moves in which a tile can participate - it is just the number of moves that can be initiated.

Note that choosing the '-' option means that each tile has unlimited moves.

If the number of moves is limited, then the appearance of a moved tile will indicate whether it has a move remaining or is locked. Tiles with a single move remaining are shown with a single diagonal line; tiles with no moves remaining have two diagonal lines forming a cross. 
]]
helpText.length = [[
Word Length:

Choose the minimum permissible word length.

Note that choosing the '-' option means that the length of each word must match the board size.
]]
helpText.firstRun = [[
Welcome to Word Jam!

The aim of the game is to form words by moving letter tiles within the game board.

Words may be formed horizontally or vertically. Words must be formed of tiles of the same colour.

On first use, the game board is configured for 5 x 5 tiles, with 2 tile colours and a minimum word length of 4 letters. 

Use the Options menu to choose your preferred game settings.

Tap to continue.
]]


-- -----------------------------------------------------------------------------------
-- Scene functions
-- -----------------------------------------------------------------------------------

function scene:showHelp( option )

	textHelp.text = helpText[option]
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
-- create()

function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	local border = 20
	scrollView = widget.newScrollView 
    	{
	        width = display.actualContentWidth * 0.85,
	        height = display.actualContentHeight * 0.7,
        	hideBackground = false,
        	backgroundColor = col.colBlue,
        	horizontalScrollDisabled = true,
        	verticalScrollDisabled = false
    }
	scrollView.x = display.contentCenterX
	scrollView.y = display.contentCenterY    
    textHelp = display.newText( "", border, border, scrollView.width - 2 * border, scrollView.height * 2, opt.defaultFont, 35 )
    textHelp.anchorX, textHelp.anchorY = 0, 0
    textHelp:setFillColor( unpack(col.colIvory) )
    scrollView:insert( textHelp )
    sceneGroup:insert( scrollView )

    -- respond to the overlay being pressed
    function scrollView:tap( event )
    	composer.hideOverlay( "fade", 400 )
    end
    scrollView:addEventListener( "tap", scrollView )

end

-- -----------------------------------------------------------------------------------
-- show()

function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
		local helpID = event.params.helpID
		assert( helpID == "size" or helpID == "time" or helpID == "colors" or helpID == "moves" or helpID == "length" or helpID == "firstRun" )
		scene:showHelp( helpID )
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
	scrollView:removeEventListener( "tap" )
        
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
