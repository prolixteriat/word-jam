-- -----------------------------------------------------------------------------------

local M = {}

local TAG = "debugging.lua"

-- -----------------------------------------------------------------------------------

M.runTests = false
M.debug    = false

local filePath = "lib/img/"

-- -----------------------------------------------------------------------------------
-- Published functions
-- -----------------------------------------------------------------------------------

function M.errorMessage( moduleName, functionName, message )
	if( M.debug ) then 
        print( "*** Error in " .. moduleName .. " : " .. functionName .. " - " .. message )
    end
end

-- -----------------------------------------------------------------------------------

function M.statusMessage( moduleName, message, status )
    if( M.debug ) then 
        local s = status or ""
        print( moduleName .. " : " .. message .. " - " .. s)
    end
end

-- -----------------------------------------------------------------------------------

function M.testStatusMessage( moduleName, functionName, result )
    if( M.runTest ) then
        print( "*** Test result: " .. moduleName .. " : " .. functionName .. " - " .. (result and "true" or "false") )
    end
end

-- -----------------------------------------------------------------------------------
-- Usage:
-- printTable( myTable )    --> Pass the table as an argument.
-- table.print = printTable --> Alternatively, assign to a property within the table...
-- table.print( myTable )   --> and then call with

function M.printTable( t )
 
    if( not M.debug ) then return end

    local printTable_cache = {}
 
    local function sub_printTable( t, indent )
 
        if ( printTable_cache[tostring(t)] ) then
            print( indent .. "*" .. tostring(t) )
        else
            printTable_cache[tostring(t)] = true
            if ( type( t ) == "table" ) then
                for pos,val in pairs( t ) do
                    if ( type(val) == "table" ) then
                        print( indent .. "[" .. pos .. "] => " .. tostring( t ).. " {" )
                        sub_printTable( val, indent .. string.rep( " ", string.len(pos)+8 ) )
                        print( indent .. string.rep( " ", string.len(pos)+6 ) .. "}" )
                    elseif ( type(val) == "string" ) then
                        print( indent .. "[" .. pos .. '] => "' .. val .. '"' )
                    else
                        print( indent .. "[" .. pos .. "] => " .. tostring(val) )
                    end
                end
            else
                print( indent..tostring(t) )
            end
        end
    end
 
    if ( type(t) == "table" ) then
        print( tostring(t) .. " {" )
        sub_printTable( t, "  " )
        print( "}" )
    else
        sub_printTable( t, "  " )
    end
end

-- -----------------------------------------------------------------------------------
-- Display menu button in standard format to be used in all sub-scenes.

function M.showDebugButton( sceneGroup, listenerFunction )

    dbgButton = display.newImageRect( sceneGroup, filePath .. "debug.png", 80, 64 )
    dbgButton.x = display.screenOriginX + (display.actualContentWidth / 2)
    dbgButton.y = display.screenOriginY + display.actualContentHeight - 90
    dbgButton:addEventListener( "tap", listenerFunction )
    return dbgButton
end

-- -----------------------------------------------------------------------------------

return M

-- -----------------------------------------------------------------------------------
