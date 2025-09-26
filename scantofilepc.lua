term.clear()
term.setCursorPos(1,1)
print("1. Place turtle on top of the corner block of the first slice. \n(x = total area left incl 1st block, y = total height not including the spacing between slices, z = total area forwards incl 1st block) \n2. Input dimentions \"x, y, z\" of blueprint: ")
--These variables are just for the main loop
	local input = read()
	local POSITIVE_X_LENGTH_TOTAL, SLICES, POSITIVE_Z_LENGTH_TOTAL = input:match("([^,]+),([^,]+),([^,]+)")
	local x_increment_direction = 1
	local z_increment_direction = 1
	local SANDWICHES_TOTAL = math.ceil(SLICES / 2)
	local blueprint_data = {}
	local SLICES_EVEN if SLICES % 2 == 0 then SLICES_EVEN = true end
	local ORIGIN = relative_turtle_coordinates
	for x = 1, POSITIVE_X_LENGTH_TOTAL do
		blueprint_data[x] = {}
		for y = 1, SLICES do
			blueprint_data[x][y] = {}
			for z = 1, POSITIVE_Z_LENGTH_TOTAL do
			blueprint_data[x][y][z] = {}
			end
		end
	end

--[[A turtle placed will always start off facing positive on the relative "z" axis when placed down. (0 degrees)
Likewise, the relative "x" axis will be positive in the direction to the left of the turtle's starting position (-90 or +270 degrees).
This is a stylistic choices inspired by Minecraft's cardinal directions, but the cardinal directions and coordinates this program uses are relative to the turtle and not the world]]--
local relative_turtle_coordinates = { 
	x = 1, 
	y = 1, 
	z = 1, 
}
local current_cardinal = 0
local horizontal_direction_to_cardinal = {
	["z1"] = 0,
	["x-1"] = 1,
	["z-1"] = 2,		
	["x1"] = 3,
} --This table should help visualize the cardinal directions and which cardinal will increment/decrement the horizontal position components.

function turnTo(desired_cardinal)
	--Since turtles turn in 90 degree increments, and therefore 4 turns in a given direction is the same as 0, I figured this check was the easiest was to reduce the steps required to reach the desired cardinal.
	if desired_cardinal == 3 and current_cardinal == 0 then 
		turtle.turnLeft()
		current_cardinal = 3
		return
	elseif desired_cardinal == 0 and current_cardinal == 3 then
		turtle.turnRight()
		current_cardinal = 0
		return
	end

	--There was probably a better way to represent the cardinals here, and maybe eliminate the need for the check at the top of this function but idk.
	if desired_cardinal > current_cardinal then
		for i = 1, (desired_cardinal - current_cardinal) do
			turtle.turnRight()
			current_cardinal = current_cardinal + 1
		end
	elseif desired_cardinal < current_cardinal then
		for i = 1, (current_cardinal - desired_cardinal) do
			turtle.turnLeft()
			current_cardinal = current_cardinal -1
		end
	end
end

function move_along_axis(axis, distance_along_axis)
	--It seemed okay to use string concatenation to make keys for the cardinal direction table. (Though, it may be inefficient and dumb ¯\_(ツ)_/¯ idk.)
	if distance_along_axis == 0 then return end --This return is here bc my code is sloppy and calls move_along_axis() with variables (which can potentially be 0, making the following code useless).
	local axis_increment_direction = 1 if distance_along_axis < 0 then axis_increment_direction = -1 end 
	local axis_and_direction = axis .. tostring(axis_increment_direction)

	--Pathfinding is too complicated for the scope of this project and feels unnecessary since the environment should be constant, so this function just throws an error if there's stuff in the way.
	local path_blocked_error = "Scan incomplete.\nEnsure there is at least a 1 block perimiter of air around scanned area..."

	if axis ~= "y" then --Since turtles can't look backwards, and can't look or move to the sides, the turtle needs to be facing any horizontal movement so it can properly detect collision.
		turnTo(horizontal_direction_to_cardinal[axis_and_direction]) 
		for i = 1, math.abs(tonumber(distance_along_axis)) do
			local direction_moving_blocked, _ = turtle.inspect()
			if direction_moving_blocked then
				print(path_blocked_error)
				break
			end
			turtle.forward()
		end
	elseif axis_increment_direction == -1 then
		for i = 1, math.abs(tonumber(distance_along_axis)) do
			local direction_moving_blocked, _ = turtle.inspectDown()
			if direction_moving_blocked then
				print(path_blocked_error)
				break
			end
			turtle.down()
		end
	else 
		for i = 1, distance_along_axis do
			local direction_moving_blocked, _ = turtle.inspectUp()
			if direction_moving_blocked then
				print(path_blocked_error)
				break
			end
			turtle.up()
		end
	end
	relative_turtle_coordinates[axis] = relative_turtle_coordinates[axis] + (distance_along_axis * axis_increment_direction)
end

for s = 1, SANDWICHES_TOTAL do
	local currently_filling_sandwich = s
	local current_bottom_slice = s + (s - 1)
	for x = 1, POSITIVE_X_LENGTH_TOTAL do	
		for z = 1, POSITIVE_Z_LENGTH_TOTAL do
			local _, bottom_block_info = turtle.inspectDown()
			blueprint_data[relative_turtle_coordinates.x][current_bottom_slice][relative_turtle_coordinates.z] = {info = bottom_block_info, coords = tostring(relative_turtle_coordinates.x) .. "," .. tostring(current_bottom_slice) .. "," .. tostring(relative_turtle_coordinates.z)}
			if currently_filling_sandwich < SANDWICHES_TOTAL or SLICES_EVEN then
				local _, top_block_info = turtle.inspectUp()
				local current_top_slice = current_bottom_slice + 1
				blueprint_data[relative_turtle_coordinates.x][current_top_slice][relative_turtle_coordinates.z] = {info = top_block_info, coords = tostring(relative_turtle_coordinates.x) .. "," .. tostring(current_top_slice) .. "," .. tostring(relative_turtle_coordinates.z)}
			end
			if z < tonumber(POSITIVE_Z_LENGTH_TOTAL) then
				move_along_axis("z", z_increment_direction)
			end
		end	
		if x < tonumber(POSITIVE_X_LENGTH_TOTAL) then
			move_along_axis("x", x_increment_direction)
		end
		x_increment_direction = x_increment_direction * -1
	end	
	if SANDWICHES_TOTAL > 1 and currently_filling_sandwich < SANDWICHES_TOTAL then 
		move_along_axis("z", (z_increment_direction * -1))
		move_along_axis("y", 3)
		move_along_axis("z", z_increment_direction)
	end		
	x_increment_direction = x_increment_direction * -1
end	
--This little chunk of code should make sure that the turtle comes home after scanning, even if it's many sandwiches up.
local distance_to_origin_x, distance_to_origin_z, distance_to_origin_y = ORIGIN.x - relative_turtle_coordinates.x, ORIGIN.z - relative_turtle_coordinates.z, ORIGIN.y - relative_turtle_coordinates.y
if SANDWICHES_TOTAL > 1 then
	move_along_axis("z", (z_increment_direction * -1)) --Clears the the 
	move_along_axis("y", distance_to_origin_y)
end

move_along_axis("x", distance_to_origin_x)
move_along_axis("z", distance_to_origin_z)
turnTo(0)

--Writes the dimentions of the blueprint and the data scanned to a data file on the turtle's local file system
table.insert(blueprint_data, {dimentions = {x = POSITIVE_X_LENGTH_TOTAL, y = SLICES, z = POSITIVE_Z_LENGTH_TOTAL}})
local model = fs.open("models/model.data", "w")
model.write(textutils.serialise(blueprint_data, { compact = true }))
model.close()