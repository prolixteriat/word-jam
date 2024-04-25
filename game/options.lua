
-- ---------------------------------------------------------------------------------------

local dbg = require ("lib.debugging")
local hlp = require( "lib.helper" )

-- ---------------------------------------------------------------------------------------

local M = {}

local TAG = "options.lua"

-- ---------------------------------------------------------------------------------------

M.defaultFont     = "fonts/Dosis-Bold.ttf"
M.defaultFontSize = 50
M.widgetTheme     = "widget_theme_android_holo_light"
M.restart         = false  -- set to true when a game restart is required rather than continuation

-- -----------------------------------------------------------------------------------

local defaultLocation = system.DocumentsDirectory
local optionsFileName = "options_009.json"

-- ---------------------------------------------------------------------------------------
-- Local functions
-- ---------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------
-- Published functions
-- ---------------------------------------------------------------------------------------
-- Initialise score.

function M.initScores()

	M.score = M.createScores()
end

-- ---------------------------------------------------------------------------------------
-- Initialise score.

function M.createScores()

    local score = {}

    score.numHorizontal = 0
    score.numVertical   = 0
    score.numMultiple   = 0
    score.foundWords    = {}
    score.score         = 0

    return score
end


-- ---------------------------------------------------------------------------------------
-- Load the game options. 

function M.loadGameOptions()

    M.gameOptions = hlp.loadTable( optionsFileName )
    if( M.gameOptions == nil ) then
        -- file load has failed - initialise to default values
        dbg.errorMessage( TAG, "loadGameOptions", "Failed to load options file")
        M.gameOptions = {}
        M.gameOptions.capitals   = true     -- use capitals for tiles
        M.gameOptions.colorCount = 2        -- number of tile colours per board
        M.gameOptions.haptic     = true     -- vibrate on attempt to move locked tile
        M.gameOptions.minLen     = 4        -- minimum length for word match (0 = tileCount) 
        M.gameOptions.moveLimit  = 0        -- maximum no. moves per tile (0 = unlimited)
        M.gameOptions.playSounds = true     -- play sound effects
        M.gameOptions.tileCount  = 5        -- number of tiles in each row and column
        M.gameOptions.timeLimit  = 5        -- no. of mins for time-limited game (0 = unlimited)
    end
end



-- -----------------------------------------------------------------------------------
-- Save the game options.

function M.saveGameOptions()

    hlp.saveTable( M.gameOptions, optionsFileName )
end

-- -----------------------------------------------------------------------------------
-- Test functions
-- -----------------------------------------------------------------------------------
-- output current game options to console

function M.testOutputGameOptions()

    if( dbg.runTests ) then 
        dbg.statusMessage( TAG, "testOutputGameOptions", "Current game options:")
        dbg.printTable( M. gameOptions )
    end
end

-- ---------------------------------------------------------------------------------------

return M

-- ---------------------------------------------------------------------------------------
