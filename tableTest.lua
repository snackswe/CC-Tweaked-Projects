local arg1 = ...
local blueprint_file = fs.open(arg1, "r")
local loaded_blueprint = textutils.unserialise(blueprint_file.readAll())
blueprint_file.close()
local orientation_sensitive_blocks_list = {}

local function update_orientations_list_from_table(supplied)
    local dictionary_append_index = #orientation_sensitive_blocks_list + 1
    if not supplied.info.state then return end
    selected_rotation_data = {}
    selected_rotation_data = orientation_sensitive_blocks_list[dictionary_append_index]
    if selected_rotation_data.coords ~= supplied.coords then
        table.insert(selected_rotation_data, dictionary_append_index, {name = supplied.info.name, coords= supplied.coords})
    end
    if supplied.info.state.facing then table.insert(selected_rotation_data, #selected_rotation_data + 1, {facing = supplied.info.state.facing}) end
    if supplied.info.state.half then table.insert(selected_rotation_data, #selected_rotation_data + 1, {half = supplied.info.state.half}) end
    if supplied.info.state.axis then table.insert(selected_rotation_data, #selected_rotation_data + 1, {axis = supplied.info.state.axis}) end
end

for x=1,#loaded_blueprint do
    for y=1,#loaded_blueprint[x] do
        for z=1,#loaded_blueprint[x][y] do
            local loaded_cell = loaded_blueprint[x][y][z]
            update_orientations_list_from_table(loaded_cell)
        end
    end
end

local save = fs.open("orientations.data", "w")
save.write(textutils.serialise(orientation_sensitive_blocks_list, { compact = true }))
save.close()