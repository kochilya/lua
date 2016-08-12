local r = require ('robot')
local c = require ('computer')
local tArgs = { ... }
if #tArgs ~= 1 then
	print( "Usage: excavate <diameter>" )
	return
end

-- Mine in a quarry pattern until we hit something we can't dig
local size = tonumber( tArgs[1] )
if size < 1 then
	print( "Excavate diameter must be positive" )
	return
end

local depth = 0
local unloaded = 0
local collected = 0

local xPos,zPos = 0,0
local xDir,zDir = 0,1

local goTo -- Filled in further down
local refuel -- Filled in further down

local function unload( _bKeepOneFuelStack )
	print( "Unloading items..." )
	for n=1,16 do
		local nCount = r.count(n)
		if nCount > 0 then
			r.select(n)
			local bDrop = true
--			if _bKeepOneFuelStack and r.refuel(0) then
--				bDrop = false
--				_bKeepOneFuelStack = false
--			end
			if bDrop then
				r.drop()
				unloaded = unloaded + nCount
			end
		end
	end
	collected = 0
	r.select(1)
end

local function returnSupplies()
	local x,y,z,xd,zd = xPos,depth,zPos,xDir,zDir
	print( "Returning to surface..." )
	goTo( 0,0,0,0,-1 )

--	local fuelNeeded = 2*(x+y+z) + 1
--	if not refuel( fuelNeeded ) then
--		unload( true )
--		print( "Waiting for fuel" )
--		while not refuel( fuelNeeded ) do
--			sleep(1)
--		end
--	else
		unload( true )
--	end

	print( "Resuming mining..." )
	goTo( x,y,z,xd,zd )
end

local function collect()
	local bFull = true
	local nTotalItems = 0
	for n=1,16 do
		local nCount = r.count(n)
		if nCount == 0 then
			bFull = false
		end
		nTotalItems = nTotalItems + nCount
	end

	if nTotalItems > collected then
		collected = nTotalItems
		if math.fmod(collected + unloaded, 50) == 0 then
			print( "Mined "..(collected + unloaded).." items." )
		end
	end

	if bFull then
		print( "No empty slots left." )
		return false
	end
	return true
end

function refuel( ammount )
--[[
	local fuelLevel = c.energy()
	if fuelLevel == "unlimited" then
		return true
	end

	local needed = ammount or (xPos + zPos + depth + 1)
	if c.energy() < needed then
		local fueled = false
		for n=1,16 do
			if r.count(n) > 0 then
				r.select(n)
				if r.refuel(1) then
					while r.count(n) > 0 and c.energy() < needed do
						r.refuel(1)
					end
					if c.energy() >= needed then
						r.select(1)
						return true
					end
				end
			end
		end
		r.select(1)
		return false
	end
--]]
	return true
end

local function tryForwards()
	if not refuel() then
		print( "Not enough Fuel" )
		returnSupplies()
	end

	while not r.forward() do
		if r.detect() then
			if r.swing() then
				if not collect() then
					returnSupplies()
				end
			else
				return false
			end
		elseif r.attack() then
			if not collect() then
				returnSupplies()
			end
		else
			sleep( 0.5 )
		end
	end

	xPos = xPos + xDir
	zPos = zPos + zDir
	return true
end

local function tryDown()
	if not refuel() then
		print( "Not enough Fuel" )
		returnSupplies()
	end

	while not r.down() do
		if r.detectDown() then
			if r.digDown() then
				if not collect() then
					returnSupplies()
				end
			else
				return false
			end
		elseif r.attackDown() then
			if not collect() then
				returnSupplies()
			end
		else
			sleep( 0.5 )
		end
	end

	depth = depth + 1
	if math.fmod( depth, 10 ) == 0 then
		print( "Descended "..depth.." metres." )
	end

	return true
end

local function turnLeft()
	r.turnLeft()
	xDir, zDir = -zDir, xDir
end

local function turnRight()
	r.turnRight()
	xDir, zDir = zDir, -xDir
end

function goTo( x, y, z, xd, zd )
	while depth > y do
		if r.up() then
			depth = depth - 1
		elseif r.digUp() or r.attackUp() then
			collect()
		else
			sleep( 0.5 )
		end
	end

	if xPos > x then
		while xDir ~= -1 do
			turnLeft()
		end
		while xPos > x do
			if r.forward() then
				xPos = xPos - 1
			elseif r.dig() or r.attack() then
				collect()
			else
				sleep( 0.5 )
			end
		end
	elseif xPos < x then
		while xDir ~= 1 do
			turnLeft()
		end
		while xPos < x do
			if r.forward() then
				xPos = xPos + 1
			elseif r.dig() or r.attack() then
				collect()
			else
				sleep( 0.5 )
			end
		end
	end

	if zPos > z then
		while zDir ~= -1 do
			turnLeft()
		end
		while zPos > z do
			if r.forward() then
				zPos = zPos - 1
			elseif r.dig() or r.attack() then
				collect()
			else
				sleep( 0.5 )
			end
		end
	elseif zPos < z then
		while zDir ~= 1 do
			turnLeft()
		end
		while zPos < z do
			if r.forward() then
				zPos = zPos + 1
			elseif r.dig() or r.attack() then
				collect()
			else
				sleep( 0.5 )
			end
		end
	end

	while depth < y do
		if r.down() then
			depth = depth + 1
		elseif r.digDown() or r.attackDown() then
			collect()
		else
			sleep( 0.5 )
		end
	end

	while zDir ~= zd or xDir ~= xd do
		turnLeft()
	end
end

if not refuel() then
	print( "Out of Fuel" )
	return
end

print( "Excavating..." )

local reseal = false
r.select(1)
if r.digDown() then
	reseal = true
end

local alternate = 0
local done = false
while not done do
	for n=1,size do
		for m=1,size-1 do
			if not tryForwards() then
				done = true
				break
			end
		end
		if done then
			break
		end
		if n<size then
			if math.fmod(n + alternate,2) == 0 then
				turnLeft()
				if not tryForwards() then
					done = true
					break
				end
				turnLeft()
			else
				turnRight()
				if not tryForwards() then
					done = true
					break
				end
				turnRight()
			end
		end
	end
	if done then
		break
	end

	if size > 1 then
		if math.fmod(size,2) == 0 then
			turnRight()
		else
			if alternate == 0 then
				turnLeft()
			else
				turnRight()
			end
			alternate = 1 - alternate
		end
	end

	if not tryDown() then
		done = true
		break
	end
end

print( "Returning to surface..." )

-- Return to where we started
goTo( 0,0,0,0,-1 )
unload( false )
goTo( 0,0,0,0,1 )

-- Seal the hole
if reseal then
	r.placeDown()
end

print( "Mined "..(collected + unloaded).." items total." )