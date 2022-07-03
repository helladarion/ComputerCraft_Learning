os.loadAPI("/ComputerCraft_Learning/move.lua")
os.loadAPI("/ComputerCraft_Learning/time.lua")
os.loadAPI("/ComputerCraft_Learning/check_basics.lua")
os.loadAPI("/ComputerCraft_Learning/persistence.lua")
if peripheral.isPresent("Left") and peripheral.getType("Left") == "modem" then
    rednet.open("Left")
    print("Openned Wifi on the left side")
    wifi=true
end
channel=2
turtle.select(1)
start_items = {[16] = {"minecraft:coal",5}, [14] = {"minecraft:crafting_table",1}, [13] = {"minecraft:chest",2}}

db_data = persistence.open_database("recipe")
--[[
db_data.planks = {
    requires = false,
    item = "minecraft:planks",
    components = {
        pos = {[1] = "minecraft:spruce_oak"}
    }
}
--]]
local function split(str, delim, maxNb)
    print(str..","..delim)

    -- Eliminate bad cases...
    if string.find(str, delim) == nil then
        return { str }
    end

    if maxNb == nil or maxNb < 1 then
        maxNb = 0 -- No Limit
    end

    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gmatch(str, pat) do
        nb = nb + 1
        result[nb] = part
        lastPos = pos
        if nb == maxNb then break end
    end

    --handle the last field
    if nb ~= maxNb then
        result[nb + 1] =  string.sub(str, lastPos)
    end

    return result
end

local function wait_for_keypress(msg)
    while os.startTimer(5) do
        local event, key_code = os.pullEvent("key")
        if key_code == keys.enter then
            print(msg)
            break
        end
    end
end

local function copyTable(t)
    local aux = textutils.serialize(t)
    local t2  = textutils.unserialize(aux)
    return t2
end

function learnRecipe(db)
    print("Add the pattern to produce a new item and press Enter when ready to craft")
    wait_for_keypress("Learning Recipe")
    local learn = {}
    learn.components = {}
    learn.components.pos = {}
    for i = 1, 11 do
        if turtle.getItemDetail(i) ~= nil then
            table.insert(learn.components.pos, i,turtle.getItemDetail(i).name)
        end
    end
    turtle.craft()
    -- Getting new item name
    local new_item = {}
    local x = split(turtle.getItemDetail(1).name, ":")
    local short_name = x[2]
    db[short_name] = copyTable(learn)
    print("We learned "..short_name)
    return db
end

--db_data = learnRecipe(db_data)
--
local function has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            --print("Yep "..val)
            return true
        end
    end

    --print("nope "..val)
    return false
end

local function prepare_items(item)
    print("We will be crafting "..item)
    already_set = {}
    for k,v in pairs(db_data[item].components.pos) do
        --turtle.select(16)
        for y=1, 16 do
            if turtle.getItemCount(y) > 0 and turtle.getItemDetail(y).name == v and not has_value(already_set, y) and k ~= y then
                turtle.select(y)
                --print("coordenada: y"..y.." k:"..k )
                turtle.transferTo(k,1)
                table.insert(already_set, k)
            elseif turtle.getItemCount(y) > 0 and turtle.getItemDetail(y).name == v  and k == y then
                --print("Skipping "..k.."=="..y)
                table.insert(already_set, k)
                break
            end
        end
    end
end

prepare_items("stick")



--[[
Ideas:
- Craft an item, and teach the system how to make it, by making it once.
  - we can simply start a capture mode, put the items on the turtle, and have
  it craft the item.. the result will be captured as a new recipe.
  - dependencies of other complex items can be crafted, and items required can
  be used like we do with start_items.
  - We can combo it with the storage system or simply a chest to start, and have
  the system checking for the list of materials needed to perform the craft.
--]]

--[[
db_data.chest = {
    name = "minecraft:chest",
    requires = {db_data.planks.components, qtt = 2},
    components = {[2] = {1,2,3,5,7,9,10,11}}
}
--]]
persistence.save_database(db_data,"recipe")
--persistence.remove_db("recipe")
--error()

--print(tprint(db_data.chest.components.pos))
--print(db_data.planks.components.pos[1])
-- Create recipe database
-- Load recipe database
-- show recipe options
