-- -----------------------------------------------------------------------------------
-- Class extenders
-- -----------------------------------------------------------------------------------

local M = {}

local TAG = "extenders.lua"

-- -----------------------------------------------------------------------------------
-- Published functions
-- ---------------------------------------------------------------------------------------
-- Extension to string class to provide split method

function string:split( inSplitPattern )
 
    local outResults = {}
    local theStart = 1
    local theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
 
    while theSplitStart do
        table.insert( outResults, string.sub( self, theStart, theSplitStart-1 ) )
        theStart = theSplitEnd + 1
        theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
    end
 
    table.insert( outResults, string.sub( self, theStart ) )
    return outResults
end

-- -----------------------------------------------------------------------------------

return M

-- -----------------------------------------------------------------------------------

