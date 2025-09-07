facing = 0 -- clockwise rotation is positive, counter is negative
pos = { x = 0, y = 0, z = 0 } -- forward/up is positive, back/down is negative

function Face(desired) -- relative cardinal direction function
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

function Go(axis, distance)
	local axisPol = 1
	if distance < 0 then -- check if request wants to move negative blocks on the given axis
		axisPol = -1 -- update the negativity variable
	end
	local axisDir = axis .. tostring(axisPol) -- make the polarity(number) into a string and combine it with the axis(string) to make that info 1 datatype so it can be used as a key
	local faceNum = {["x1"] = 0, ["x-1"] = 2, ["z1"] = 1, ["z-1"] = 3} -- use the requested axis and polarity to determine the appropriate degree of rotation to move in the desired relative direction
	if axis ~= "y" then -- use this loop for the x and z axis because they can use turtle.forward() for positive and negative movement
		Face(faceNum[axisDir]) -- face the appropriate degree of rotation
		for i = 1, math.abs(tonumber(distance)) do -- loop for the requested number of times (not including the polarity)
			turtle.forward()
			pos[axis] = pos[axis] + axisPol -- 
		end
	elseif axisPol == -1 then -- use this loop for moving negative on the y axis
		for i = 1, math.abs(tonumber(distance)) do
			turtle.down()
			pos[axis] = pos[axis] + axisPol
		end
	else -- use this loop for moving positive on the y axis
		for i = 1, distance do
			turtle.up()
			pos[axis] = pos[axis] + axisPol
		end
	end
end

while true do
	term.clear()
	term.setCursorPos(1,1)
	print("Facing direction " .. tostring(facing) .. " on the relative axis")
	print(textutils.serialise(pos))
	write("Enter move axis, distance: ")
	local input = read()
	local axis
	local distance
	if input == "exit" then 
		term.clear()
		break 
	end
	one, two = input:match("([^,]+),([^,]+)")    
	if one == "face" then
		Face(tonumber(two))
	elseif one == "scan" then
		local isBlock, data = turtle.inspectDown()
		print(textutils.serialise(data))
		sleep(3)
	else
		print(one, two)
        Go(one, tonumber(two))
    end
end
