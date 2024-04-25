
-- ---------------------------------------------------------------------------------------

local col  = require( "data.colors" )
local data = require( "data.words" )
local dbg  = require( "lib.debugging" )
local hi = require( "game.highscores" )
local opt  = require( "game.options" )
local puff = require( "lib.puff").newPuff
local snd  = require( "game.sounds" )

-- ---------------------------------------------------------------------------------------

local M = {}

local TAG = "board.lua"

-- ---------------------------------------------------------------------------------------
-- Local functions
-- ---------------------------------------------------------------------------------------
-- return true if provided co-ords are within an object's bounds

local function pointInBounds(x, y, object)
	local bounds = object.contentBounds
  	if not bounds then return false end
  	if x > bounds.xMin and x < bounds.xMax and y > bounds.yMin and y < bounds.yMax then
    	return true 
  	else 
    	return false
  	end
end

-- ----------------------------------------
-- update scores because a word has been found.

local function updateWordFound( word, isRow )

	if( isRow ) then 
		opt.score.numHorizontal = opt.score.numHorizontal + 1
	else
		opt.score.numVertical = opt.score.numVertical + 1
	end
	opt.score.score = opt.score.score + data.getWordScore( word )
	table.insert( opt.score.foundWords, 1, word )
end

-- ---------------------------------------------------------------------------------------

local abs = math.abs
local random = math.random

-- ---------------------------------------------------------------------------------------
-- Published functions
-- ---------------------------------------------------------------------------------------

