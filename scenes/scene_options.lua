
local col = require( "data.colors" )
local composer = require( "composer" )
local data = require( "data.words" )
local dbg = require( "lib.debugging" )
local hlp = require( "lib.helper" )
local menu = require( "scenes.menubar" )
local opt  = require( "game.options" )
local snd = require( "game.sounds" )
local widget = require( "widget" )

widget.setTheme( opt.widgetTheme )

-- -----------------------------------------------------------------------------------

local TAG = "scene_options.lua"

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------

local filePath  = "scenes/img/"
local border    = 25
local colTiles, colTimes, colColors, colMoves, colLengths = 1, 2, 3, 4, 5
local fontSize  = 35
local noLimit   = "-"
local ox, oy    = display.screenOriginX, display.screenOriginY
local textColor = col.colIvory
local colN      = 5     -- number of columns
local colW      = (display.actualContentWidth - border * 2) / colN   -- individual columns width

local pickerWheel  -- forward declaration
-- picker wheel options - to be populated later    
local colors  = {}
local colors  = {}
local minlens = {}
local moves   = {}
local tiles   = {}
local times   = {}

-- -----------------------------------------------------------------------------------
-- Local functions
-- -----------------------------------------------------------------------------------
-- respond to a picker wheel selection

local function pickerValueSelected( event )

	-- return string converted to number, else 1
	local function convertValue( str )
		local num = tonumber( str )
		if( num == nil ) then 
			num = 0 
		end
		return num
	end

	if( not event ) then return end
	-- get the current values
	local values = pickerWheel:getValues()
    local tileCount  = convertValue( values[colTiles].value )
    local timeLimit  = convertValue( values[colTimes].value )
    local colorCount = convertValue( values[colColors].value )
    local moveLimit  = convertValue( values[colMoves].value ) 
    local minLen     = convertValue( values[colLengths].value )
    
    if( dbg.debug ) then 
    	local s = "[tileCount: " .. tileCount .. "] - [timeLimit: " .. timeLimit .. "] - [colorCount: " .. colorCount .. "] - [moveLimit: " .. moveLimit .. "] - [minLen: " .. minLen .. "]"
    	dbg.statusMessage( TAG, "pickerValueSelected[1]", s )
	end
    -- respond to the chosen column
	if( event.column == colTiles ) then
		tileCount = convertValue( tiles[event.row] )
		if( tileCount < opt.gameOptions.tileCount ) then 
			if( colorCount >= (tileCount - 1) ) then 
				pickerWheel:selectValue( colColors, 1 )
			end
			if( minLen > (tileCount - 1) ) then 
				pickerWheel:selectValue( colLengths, 1 )
			end
			opt.gameOptions.tileCount = tileCount
		end
		opt.gameOptions.tileCount = tileCount
	elseif( event.column == colColors ) then 
		colorCount = convertValue( colors[event.row] )
		if( colorCount > (opt.gameOptions.tileCount - 1) ) then 
			-- snd.playSound( snd.sounds.locked )
			pickerWheel:selectValue( colColors, 1 )
		else
			opt.gameOptions.colorCount = colorCount
		end
	elseif( event.column == colMoves ) then 
		moveLimit = convertValue( moves[event.row] )
		opt.gameOptions.moveLimit = moveLimit
	elseif( event.column == colLengths ) then
		minLen = convertValue( minlens[event.row] )
		if( minLen > (opt.gameOptions.tileCount - 1) ) then 
			-- snd.playSound( snd.sounds.locked )
			pickerWheel:selectValue( colLengths, 1 )
		else
			opt.gameOptions.minLen = minLen
		end
	elseif( event.column == colTimes ) then
		timeLimit = convertValue( times[event.row] )
		opt.gameOptions.timeLimit = timeLimit
	else
		dbg.errorMessage( TAG, pickerValueSelected, event.column )
	end

    if( dbg.debug ) then 
    	dbg.statusMessage( TAG, "pickerValueSelected[2]", "[column: " .. event.column .. "] - [row: " .. event.row .. "]" )
    	dbg.statusMessage( TAG, "pickerValueSelected[3]", "[tileCount: " .. tileCount .. "] - [timeLimit: " .. timeLimit .."] - [colorCount: " .. colorCount .. "] - [moveLimit: " .. moveLimit .. "] - [minLen: " .. minLen ..  "]" )
    end
