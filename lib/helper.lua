-- -----------------------------------------------------------------------------------

local composer = require( "composer" )
local dbg = require ("lib.debugging")
local json = require( "json" )

-- -----------------------------------------------------------------------------------

local M = {}

local TAG = "helper.lua"

-- -----------------------------------------------------------------------------------

local defaultLocation = system.DocumentsDirectory
local filePath = "lib/img/"

-- -----------------------------------------------------------------------------------
-- Local functions
-- -----------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------
-- Published functions
-- -----------------------------------------------------------------------------------

function M.gotoScene( menu )
    
    composer.gotoScene( menu, { time=800, effect="crossFade" } )
end

-- -----------------------------------------------------------------------------------
-- return the key for a given value in a supplied has table, else return nil

function M.getKeyFromValue( t, val )

    local key = nil
    -- dbg.printTable( t )
    -- print( "Val: " .. val )
    for k, v in pairs( t ) do
        -- print( "k: " .. k .. " - v: " .. v )
        if( v == val ) then 
            key = k 
            break
        end
    end
    return key
end

-- -----------------------------------------------------------------------------------

function M.loadTable( filename, location )
 
    local loc = location
    if not location then
        loc = defaultLocation
    end
 
    local path = system.pathForFile( filename, loc )
    local file, errorString = io.open( path, "r" )
 
    if not file then
        dbg.errorMessage( TAG, "loadTable", errorString )
        return nil
    else
        local contents = file:read( "*a" )
        local t = json.decode( contents )
        io.close( file )
        return t
    end
end

-- -----------------------------------------------------------------------------------
-- Save table to file. Return true if successful.

function M.saveTable( t, filename, location )
 
    local loc = location
    if not location then
        loc = defaultLocation
    end
 
    local path = system.pathForFile( filename, loc )
    local file, errorString = io.open( path, "w" )
 
    if not file then
        dbg.errorMessage( TAG, "saveTable", errorString )
        return false
    else
        file:write( json.encode( t ) )
        io.close( file )
        return true
    end
end

-- -----------------------------------------------------------------------------------

return M

-- -----------------------------------------------------------------------------------

