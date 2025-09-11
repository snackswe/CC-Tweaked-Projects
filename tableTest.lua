local arg1 = ...
model = fs.open(arg1, "r")
bP = textutils.unserialise(model.readAll())
model.close()
local special = {}
foundNum = 1

for x=1,#bP do
    for y=1,#bP[x] do
        for z=1,#bP[x][y] do
            local cell = bP[x][y][z]
            if cell.info.state and cell.info.state.facing then                    
                if not special[foundNum] or special[foundNum].pos ~= cell.coords then
                    table.insert(special, foundNum, {name = cell.info.name, facing = cell.info.state.facing, pos = cell.coords})
                elseif special[foundNum].pos == cell.coords then
                    table.insert(special, foundNum, {facing = cell.info.state.facing})
                end
            end
            if cell.info.state and cell.info.state.half then
                if not special[foundNum] or special[foundNum].pos ~= cell.coords then
                    table.insert(special, foundNum, {name = cell.info.name, half = cell.info.state.half, pos = cell.coords})
                elseif special[foundNum].pos == cell.coords then
                    special[foundNum] = {name = cell.info.name, half = cell.info.state.half, facing = info.state.facing, pos = cell.coords}
                end
            end
            if cell.info.state and cell.info.state.axis then
                if not special[foundNum] or special[foundNum].pos ~= cell.coords then
                    table.insert(special, foundNum, {name = cell.info.name, axis = cell.info.state.axis, pos = cell.coords})
                elseif special[foundNum].pos == cell.coords then
                    special[foundNum] = {name = cell.info.name, axis = cell.info.state.axis, half = info.state.half, pos = cell.coords}
                end
            end
            if cell.info.state and (cell.info.state.axis or cell.info.state.half or cell.info.state.facing) then
                foundNum = foundNum + 1
            end
        end
    end
end

local model = fs.open("temp.data", "w")
model.write(textutils.serialise(special, { compact = true }))
model.close()
--[[
for x=1,#bP do
  for y=1,#bP[x] do
    for z=1,#bP[x][y] do
    end
  end
end
]]--