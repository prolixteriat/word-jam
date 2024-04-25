
-- ---------------------------------------------------------------------------------------

local dbg = require ("lib.debugging")
local hlp = require( "lib.helper" )
local opt = require( "game.options" )
local snd = require( "game.sounds" )

-- ---------------------------------------------------------------------------------------

local M = {}

local TAG = "highscores.lua"

-- ---------------------------------------------------------------------------------------

local defaultLocation  = system.DocumentsDirectory
local highScoreFileName = "highscores_009.json"

-- ---------------------------------------------------------------------------------------
-- Local functions
-- ---------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------
-- Published functions
-- ---------------------------------------------------------------------------------------
-- Load the saved high scores. 
-- Note: both of the following need to have been called first:
--   opt.initScores() opt.loadGameOptions()

function M.loadHighScores()

    M.highScore = hlp.loadTable( highScoreFileName )
    M.isHighScore = false  -- true if high score already achieved for game
    if( M.highScore == nil ) then
        -- file load has failed - initialise to default values
        dbg.errorMessage( TAG, "loadHighScores", "Failed to load high scores file")
        M.highScore = {}
        M.highScore.score         = 0
        M.highScore.numHorizontal = 0
        M.highScore.numVertical   = 0
        M.highScore.numMultiple   = 0
        -- unused
        M.highScore.gameCount     = 0
        M.highScore.feedback      = 0
        M.highScore.totalTime     = 0
        M.highScore.maxWord       = "" 
        M.highScore.maxWordScore  = 0
        M.highScore.avScorePerMin = 0
        M.highScore.options       = opt.gameOptions
    end
    -- dbg.printTable( M.highScore )
end

-- -----------------------------------------------------------------------------------
-- Update and save the high score, if required. Return true if new high score.

function M.saveHighScores()

    local newHighScore = false
    -- check whether new high score
    -- print("Checking high scores")
    -- dbg.printTable( M.highScore )
    -- dbg.printTable( opt.score )
    if( M.highScore.score < opt.score.score ) then 
        -- dbg.statusMessage(TAG, "saveHighScores", Saving high scores")
        newHighScore = true
        -- only play high score sound once
        if( (M.highScore.gameCount > 1) and (not M.isHighScore) ) then 
            snd.playSound( snd.sounds.highScore )
            M.isHighScore = true 
        end
        M.highScore.score         = opt.score.score
        M.highScore.numHorizontal = opt.score.numHorizontal
        M.highScore.numVertical   = opt.score.numVertical
        M.highScore.numMultiple   = opt.score.numMultiple
        M.highScore.gameOptions   = opt.gameOptions
        hlp.saveTable( M.highScore, highScoreFileName )
    end
    return newHighScore
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
