local arg1 = ...
sensitive_test_file = fs.open(arg1, "r")
loaded_blueprint = textutils.unserialise(sensitive_test_file.readAll())
sensitive_test_file.close()
local position_sensitive_blocks = {}
total_sensitive_found = 1

for x=1,#loaded_blueprint do
    for y=1,#loaded_blueprint[x] do
        for z=1,#loaded_blueprint[x][y] do
            local cell = loaded_blueprint[x][y][z]
            if cell.info.state and cell.info.state.facing then                    
                if not position_sensitive_blocks[total_sensitive_found] or position_sensitive_blocks[total_sensitive_found].pos ~= cell.coords then
                    table.insert(position_sensitive_blocks, total_sensitive_found, {name = cell.info.name, facing = cell.info.state.facing, pos = cell.coords})
                elseif position_sensitive_blocks[total_sensitive_found].pos == cell.coords then
                    table.insert(position_sensitive_blocks, total_sensitive_found, {facing = cell.info.state.facing})
                end
            end
            if cell.info.state and cell.info.state.half then
                if not position_sensitive_blocks[total_sensitive_found] or position_sensitive_blocks[total_sensitive_found].pos ~= cell.coords then
                    table.insert(position_sensitive_blocks, total_sensitive_found, {name = cell.info.name, half = cell.info.state.half, pos = cell.coords})
                elseif position_sensitive_blocks[total_sensitive_found].pos == cell.coords then
                    position_sensitive_blocks[total_sensitive_found] = {name = cell.info.name, half = cell.info.state.half, facing = info.state.facing, pos = cell.coords}
                end
            end
            if cell.info.state and cell.info.state.axis then
                if not position_sensitive_blocks[total_sensitive_found] or position_sensitive_blocks[total_sensitive_found].pos ~= cell.coords then
                    table.insert(position_sensitive_blocks, total_sensitive_found, {name = cell.info.name, axis = cell.info.state.axis, pos = cell.coords})
                elseif position_sensitive_blocks[total_sensitive_found].pos == cell.coords then
                    position_sensitive_blocks[total_sensitive_found] = {name = cell.info.name, axis = cell.info.state.axis, half = info.state.half, pos = cell.coords}
                end
            end
            if cell.info.state and (cell.info.state.axis or cell.info.state.half or cell.info.state.facing) then
                total_sensitive_found = total_sensitive_found + 1
            end
        end
    end
end

local sensitive_test_file = fs.open("sensitive.data", "w")
sensitive_test_file.write(textutils.serialise(position_sensitive_blocks, { compact = true }))
sensitive_test_file.close()
--[[
for x=1,#loaded_blueprint do
  for y=1,#loaded_blueprint[x] do
    for z=1,#loaded_blueprint[x][y] do
    end
  end
end
]]--