function M.new( parent, scoreCallback, timeCallback, options )
  
  	options = options or {}

  	if( data.loadWordFiles() == false ) then 
    	dbg.errorMessage( TAG, "new", "Failed to load word files" )
  	end
  	data.testSuccessfulLoad() 

  	local rows = options.rows or 5
  	local cols = options.cols or 5
  	local width = options.width or (display.actualContentWidth / cols) - 6
  	local height = options.height or width
  	local paused = options.paused or false
  	local parentScene = parent
  	local updateScore = scoreCallback
  	local updateTime = timeCallback
  	local secondsLeft = opt.gameOptions.timeLimit * 60 -- duration of game (secs)
  	local lockCount = 0      -- number of locked tiles
	hi.highScore.gameCount = hi.highScore.gameCount + 1

  	local board = display.newGroup()   
  	board.status = "init"
  	board.timer = {}

  	-- handle countdown timer
  	local function updateTime( event )
  		secondsLeft = secondsLeft - 1
  		timeCallback( { secs = secondsLeft } )
  		if( secondsLeft == 0 ) then 
  			board:gameOver( "Out of time" )
  		elseif( secondsLeft <= 10 ) then
  			snd.playTimer( true )
  		end

  	end
  
  	if( secondsLeft > 0 ) then 
  		board.countDownTimer = timer.performWithDelay( 1000, updateTime, secondsLeft )
  	end

  	if paused then board.status = "paused" end

	-- ----------------------------------------

  	function board:play()
    	paused = false
    	board.status = "idle"    
    	board:replenish()    
    	board:recycle()
    	if( secondsLeft > 0 ) then 
    		timer.resume( board.countDownTimer )
    	end
  	end 

	-- ----------------------------------------

  	function board:pause()
    	-- print( "board:paused called")
    	paused = true
    	board.status = "paused"  
  		if( secondsLeft > 0 ) then 
    		timer.pause( board.countDownTimer )
    		snd.playTimer( false )
    	end
  	end  

  	-- ----------------------------------------
  	-- start a new game

  	function board:restart( tileCount, tileSize )
  	
  		local pieces = board.piece
    	for i = #pieces,1,-1 do
       		display.remove(pieces[i])
       		table.remove(pieces,i)  
    	end
        lockCount = 0
		updateScore( { phase = "culling" } ) 
		cols, rows    = tileCount, tileCount
		height, width = tileSize, tileSize
		hi.highScore.gameCount = hi.highScore.gameCount + 1
		board:play()
        
    	if( secondsLeft > 0 ) then 
  			timer.cancel( board.countDownTimer )
  			snd.playTimer( false )	
  		end
		secondsLeft = opt.gameOptions.timeLimit * 60
    	if( secondsLeft > 0 ) then 
  			updateTime()
  			board.countDownTimer = timer.performWithDelay( 1000, updateTime, secondsLeft )
    	end
        
  	end

  	-- ----------------------------------------
  
  	-- display screen info for debugging purposes...
  	-- print( "screenOriginX:      " .. display.screenOriginX )
  	-- print( "contentCenterX:     " .. display.contentCenterX )
  	-- print( "actualContentWidth: " .. display.actualContentWidth )
  	-- print( "contentWidth:       " .. display.contentWidth )
  	-- print( "cols:               " .. cols )
  	-- print( "width:              " .. width )
	-- local tmp = display.newRect( 0, 0, 50, 50 )
	-- tmp.x = display.contentCenterX, tmp.y = display.contentCenterY 
  	
  	function board:newPiece(r,c)

    	if not board.removeSelf then return false end
    	if board.piece == nil then
      		board.piece = {}
    	end
    	local pieces = board.piece
    	-- function that builds a new game piece    
    	local nextPiece = #pieces+1

    	-- each tile consists of a group, a background rectangle plus a text character:
      	--   make group
      	-- calculate offsets to centre board horizontally
	  	local ox = (display.screenOriginX + (display.actualContentWidth - (cols * width)) / 2) - (width / 2)
  		local oy = display.screenOriginY + height / 2
      	local squareGroup = display.newGroup()
      	squareGroup.x = ox + c*width
      	squareGroup.y = oy + r*height 
      	
      	squareGroup.width  = width - 2
      	squareGroup.height = height - 2
      	--   make background rectangle
      	local space = display.newRoundedRect(self, 0, 0, width-2, height-2, width * 0.10)
      	space.color = col.getRandomColor()
      	space:setFillColor( unpack(space.color) ) 
	  	space.moves = 0
	  	--   make text character
      	local rndLetter = board:getRandomLetter( space.color ) 
      	piece = display.newText(self, rndLetter, 0, 0, opt.defaultFont, 70)
      	piece.letter = rndLetter --new
      	piece:setFillColor( unpack(col.colTileText) ) 
      	squareGroup:insert( space )
      	squareGroup:insert( piece )
      	pieces[nextPiece] = squareGroup
      	board:insert( squareGroup ) 

    	-- make a local copy
    	local currentPiece = pieces[nextPiece]    
    	currentPiece.id = nextPiece
    	currentPiece.r,currentPiece.c = r,c
    	-- transition.from( currentPiece, { time = 2000, xScale = 0.01, yScale = 0.01, transition=easing.outBounce } ) -- original
    	transition.from( currentPiece, { time = 1000, xScale = 0.01, yScale = 0.01, transition=easing.outBounce } )
    
		-- ----------------------------------------
    	-- touch listener function
    	function currentPiece:touch( event )

      		if not self.moving and board.status == "idle" and event.phase == "began" then
	        	-- first we set the focus on the object
	        	display.getCurrentStage():setFocus( self, event.id )
		        self:toFront()
		        self.isFocus = true
		        self.isMoving = true

		        -- then we store the original x and y position
		        self.markX = self.x
		        self.markY = self.y

		        board.status = "swapping"      
		        transition.to (self, { tag="board", time=100, xScale = 1.2, yScale = 1.2, transition=easing.outQuad } )

      		elseif self.isFocus then

	        	if event.phase == "moved" then

	          		local dx, dy = abs(event.x - event.xStart), abs(event.y - event.yStart)
	          		local lr, ud = false, false

			        if dx > 16 or dy > 16 then 
			        	if dx > dy then lr = true end 
			        	if dy > dx then ud = true end 
			    	end

		          	-- then drag our object
		          	self.x = event.x - event.xStart + self.markX
		          	self.y = event.y - event.yStart + self.markY

		          	-- keep it lr/ud
		          	if ud then self.x = self.markX end
		          	if lr then self.y = self.markY end

		          	-- only allow moving a single space
		          	if self.x < self.markX - width then self.x = self.markX - width end
		          	if self.x > self.markX + width then self.x = self.markX + width end
		          	if self.y < self.markY - height then self.y = self.markY - height end
		          	if self.y > self.markY + height then self.y = self.markY + height end

	        	elseif event.phase == "ended" or event.phase == "cancelled" then

	          		-- is there a new piece under where we let go?
			        local lx = (self.contentBounds.xMin + self.contentBounds.xMax) * 0.5
			        local ly = (self.contentBounds.yMin + self.contentBounds.yMax) * 0.5          
			        local pieceToSwap = board:findPiece(lx,ly,self.id)

		          	-- keep from double touches
		          	local function checkMatches()
		            	if pieceToSwap then pieceToSwap.moving = false end
		            	self.moving = false 
		            	board:cull()              
		          	end

	          		local function noMove()
	            		self.moving = false
	            		board.status = "idle"
	          		end

	          		if ( pieceToSwap and board:checkMoveLimit( self ) ) then
	            		-- keep from double touches
	            		pieceToSwap.moving = true

			            -- swap row and column
			            pieceToSwap.r, self.r = self.r, pieceToSwap.r
			            pieceToSwap.c, self.c = self.c, pieceToSwap.c

			            -- transition.to(self, { tag="board", time = 500, xScale = 1, yScale = 1, x = pieceToSwap.x, y = pieceToSwap.y, transition = easing.outBounce, onComplete = checkMatches } ) -- original
			            -- transition.to(pieceToSwap, { tag="board", time = 500, x = self.markX, y = self.markY, transition = easing.outBounce } ) -- original 
			            transition.to(self, { tag="board", time = 250, xScale = 1, yScale = 1, x = pieceToSwap.x, y = pieceToSwap.y, transition = easing.outBounce, onComplete = checkMatches } )
			            transition.to(pieceToSwap, { tag="board", time = 250, x = self.markX, y = self.markY, transition = easing.outBounce } )              

	          		else           
	            		transition.to(self, { tag="board", time = 333, xScale = 1, yScale = 1, x = self.markX, y = self.markY, transition = easing.outBounce, onComplete = noMove }  )     
	          		end
	          		-- we end the movement by removing the focus from the object
	          		display.getCurrentStage():setFocus( self, nil )
	          		self.isFocus = false      
	        	end
      		end
      		-- return true so Solar2D knows that the touch event was handled properly
      		return true
    	end

    	-- finally, add an event listener to the tile to allow it to be dragged
    	currentPiece:addEventListener( "touch" )
  	end

	-- ----------------------------------------

	function board:findPiece(x,y,id)
    	if not board.removeSelf then return false end    
    	-- find a piece at a screen x,y
    	local pieces = board.piece
	    id = id or -1
	    if pieces == nil then return false end
	    for i = #pieces, 1, -1 do
	    	if pointInBounds(x,y,pieces[i]) and i ~= id then
	        	return pieces[i]
	    	end
	    end
	    return false
  	end

  	-- ----------------------------------------

	function board:getPiece(r,c)
		if not board.removeSelf then return false end    
	    -- get a piece at a board r,c
	    local pieces = board.piece
	    if pieces == nil then return false end
	    for i = #pieces,1,-1 do
	    	if pieces[i] and pieces[i].r == r and pieces[i].c == c then
	        	return pieces[i]
	    	end
	    end
	    return false    
	  end

  	-- ----------------------------------------
  	-- return true if match in col r
  
  	function board:checkMatchCol( c )

      	local match = false     -- return value
      	local color = board:getColorCol( c )
      	local word  = board:getWordCol( c )
      	local found = data.doesWordExist( word )
      	-- dbg.statusMessage( "checkMatchCol", word, (found and "true" or "false") )
      
      	if( found and (color or (opt.gameOptions.colorCount == 0)) ) then 
      		match = true
      		-- update scores
      		updateWordFound( word, false )
      	end

      	return match
  	end

  	-- ----------------------------------------
  	-- return true if match in row r
  
  	function board:checkMatchRow( r )

      	local match = false     -- return value
      	local color = board:getColorRow( r )
      	local word  = board:getWordRow( r )
      	local found = data.doesWordExist( word )
      	-- if( color ) then 
      	--	dbg.statusMessage( TAG, "checkMatchRow", "[r: " .. r .. " - [R: ".. color[1] .. "] - [G: " .. color[2] .. "] - [B: " .. color[3] .. "]")
      	-- end
      	-- dbg.statusMessage( "checkMatchRow", word, (found and "true" or "false") )
      	if( found and (color or (opt.gameOptions.colorCount == 0)) ) then 
			match = true
      		updateWordFound( word, true )
      	end

      return match
  	end

		-- ----------------------------------------
  	-- returns begin and end indices if match, else (-1, -1). 
  	-- only matches single longest word in row

  	function board:checkMatchPartCol( c )
  		
  		local o = opt.gameOptions
  		if( o.minLen == 0 ) then 
  			-- only allowing full length words
  			if( board:checkMatchCol( c ) ) then 
  				return 1, rows
  			end
  		else
  			for l = o.tileCount, o.minLen, -1 do        -- word length
  				for b = 1, (o.tileCount - l + 1) do     -- begin index
					local e = b + l - 1          		-- end index
			      	local color = board:getColorCol( c, b, e )
			      	local word  = board:getWordCol( c, b, e )
			      	local found = data.doesWordExist( word )
					-- dbg.statusMessage( TAG, "checkMatchPartCol", "[c: " .. c .. "] [l: " .. l .. "] [b: " .. b .. "] [e: " .. e .. "]" )
			      	-- dbg.statusMessage( "checkMatchPartCol", word, (found and "true" or "false") )
			      	local match = found and color
			      	if( match ) then 
				      	-- dbg.statusMessage( "checkMatchPartCol", word, (found and "true" or "false") )
						updateWordFound( word, false )
			      		return b, e
			      	end
  				end
  			end
  		end

  		return -1, -1
  	end

  	-- ----------------------------------------
  	-- returns begin and end indices if match, else (-1, -1). 
  	-- only matches single longest word in row

  	function board:checkMatchPartRow( r )
  		
  		local o = opt.gameOptions
  		if( o.minLen == 0 ) then 
  			-- only allowing full length words
  			if( board:checkMatchRow( r ) ) then 
  				return 1, cols
  			end
  		else
  			for l = o.tileCount, o.minLen, -1 do        -- word length
  				for b = 1, (o.tileCount - l + 1) do     -- begin index
					local e = b + l - 1          		-- end index
			      	local color = board:getColorRow( r, b, e )
			      	local word  = board:getWordRow( r, b, e )
			      	local found = data.doesWordExist( word )
					-- dbg.statusMessage( TAG, "checkMatchPartRow[1]", "[r: " .. r .. "] [l: " .. l .. "] [b: " .. b .. "] [e: " .. e .. "]" )
					-- dbg.statusMessage( "checkMatchPartRow[2]", word, (found and "true" or "false") )
			      	local match = found and color
			      	if( match ) then 
		    		  	-- dbg.statusMessage( "checkMatchPartRow", word, (found and "true" or "false") )
			      		updateWordFound( word, true )
			      		return b, e
			      	end
  				end
  			end
  		end

  		return -1, -1
  	end

  	-- ----------------------------------------
  	-- return the uniform colour in column c - else nil if not uniform (bi = begin index; ei = end index)
  
  	function board:getColorCol( c, bi, ei )

		local b = bi or 1
		local e = ei or rows
		local color = nil
		local p1 = board:getPiece(b,c)
		if( p1 ) then 
			color = p1[1].color  -- colour in first square in sequence
		    for r = b+1, e do
		    	local p2 = board:getPiece(r,c)
		    	if( (not p2) or (p2[1].color ~= color) ) then 
		    		color = nil
		    		break
		    	end
		    end
		end
	    return color
	end

	-- ----------------------------------------
	-- return the uniform colour in row r - else nil if not uniform (bi = begin index; ei = end index)
  
	function board:getColorRow( r, bi, ei )

		local b = bi or 1
		local e = ei or cols
		local color = nil
		local p1 = board:getPiece(r,b)
		if( p1 ) then 
			color = p1[1].color  -- colour in first square in sequence
		    for c = b+1, e do
		    	local p2 = board:getPiece(r,c)
		    	if( (not p2) or (p2[1].color ~= color) ) then 
		    		color = nil
		    		break
		    	end
		    end
		end
	    return color
	end

  	-- ----------------------------------------
  	-- return the word in column c - (bi = begin index; ei = end index)

  	function board:getWordCol( c, bi, ei )

      	local b = bi or 1
		local e = ei or rows
      	local word = ""
      	for r = b, e do
        	local p = board:getPiece(r,c)
        	if( p ) then 
         		word = word .. p[2].letter
         	end
      	end
      	return word
  	end

  	-- ----------------------------------------
  	-- return the word in row r - (bi = begin index; ei = end index)

  	function board:getWordRow( r, bi, ei )

      	local b = bi or 1
		local e = ei or cols
		local word = ""
      	for c = b, e do
         	local p = board:getPiece(r,c)
         	if( p ) then 
         		word = word .. p[2].letter
         	end
      	end
      	return word
  	end

	-- ----------------------------------------
 	
	function board:getStatus()

		return board.status 
	end

 	-- ----------------------------------------
 	-- check whether game is over due to no moves remaining

  	function board:checkGameOver()

  		--[[
  		print( "Lock count: "  .. lockCount )
  		print( "cols: " .. cols .. " - rows: " .. rows)
  		print( "Moves limit: "  .. opt.gameOptions.moveLimit )
  		--]]
  		board:updateLockCount()
  		if( (opt.gameOptions.moveLimit > 0) and (lockCount >= cols * rows) ) then 
  			board:gameOver( "No moves remaining")
  		end
 	end

	-- ----------------------------------------
	-- handle game over

	function board:gameOver( reason )
		board:pause()
		board.status = "ended"
		parentScene:gameOver( reason )
	end

	-- ----------------------------------------
 	-- Update the lock count

 	function board:updateLockCount()

 		lockCount = 0

	    for i = 1, #board.piece do
	    	s = board.piece[i][1]
	    	if( (opt.gameOptions.moveLimit > 0) and (s.moves >= opt.gameOptions.moveLimit) ) then
	    		lockCount = lockCount + 1
	    	end
	    end
 	end

 	-- ----------------------------------------
 	-- return true if ok to move a square 

  	function board:checkMoveLimit( squareGroup )

	  	-- draw a line to indicate move limit
	  	local function drawLine( x1, y1, x2, y2 )
	  		local line = display.newLine( x1, y1, x2, y2 )
	    	line:setStrokeColor( 1, 0, 0, 0.3 )
	    	line.strokeWidth = 20
	    	squareGroup:insert( line )

	  	end
	  	
	  	local moveOk = false	-- return value
	  	local square = squareGroup[1]
	  	local w = square.width / 2 - square.width * 0.05
	    local h = square.height / 2 - square.width * 0.05

	  	if( opt.gameOptions.moveLimit == 0 ) then 
	  		-- no restrictions on number of moves
	  		moveOk = true
	        square.moves = square.moves + 1
	  	elseif( opt.gameOptions.moveLimit == 1 ) then
	  		-- only one move allowed 
	  		if( square.moves < 1 ) then 
	            moveOk = true
	            square:setFillColor ( col.getGradient( square.color ))
	            -- draw both lines
	            drawLine( -w, -h, w, h )
	            drawLine( -w, h, w, -h )
	            square.moves = square.moves + 1
	            board:checkGameOver()
	        end
	  	else
	  		-- two moves allowed
	  		if( square.moves == 0 ) then 
	  			moveOk = true 
		      square.moves = square.moves + 1
	  			square:setFillColor ( col.getGradient( square.color ))
	    		drawLine( -w, -h, w, h )            
	  		elseif( square.moves == 1 ) then 
	  			    moveOk = true
	            square.moves = square.moves + 1
	            drawLine( -w, h, w, -h )
	            board:checkGameOver()
	  		end
	  	end
	  	if( not moveOk ) then 
	  		snd.playSound( snd.sounds.locked )
	  		if( opt.gameOptions.haptic ) then
	  			system.vibrate()
	  		end
	  	end

	  	return moveOk
	end

	-- ----------------------------------------
  	-- return a weighted random letter, accounting for greater need for vowels in each colour
 
   	function board:getRandomLetter( color )

     	local rndLetter  -- return value
     	local vc = 0    -- vowel count

	    -- count current vowels in the provided color
	    for i = 1, #board.piece do
	    	c = board.piece[i][1].color
	    	if( c == color ) then 
		    	l = string.lower( board.piece[i][2].letter )
		    	if( l == "a" or l == "e" or l == "i" or l == "o" or l == "u" ) then 
		    		vc = vc + 1
		    	end
	    	end
	    end
	    -- get minimum recommended number of vowels
	    local minv = opt.gameOptions.tileCount - opt.gameOptions.colorCount
	    assert( (minv > 0), TAG .. "[board:getRandomLetter][1]" )
	    -- if the vowel count < the recommended minimum, then use a 33% probability of selecting a random vowel
	    if( vc < minv and math.random(1,3) == 2 ) then 
	    	rndLetter = data.getRandomVowel()
	    	-- dbg.statusMessage( TAG, "board:getRandomLetter", "Random vowel: " .. rndLetter .. " - minv: " .. minv .. " - vc: " .. vc )
	    else
	    	rndLetter = data.getRandomLetter()
	    	-- dbg.statusMessage( TAG, "board:getRandomLetter", "Random letter: " .. rndLetter .. " - minv: " .. minv .. " - vc: " .. vc )
	    end
     	
     	return rndLetter  
  	end

  	-- ----------------------------------------
  	-- 

  	function board:cull()
    	if not board.removeSelf then return false end 
	    if paused then return false end        
	    local pieces = board.piece
	    if pieces == nil then return false end
	    local cull = false
	    board.status = "matching"

	    local numMulti = 0
	    -- horizontal
	    for r = 1, rows do
	    	-- get begin and end indices of matched word
	    	local b, e = board:checkMatchPartRow( r ) 
	    	if( b > 0 and e > 0 ) then 
	        	board.status = "matched"
	        	numMulti = numMulti + 1
	        	for c = b, e do
	          		local piece = board:getPiece(r,c)
	          		if( piece ) then 
	          			piece.cull = true
	          			cull = true
	          		end
	        	end
	      	end	      
	    end
    	-- vertical
	    for c = 1, cols do
	    	-- get begin and end indices of matched word
	    	local b, e = board:checkMatchPartCol( c ) 
	    	if( b > 0 and e > 0 ) then 
	        	board.status = "matched"             
	        	numMulti = numMulti + 1
	        	for r = b, e do
	          		local piece = board:getPiece(r,c)
	          		if( piece ) then 
	          			piece.cull = true
	          			cull = true
	          		end
	        	end
	      	end
	    end
    	-- check whether more than one word has been found
    	if( numMulti > 1 ) then 
      		opt.score.numMultiple = opt.score.numMultiple + numMulti
    	end

    	if cull then
      		board.status = "culling"
      		updateScore( { phase = board.status } )  
      		local pieces = board.piece
      		if pieces == nil then return false end
      		for i = #pieces, 1, -1 do
        		if pieces[i].cull then
          			puff({g = self, x = pieces[i].x, y = pieces[i].y, isExplosion = false})
          			snd.playSound( snd.sounds.wordFound )
          			-- transition.to (pieces[i], { tag="board", time = 233, xScale = 0.001, yScale = 0.001, transition=easing.outExpo }) -- original
        		end
      		end
      		-- board.timer[#board.timer+1] = timer.performWithDelay(250, function () board:drop("down") end) -- original
      		board:drop("down") -- new ###
      		board:updateLockCount()
    	else
      		board.status = "idle"
    	end
  	end

  	-- ----------------------------------------
  	-- 

  	function board:drop( direction )
    	
  		if not board.removeSelf then return false end    
    	board:recycle()
    	board.status = "dropping"
    	local drop = false
    	-- set gravity
    	direction = direction or "down"
    	if direction == "down" then
	      	-- find gaps
	      	for i = rows,1,-1 do
	        	for j = cols,1,-1 do
	          		if not board:getPiece(i,j) then -- we have a gap
	            		if board:getPiece(i-1,j) then
	              			drop = true
	              			-- transition.to(board:getPiece(i-1,j), { tag="board", delta = true, time=1000, y = height+1, transition=easing.outBounce } ) -- original
	              			transition.to(board:getPiece(i-1,j), { tag="board", delta = true, time=0, y = height, transition=easing.outBounce } )
	              			board:getPiece(i-1,j).r = i
	            		end
	          		end
	        	end
	      	end
    	else
      		-- find gaps
      		for i = 1,rows do
        		for j = 1,cols do
          			if not board:getPiece(i,j) then -- we have a gap
            			if board:getPiece(i+1,j) then
              				drop = true
              				-- transition.to(board:getPiece(i+1,j), { tag="board", delta = true, time=1000, y = -(height+1), transition=easing.outBounce } ) -- original
              				transition.to(board:getPiece(i+1,j), { tag="board", delta = true, time=0, y = -height, transition=easing.outBounce } )
              				board:getPiece(i+1,j).r = i
            			end
          			end
        		end
      		end
    	end

    	if drop then
      		-- board.timer[#board.timer+1] = timer.performWithDelay(250, function () board:drop(direction) end )  -- original
      		board.timer[#board.timer+1] = timer.performWithDelay(500, function () board:drop(direction) end )
    	else
      		board:replenish() -- original
    	end
  	end



  	-- ----------------------------------------

  	function board:replenish()
    	if not board.removeSelf then return false end    
    	board:recycle()    
    	for i = 1, rows do
      		for j = 1, cols do
        		if not board:getPiece(i,j) then board:newPiece(i,j) end
      		end
    	end
    	-- board.timer[#board.timer+1] = timer.performWithDelay(250, function () board:cull() end ) -- original
    	board.timer[#board.timer+1] = timer.performWithDelay(500, function () board:cull() end ) 
  	end

  	-- ----------------------------------------

  	function board:finalize()
    	if not board.removeSelf then return false end    
    	transition.cancel("board")
    	board.status = "finalizing"
    	snd.playTimer( false )
    	-- clean up timers
    	for i = #board.timer, 1, -1 do
      		timer.cancel(board.timer[i])
      		board.timer[i]=nil 
    	end
  	end
  
    -- ----------------------------------------

  	function board:recycle()
    	if not board.removeSelf then return false end    
    	-- object cleanup
    	local pieces = board.piece
    	if pieces == nil then return false end

    	-- compact table
    	for i = #pieces,1,-1 do
      		if pieces[i].cull then
        		display.remove(pieces[i])
        		table.remove(pieces,i)  
      		end
    	end

    	-- re-id
    	for i = 1, #pieces,1 do
      		pieces[i].id = i
    	end    
  	end

  -- ---------------------------------------------------------------------------------------
-- Test functions
-- ---------------------------------------------------------------------------------------
	-- inject partially formed words which require only one char to be moved in order to match

	function board:testInjectWord()

		if( not dbg.runTests ) then return end

		-- inject a given character at a specific location
		local function doInject( r, c, char )
			local square = board:getPiece( c, r )
      		square[2].text = char
      		square[2].letter = char
      		square[1]:setFillColor( unpack(col.colIvory) )
		end

		-- add the same letter at two locations
		local function injectLetter( r, c, char )
			doInject( r, c, char )
			doInject( c, r, char )
		end

		-- add horizontal and vertical test words for tile counts of 4, 5 and 6
		injectLetter( 2, 1, "t" )
		injectLetter( 2, 2, "e" )
		injectLetter( 2, 3, "s" )
		injectLetter( 3, 4, "t" )
		if( opt.gameOptions.tileCount == 5 ) then 
			injectLetter( 2, 5, "s" )
		elseif( opt.gameOptions.tileCount == 6) then 
			injectLetter( 2, 5, "e" )
			injectLetter( 2, 6, "r" )
		end
	end

  -- ----------------------------------------

  	-- end of 'new' function
	board:addEventListener('finalize')

  	-- add the pieces
  	board:replenish()
  	board:recycle()  

  	return board
end

-- ---------------------------------------------------------------------------------------

return M

-- ---------------------------------------------------------------------------------------

