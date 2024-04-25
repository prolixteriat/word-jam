
-- ---------------------------------------------------------------------------------------

local opt = require( "game.options" )

-- ---------------------------------------------------------------------------------------

local M   = {}

local TAG = "sounds.lua"

-- ---------------------------------------------------------------------------------------

M.sounds  = {}        -- sound effects used throughout the game

-- ---------------------------------------------------------------------------------------

local filePath = "game/sounds/"
local chan     = 1    -- reserved sound channel for timer countdown

-- ---------------------------------------------------------------------------------------
-- Published functions
-- ---------------------------------------------------------------------------------------
-- Dispose of audio resources

function M.disposeAudio()
	
	audio.stop()
  	for s,v in pairs( M.sounds ) do
    	audio.dispose( v )
    	M.sounds[s] = nil
  	end
end

-- ---------------------------------------------------------------------------------------
-- Initialise audio resources

function M.initAudio()
	
	M.sounds = {
    	click     = audio.loadSound( filePath .. "click.mp3" ),  
    	gameOver  = audio.loadSound( filePath .. "game_over.wav" ),
    	highScore = audio.loadSound( filePath .. "high_score.mp3" ),
    	locked    = audio.loadSound( filePath .. "locked.mp3" ),
    	timer     = audio.loadSound( filePath .. "timer.mp3" ),
    	wordFound = audio.loadSound( filePath .. "word_found.wav" )
	}

	audio.reserveChannels( chan )             -- Reserve channel 1 for background music
	audio.setVolume( 0.5, { channel=chan } )  -- Reduce the overall volume of the channel
end

-- ---------------------------------------------------------------------------------------
-- play the supplied sound effect

function M.playSound( sound )

	if( opt.gameOptions.playSounds ) then 
		audio.play( sound )
	end
end

-- ---------------------------------------------------------------------------------------
-- start or stop the timer countdown sound effect

function M.playTimer( play )

	if( opt.gameOptions.playSounds and play ) then
		audio.play( M.sounds.timer, { channel=chan, loops=-1 } )
	else
		audio.stop( chan )
	end
end
-- ---------------------------------------------------------------------------------------

return M

-- ---------------------------------------------------------------------------------------