end

-- -----------------------------------------------------------------------------------
-- respond to an on/off button being selected

local function onOffSelected( event )

	local switch = event.target
	if( switch.id == "switchCapitals" ) then 
		opt.gameOptions.capitals = switch.isOn
	elseif( switch.id == "switchSounds" ) then 
		opt.gameOptions.playSounds = switch.isOn
	elseif( switch.id == "switchVibrate" ) then
		opt.gameOptions.haptic = switch.isOn
	else
	 	dbg.errorMessage( TAG, "onOffSelected", switch.id )
    end
end

-- -----------------------------------------------------------------------------------
-- handle press of info button by showing help overlay

local function infoListener( event )

	local info = event.target

	local options = {
    	isModal = true,
    	effect  = "fade",
    	time    = 400,
    	params  = {
    				helpID = info.id
    			  }
	}
 	composer.showOverlay( "scenes.helpoverlay", options )
end

-- -----------------------------------------------------------------------------------
-- Scene functions
-- -----------------------------------------------------------------------------------
-- create the game option controls and add to group

function scene:gameOptions( group )

	local textX = ox + border * 2
	local textY = oy + 550
	local infoY = textY
	local infoSize = 60
    
    -- create the info button to accompany each picker wheel column
    local function createInfoButton( id, x )

		local img = display.newImageRect( group, filePath .. "buttons/infobutton.png", infoSize, infoSize )
		img.anchorX, img.anchorY = 0, 0
		img.x = x
		img.y = infoY
		img.id = id
		img:addEventListener( "tap", infoListener )
		return img
	end

	-- background rectangle
	local groupRect = display.newRect( group, ox, textY, display.contentWidth, 222 + fontSize * 7 )
	groupRect.anchorX, groupRect.anchorY = 0, 0
	groupRect:setFillColor( unpack(col.colGroup))

    -- labels
    textY = textY + fontSize * 2
	local labelTiles  = display.newText( group, "Board\nSize", textX, textY, opt.defaultFont, fontSize, "center" )
	labelTiles.anchorX, labelTiles.anchorY = 0, 0
	infoTiles = createInfoButton( "size", textX )

	textX = textX + colW
    local labelTimes  = display.newText( group, "Time\n(mins)", textX, textY, opt.defaultFont, fontSize, "center" )
	labelTimes.anchorX, labelTimes.anchorY = 0, 0
	infoTime = createInfoButton( "time", textX )

	textX = textX + colW
    local labelColors  = display.newText( group, "Tile\nColours", textX, textY, opt.defaultFont, fontSize, "center" )
	labelColors.anchorX, labelColors.anchorY = 0, 0
	infoColors = createInfoButton( "colors", textX )

	textX = textX + colW
    local labelMoves  = display.newText( group, "Letter\nMoves", textX, textY, opt.defaultFont, fontSize, "center" )
	labelMoves.anchorX, labelMoves.anchorY = 0, 0
	infoMoves = createInfoButton( "moves", textX )

	textX = textX + colW
    local labelMinLens  = display.newText( group, "Word\nLength", textX, textY, opt.defaultFont, fontSize, "center" )
	labelMinLens.anchorX, labelMinLens.anchorY = 0, 0
	infoLength = createInfoButton( "length", textX )

	-- populate picker tables
	-- board size
	for i = 1, (data.maxTileCount - data.minTileCount + 1) do 
		tiles[i] = i + data.minTileCount - 1
	end
	local idTile = hlp.getKeyFromValue( tiles, opt.gameOptions.tileCount )
	if( idTile == nil ) then
		idTile = 1
		dbg.errorMessage( TAG, "scene:gameOptions-tileCount", opt.gameOptions.tileCount )
	end

	-- game duration
	times[1], times[2], times[3], times[4], times[5] = noLimit, 3, 5, 10, 15
	local idTime = 1
	if( opt.gameOptions.timeLimit > 0 ) then 
		idTime = hlp.getKeyFromValue( times, opt.gameOptions.timeLimit )
		if( idTime == nil ) then
			idTime = 1
			dbg.errorMessage( TAG, "scene:gameOptions-timeLimit", opt.gameOptions.timeLimit )
		end
	end

	-- number of tile colours
	for i = 1, (data.maxWordLen - 1) do
		colors[i] = i 
	end
	local idCol = hlp.getKeyFromValue( colors, opt.gameOptions.colorCount )
	if( idCol == nil ) then
		idCol = 1
		dbg.errorMessage( TAG, "scene:gameOptions-colorCount", opt.gameOptions.colorCount )
	end
	
	-- maximum tile moves
	moves[1], moves[2], moves[3]  = noLimit, 1, 2
	local idMove = 1
	if( opt.gameOptions.moveLimit > 0 ) then 
		idMove = hlp.getKeyFromValue( moves, opt.gameOptions.moveLimit )
		if( idMove == nil ) then
			idMove = 1
			dbg.errorMessage( TAG, "scene:gameOptions-moveLimit", opt.gameOptions.moveLimit )
		end
	end
	
	-- minimum word lengths
	-- minlens[1], minlens[2], minlens[3], minlens[4], minlens[5], minlens[6] = noLimit, 3, 4, 5, 6  -- three letter minimum
	minlens[1], minlens[2], minlens[3], minlens[4], minlens[5] = noLimit, 4, 5, 6   -- four letter minimum
	local idLen = 1
	if( opt.gameOptions.minLen > 0 ) then 
		idLen = hlp.getKeyFromValue( minlens, opt.gameOptions.minLen )
		if( idLen == nil ) then
			idLen = 1
			dbg.errorMessage( TAG, "scene:gameOptions-minLen", opt.gameOptions.minLen )
		end
	end

	-- initialise columns
	local columnData = { 
		{
			align = "center",
			width = colW,
			startIndex = idTile,
			labels = tiles,
		},
		{
			align = "center",
			width = colW,
			startIndex = idTime,
			labels = times,
		},
		{
			align = "center",
			width = colW,
			startIndex = idCol,
			labels = colors,
		},	
		{
			align = "center",
			width = colW,
			startIndex = idMove,
			labels = moves,
		},	
		{
			align = "center",
			width = colW,
			startIndex = idLen,
			labels = minlens,
		}	
	}
	
	-- initialise image sheet for picker wheel
	local images = {
		frames =
		{
			{ x=0,   y=0,   width=20,  height=20  },  --topLeft
			{ x=20,  y=0,   width=120, height=20  },  --topMiddle
			{ x=140, y=0,   width=20,  height=20  },  --topRight
			{ x=0,   y=20,  width=20,  height=120 },  --middleLeft
			{ x=140, y=20,  width=20,  height=120 },  --middleRight (adjust x later!)
			{ x=0,   y=140, width=20,  height=20  },  --bottomLeft (adjust y later!)
			{ x=20,  y=140, width=120, height=20  },  --bottomMiddle (adjust y later!)
			{ x=140, y=140, width=20,  height=20  },  --bottomRight (adjust x/y later!)
			{ x=180, y=0,   width=32,  height=80  },  --topFade
			{ x=224, y=0,   width=32,  height=80  },  --bottomFade
			{ x=276, y=0,   width=32,  height=20  },  --middleSpanTop
			{ x=276, y=60,  width=32,  height=20  },  --middleSpanBottom
			{ x=276, y=100, width=12,  height=32  }   --separator
		},
		sheetContentWidth  = 312,
		sheetContentHeight = 160
	}
	local pickerImages = graphics.newImageSheet( filePath .. "pickerwheel-resizable.png", images )

	-- create picker wheel
	pickerWheel = widget.newPickerWheel
	{
		top = textY + fontSize * 3,
		columns = columnData,
		fontSize = fontSize,
		fontColor = col.colGreen,
		fontColorSelected = { 1 },
		style = "resizable",
		width = colW * colN,
		rowHeight = 50,
		onValueSelected = pickerValueSelected,
		sheet = pickerImages,
		--borderPadding = 28,
		topLeftFrame = 1,
		topMiddleFrame = 2,
		topRightFrame = 3,
		middleLeftFrame = 4,
		middleRightFrame = 5,
		bottomLeftFrame = 6,
		bottomMiddleFrame = 7,
		bottomRightFrame = 8,
		topFadeFrame = 9,
		bottomFadeFrame = 10,
		middleSpanTopFrame = 11,
		middleSpanBottomFrame = 12,
		--backgroundFrame = 11,
		separatorFrame = 13,
		middleSpanOffset = 4
		
	}
	pickerWheel.x = ox + border
	pickerWheel.anchorX = 0
	group:insert( pickerWheel )
	
