
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------

local TAG = "gameover.lua"

-- ---------------------------------------------------------------------------------------

local filePath = "scenes/img/"

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
-- create()

function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	local w = display.actualContentWidth * 0.9
	local h = w * 346 / 493
	gameOverImage   = display.newImageRect(sceneGroup, filePath .. "gameover.png", w, h)
	gameOverImage.x = display.contentCenterX
	gameOverImage.y = display.contentCenterY

    -- respond to the game over image being pressed
    function gameOverImage:tap(event)
    	composer.hideOverlay( "fade", 400 )
    end
    gameOverImage:addEventListener( "tap", gameOverImage )

end

-- -----------------------------------------------------------------------------------
-- show()

function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

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
	gameOverImage:removeEventListener( "tap" )
        
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
