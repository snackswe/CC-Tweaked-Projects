local arg1 = ...
sensitive_test_file = fs.open(arg1, "r")
loaded_blueprint = textutils.unserialise(sensitive_test_file.readAll())
sensitive_test_file.close()
local position_sensitive_blocks = {}
total_sensitive_found = 0

local update_sensitive_list_from_table(supplied)
    if supplied.info.state and supplied.info.state.facing then                    
        if not position_sensitive_blocks[total_sensitive_found + 1] or position_sensitive_blocks[total_sensitive_found + 1].pos ~= supplied.coords then
            table.insert(position_sensitive_blocks, total_sensitive_found, {name = supplied.info.name, facing = supplied.info.state.facing, pos = supplied.coords})
        elseif position_sensitive_blocks[total_sensitive_found + 1].pos == supplied.coords then
            table.insert(position_sensitive_blocks, total_sensitive_found, {facing = supplied.info.state.facing})
        end
    end

    if supplied.info.state and supplied.info.state.half then
        if not position_sensitive_blocks[total_sensitive_found + 1] or position_sensitive_blocks[total_sensitive_found + 1].pos ~= supplied.coords then
            table.insert(position_sensitive_blocks, total_sensitive_found, {name = supplied.info.name, half = supplied.info.state.half, pos = supplied.coords})
        elseif position_sensitive_blocks[total_sensitive_found + 1].pos == supplied.coords then
            position_sensitive_blocks[total_sensitive_found + 1] = {name = supplied.info.name, half = supplied.info.state.half, facing = info.state.facing, pos = supplied.coords}
        end
    end
    if supplied.info.state and supplied.info.state.axis then
        if not position_sensitive_blocks[total_sensitive_found + 1] or position_sensitive_blocks[total_sensitive_found + 1].pos ~= supplied.coords then
           table.insert(position_sensitive_blocks, total_sensitive_found, {name = supplied.info.name, axis = supplied.info.state.axis, pos = supplied.coords})
        elseif position_sensitive_blocks[total_sensitive_found + 1].pos == supplied.coords then
            position_sensitive_blocks[total_sensitive_found + 1] = {name = supplied.info.name, axis = supplied.info.state.axis, half = info.state.half, pos = supplied.coords}
        end
    end
    if supplied.info.state and (supplied.info.state.axis or supplied.info.state.half or supplied.info.state.facing) then
        total_sensitive_found = total_sensitive_found + 1
    end
end

for x=1,#loaded_blueprint do
    for y=1,#loaded_blueprint[x] do
        for z=1,#loaded_blueprint[x][y] do
            local loaded_cell = loaded_blueprint[x][y][z]
            update_sensitive_list_from_table(loaded_cell)
        end
    end
end

local sensitive_test_file = fs.open("sensitive.data", "w")
sensitive_test_file.write(textutils.serialise(position_sensitive_blocks, { compact = true }))
sensitive_test_file.close()
