
-- ---------------------------------------------------------------------------------------

local dbg = require( "lib.debugging" )
local hlp = require( "lib.helper" )
local opt = require( "game.options" )

-- ---------------------------------------------------------------------------------------

local M = {}

local TAG = "words.lua"

-- ---------------------------------------------------------------------------------------

M.minWordLen          =  3  -- minimum word length
M.maxWordLen          =  7  -- maximum word length
M.minTileCount        =  4  -- minimum tile count
M.maxTileCount        =  M.maxWordLen  -- maximum tile count

local defaultLocation = system.ResourceDirectory
local maxLetters      = 26  -- number of characters in alphabet

local vowels = {}
vowels[1], vowels[2], vowels[3], vowels[4], vowels[5] = "a", "e", "i", "o", "u"

-- ---------------------------------------------------------------------------------------
-- Scores:
-- initialise individual letter score table
local let = {}
let.a, let.e, let.i, let.o, let.u, let.l, let.n, let.s, let.t, let.r = 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
let.d, let.g = 2, 2
let.b, let.c, let.m, let.p = 3, 3, 3, 3
let.f, let.h, let.v, let.w, let.y = 4, 4, 4, 4, 4
let.k = 5
let.j, let.x = 8, 8
let.q, let.z = 10, 10

-- initialise word length scores
local len = {}
len[3], len[4], len[5], len[6], len[7], len[8] = 6, 10, 15, 21, 28, 36

-- initialise colour scores
local col = {}
col[1], col[2], col[3], col[4], col[5], col[6], col[7], col[8] = 34, 21, 13, 8, 5, 3, 2, 1

-- ---------------------------------------------------------------------------------------
-- Local functions
-- ---------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------
-- Published functions
-- ---------------------------------------------------------------------------------------
-- Return true if the supplied word exists

function M.doesWordExist( word )

	-- dbg.statusMessage( TAG, "doesWordExist", word )
	local found = false
	local id = string.len( word )
	word = string.lower( word )
	-- check that word meets length requirements
	if( (id >= M.minWordLen) and 
		(id <= M.maxWordLen) and 
		((opt.gameOptions.minLen == 0) or (id >= opt.gameOptions.minLen))  ) then
		if( M.words[id].list[word] ) then 
			found = true 
		end
	end
	return found
end

-- ---------------------------------------------------------------------------------------
-- Return a weighted random letter

function M.getRandomLetter( wordLen )

    local n = wordLen or opt.gameOptions.tileCount
    local letter = nil    -- return value

    local rndNum = math.random( 1, M.words[n].freq[maxLetters][1] )
    local i = 0
    repeat
    	i = i + 1
    until( (i > maxLetters) or (rndNum <= M.words[n].freq[i][1]) )

    if( i <= maxLetters ) then
    	letter = M.words[n].freq[i][2]
    	if( opt.gameOptions.capitals ) then 
    		letter = string.upper( letter )
    	end
    else
    	dbg.errorMessage( TAG, "getRandomLetter", rndNum )
    end
    return letter
end

-- ---------------------------------------------------------------------------------------
-- Return a random vowel

function M.getRandomVowel()

	local i = math.random(1, 5)
	local v = vowels[i]
    if( opt.gameOptions.capitals ) then 
    	v = string.upper( v )
    end
    return v
end

-- ---------------------------------------------------------------------------------------
-- Calculate and return the score for a given word

function M.getWordScore( word )

	local score = 0 -- return value

	word = string.lower( word )
	-- letter score
	for c in word:gmatch(".") do
		score = score + let[c]
	end
	-- length score
	local l = string.len( word )
	score = score + len[l]
	-- bonus for maximum length
	if( l == opt.gameOptions.tileCount ) then 
		score = score + math.floor(len[l] / 2)
	end
	-- colour score
	if( opt.gameOptions.colorCount > 1 ) then 
		local n = opt.gameOptions.tileCount - opt.gameOptions.colorCount
		score = score + col[n]
	end
	
	return score
end

-- ---------------------------------------------------------------------------------------
-- Initialise letter-related data structures

function M.init()

	M.words = {}

	for i=M.minWordLen, M.maxWordLen do
		M.words[i] = {}
		M.words[i].list = {}
		M.words[i].freq = {}
		for j = 1, maxLetters do
			M.words[i].freq[j] = {}
		end
	end	
end

-- ---------------------------------------------------------------------------------------
-- Read JSON files previously created by saveWordFile function. Return true if successful.
-- Note that ResourceDirectory is the same folder as main.lua

function M.loadWordFiles( location )

    local loc = location
    if not loc then
        loc = defaultLocation
    end
    local success = true
	M.init()
	
	-- load two files (words & freqs) for each set of word lengths
	for i=M.minWordLen, M.maxWordLen do
		local fn1 = "words_" .. string.format("%02d", i) .. ".json"
		local fn2 = "freqs_" .. string.format("%02d", i) .. ".json"
		M.words[i].list = hlp.loadTable( fn1, loc )
		M.words[i].freq = hlp.loadTable( fn2, loc )	
		if( M.words[i].list == nil ) then 
			dbg.errorMessage( TAG, "loadWordFiles (a)", fn1 )
			success = false
		end
		if( M.words[i].freq == nil ) then 
			dbg.errorMessage( TAG, "loadWordFiles (b)", fn2 )
			success = false
		end
	end
	
	return success
end

-- ---------------------------------------------------------------------------------------
-- Test functions
-- ---------------------------------------------------------------------------------------
-- Test that JSON files have been successfully read. Returns true if successful.

function M.testSuccessfulLoad()

	if( not dbg.runTests ) then return true end

	local function testWord( word )
		local f = M.doesWordExist( word )
		print( "    Word: " .. word .. " - Length: " .. string.len( word ) .. " - Found: " .. (f and 'true' or 'false'))
		return f
	end
	-- check word arrays: 3, 4, 5, 6 and 7 char lengths
	local words = testWord( "car" )    and
				  testWord( "want" )   and
				  testWord( "abbot" )  and
				  testWord( "bounce" ) and
	              testWord( "cheated" )
	
	-- check frequency arrays
	local freqs = true
	for i=M.minWordLen, M.maxWordLen do
		local c = M.getRandomLetter( i )
		print( "    Letter: " .. c .. " - Length: " .. i )
		if( c == nil ) then 
			freqs = false
		end
	end
	local result = words and freqs
	dbg.testStatusMessage( TAG, "testSuccessfulLoad", result )
	return result
end

-- ---------------------------------------------------------------------------------------

return M

-- ---------------------------------------------------------------------------------------
