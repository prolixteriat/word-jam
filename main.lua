-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local col = require( "data.colors" )

local TAG = "main.lua"

-----------------------------------------------------------------------------------------
 
-- Hide status bar
display.setStatusBar( display.HiddenStatusBar )
 
math.randomseed( os.time() )

display.setDefault( "background", unpack(col.colBackground) )

composer.gotoScene( "scenes.scene_menu" )


-----------------------------------------------------------------------------------------