end

-- -----------------------------------------------------------------------------------
-- create the visual option controls and add to group

function scene:visualOptions( group )

	local textX = ox + border 
	local textY = oy + 200
	
	-- checkbox image sheet options and declaration
	local options = {
	    width = 100,
	    height = 100,
	    numFrames = 4,
	    sheetContentWidth = 400,
	    sheetContentHeight = 100
	}
	local checkboxSheet = graphics.newImageSheet( filePath .. "radio-checkbox.png", options )
	local checkboxSize = fontSize * 1.7

	-- background rectangle
	local groupRect = display.newRect( group, ox, textY, display.contentWidth, fontSize * 8 )
	groupRect.anchorX, groupRect.anchorY = 0, 0
	groupRect:setFillColor( unpack(col.colGroup))

    -- capitals
    local switchStyle = "checkbox"
    textY = textY + fontSize
	local labelCapitals  = display.newText( group, "Use capitals:", textX, textY, opt.defaultFont, fontSize, "right" )
	labelCapitals.anchorX, labelCapitals.anchorY = 0, 0
	
	local switchCapitals = widget.newSwitch( {
	        style = switchStyle,
	        id = "switchCapitals",
	        width = checkboxSize,
	        height = checkboxSize,
	        initialSwitchState = opt.gameOptions.capitals,
	        onRelease = onOffSelected,
	        sheet = checkboxSheet,
	        frameOff = 3,
	        frameOn = 4
	    } )
	switchCapitals.anchorX, switchCapitals.anchorY = 0, 0
    switchCapitals.x = labelCapitals.x + labelCapitals.width + border
    switchCapitals.y = textY
	group:insert( switchCapitals )

    -- sounds
    textY = textY + fontSize * 2
	local labelSounds  = display.newText( group, "Play sounds:", textX, textY, opt.defaultFont, fontSize, "right" )
	labelSounds.anchorX, labelSounds.anchorY = 0, 0
	local switchSounds = widget.newSwitch( {
	        style = switchStyle,
	        id = "switchSounds",
	        width = checkboxSize,
	        height = checkboxSize,
	        initialSwitchState = opt.gameOptions.playSounds,
	        onRelease = onOffSelected,
	        sheet = checkboxSheet,
	        frameOff = 3,
	        frameOn = 4
	    } )
	switchSounds.anchorX, switchSounds.anchorY = 0, 0
    switchSounds.x = switchCapitals.x
    switchSounds.y = textY
	group:insert( switchSounds )

	-- vibrate
    textY = textY + fontSize * 2
	local labelVibrate  = display.newText( group, "Use vibrate:", textX, textY, opt.defaultFont, fontSize, "right" )
	labelVibrate.anchorX, labelVibrate.anchorY = 0, 0
	local switchVibrate = widget.newSwitch( {
	        style = switchStyle,
	        id = "switchVibrate",
	        width = checkboxSize,
	        height = checkboxSize,
	        initialSwitchState = opt.gameOptions.haptic,
			onRelease = onOffSelected,
	        sheet = checkboxSheet,
	        frameOff = 3,
	        frameOn = 4
	    } )
	switchVibrate.anchorX, switchVibrate.anchorY = 0, 0
    switchVibrate.x = switchCapitals.x
    switchVibrate.y = textY
	group:insert( switchVibrate )
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
-- create()

function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	menubar = menu.createMenuBar( sceneGroup )

	visualGroup = display.newGroup()
	scene:visualOptions( visualGroup )
	sceneGroup:insert( visualGroup )
	
	gameGroup = display.newGroup()
	scene:gameOptions( gameGroup )
	sceneGroup:insert( gameGroup )
end


-- -----------------------------------------------------------------------------------
-- show()

function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
		if( dbg.debug ) then 
			menubar.debug.isVisible = false
		end
		menubar.options.isVisible = false
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
		opt.testOutputGameOptions()
		opt.saveGameOptions()
		opt.restart = true
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		menubar.options.isVisible = true
	end
end

-- -----------------------------------------------------------------------------------
-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
	menubar = nil
	infoSize:removeEventListener( "tap" )
	infoTime:removeEventListener( "tap" )
	infoColors:removeEventListener( "tap" )
	infoMoves:removeEventListener( "tap" )
	infoLength:removeEventListener( "tap" )
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

