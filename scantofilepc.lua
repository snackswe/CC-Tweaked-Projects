local facing = 0 -- clockwise rotation is positive, counter is negative
local pos = { x = 0, y = 0, z = 0 } -- forward/up is positive, back/down is negative
local origin = { x = 0, y = 0, z = 0 }

function face(desired) -- relative cardinal direction function
	if desired == 3 and facing == 0 then 
		turtle.turnLeft()
		facing = 3
	elseif desired == 0 and facing == 3 then
		turtle.turnRight()
		facing = 0
	-- check if it can minimise turns since 360 degrees (position 0) is close to 270 degrees (positon 3)

	elseif desired > facing then -- check if positive (clockwise) rotation is needed to reach the desired position
		for i = 1, (desired - facing) do -- add clockwise rotation till the desired degree of clockwise rotation is met
			turtle.turnRight()
			facing = facing + 1
		end
	elseif desired < facing then -- check if negative (counterclockwise) rotation is needed to reach the desired position
		for i = 1, (facing - desired) do -- add counterclockwise rotation till the desired degree of clockwise rotation is met
			turtle.turnLeft()
			facing = facing -1
		end
	else -- if no rotation is needed to reach the desired position, then return (you're already facing the right way!)
		return
	end
end

function go(axis, distance)
	local bumpThrow = "Scan incomplete.\nEnsure there is at least a 1 block perimiter of air around scanned area"
	local axisPol = 1
	if distance < 0 then axisPol = -1 end 
	-- check if request wants to move negative blocks on the given axis, then adjust the negativity variable

	local axisDir = axis .. tostring(axisPol) -- make the polarity(number) into a string and combine it with the axis(string) to make that info 1 datatype so it can be used as a key
	local faceNum = {["x1"] = 0, ["x-1"] = 2, ["z1"] = 1, ["z-1"] = 3} -- use the requested axis and polarity to determine the appropriate degree of rotation to move in the desired relative direction

	if axis ~= "y" then -- use this loop for the x and z axis because they can use turtle.forward() for positive and negative movement
		face(faceNum[axisDir]) -- face the appropriate degree of rotation
		for i = 1, math.abs(tonumber(distance)) do -- loop for the requested number of times (not including the polarity)
			local bump, junk = turtle.inspect()
			if bump then
				print(bumpThrow)
				break
			end
			turtle.forward()
			pos[axis] = pos[axis] + axisPol -- 
		end
	elseif axisPol == -1 then -- use this loop for moving negative on the y axis
		for i = 1, math.abs(tonumber(distance)) do
			local bump, junk = turtle.inspect()
			if bump then
				print(bumpThrow)
				break
			end
			turtle.down()
			pos[axis] = pos[axis] + axisPol -- 
		end
	else -- use this loop for moving positive on the y axis
		for i = 1, distance do
			local bump, junk = turtle.inspectUp()
			if bump then
				print(bumpThrow)
				break
			end
			turtle.up()
			pos[axis] = pos[axis] + axisPol 
		end
	end
end

function Comparecoords(ref, sup, strict)
    local conAx = {x = false, y = false, z = false} -- track which axes are the same as supplied 
    if ref.x == sup.x then conAx.x = true end
    if ref.z == sup.z then conAx.z = true end
    if ref.y ~= nil and ref.y == sup.y then -- only compare y if referenced has it
        conAx.y = true
    elseif ref.y == nil then
        return conAx.x, nil, conAx.z
    end
    
    if not (conAx.x and conAx.y and conAx.z) and strict and sup.y ~= nil then
        return false, false, false
    elseif not (conAx.x and conAx.z) and strict then
        return false, nil, false
    end

    return conAx.x, conAx.y, conAx.z
end

function goTo(sup) -- sup (10 2 0) pos (-30, 4, 10)
	go("x", sup.x - pos.x)
	go("z", sup.z - pos.z)
	go("y", sup.y - pos.y)
end

term.clear()
term.setCursorPos(1,1)
print("1. Place turtle adjacent to the corner of the first slice \n2. Input dimentions x, y, z, of area relative to turtle placement (x = blocks forward, y = slices total, z = blocks right): ")
local input = read()
local one, two, three = input:match("([^,]+),([^,]+),([^,]+)")
local model = fs.open("models/model.data", "w")
local xDir = 1
local zDir = 1
local even
local layers = math.ceil(two / 2)
local bP = {}
if two % 2 == 0 then even = true end
for x = 1, one do
  bP[x] = {}
  for y = 1, two do
    bP[x][y] = {}
    for z = 1, three do
      bP[x][y][z] = {}
    end
  end
end

for i = 1, layers do
	go("z", zDir)
	go("x", xDir)
	local layer = i
	for i = 1, three do	
		for i = 1, one do
			local junk, bB = turtle.inspectDown()
			bP[pos.x][layer][pos.z] = {info = bB, coords = tostring(pos.x) .. "," .. tostring(layer) .. "," .. tostring(pos.z)}
			if layer < layers or even then
				local junk, tB = turtle.inspectUp()
				bP[pos.x][layer + 1][pos.z] = {info = tB, coords = tostring(pos.x) .. "," .. tostring(layer + 1) .. "," .. tostring(pos.z)}
			end
			go("x", xDir)
		end	
		xDir = xDir * -1
		go("z", zDir)
		go("x", xDir)
	end	
	if layers > 1 and layer < layers then goTo({x = pos.x - xDir, y = pos.y + 3,z = pos.z})end
	zDir = zDir * -1
end
goTo(origin)
face(0)
for i, tab in pairs(bP) do
  model.write(textutils.serialise(tab))
end
model.close()