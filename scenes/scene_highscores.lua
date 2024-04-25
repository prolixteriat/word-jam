
local composer = require( "composer" )
local col = require( "data.colors" )
local dbg = require( "lib.debugging" )
local hi = require( "game.highscores" )
local hlp = require( "lib.helper" )
local menu = require( "scenes.menubar" )
local opt = require( "game.options" )

-- -----------------------------------------------------------------------------------

local TAG = "scene_highscores.lua"

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------

local border    = 25
local fontSize  = 35
local ox, oy    = display.screenOriginX, display.screenOriginY
local textColor = col.colIvory

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------
-- Scene functions
-- -----------------------------------------------------------------------------------
-- create the visual option controls and add to group

function scene:highScore( group )

	local textX = ox + border 
	local textY = oy + 200
	
	-- score
	local scoreRect = display.newRect( group, ox, textY, display.contentWidth, fontSize * 8 )
	scoreRect.anchorX, scoreRect.anchorY = 0, 0
	scoreRect:setFillColor( unpack(col.colGroup))

	local o = hi.highScore
	local s = "High score: " .. o.score .. "\n\nHorizontal words: " .. o.numHorizontal .. "\n\nVertical words: " .. o.numVertical
	local txt  = display.newText( group, s, textX, textY, opt.defaultFont, fontSize, "left" )
	txt.anchorX, txt.anchorY = 0, 0
	txt:setFillColor( unpack(col.colIvory) )
	
	-- options
	textY = scoreRect.y + scoreRect.height + fontSize * 3
	local optionsRect = display.newRect( group, ox, textY, display.contentWidth, fontSize * 13 )
	optionsRect.anchorX, optionsRect.anchorY = 0, 0
	optionsRect:setFillColor( unpack(col.colGroup))

	o = hi.highScore.options
	s = "Board size: " .. o.tileCount .. "\n\nNumber of colours: " .. o.colorCount .. "\n\nMove limit: " 
	s = s .. o.moveLimit .. "\n\nMinimum word length: " .. o.minLen .. "\n\nGame time: " .. o.timeLimit .."mins"
	local txtOptions  = display.newText( group, s, textX, textY, opt.defaultFont, fontSize, "left" )
	txtOptions.anchorX, txtOptions.anchorY = 0, 0
	txtOptions:setFillColor( unpack(col.colIvory) )

end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	menubar = menu.createMenuBar( sceneGroup )
	scene:highScore( sceneGroup )
end


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
		-- back:addEventListener( "tap" )
	end
end


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
