os.loadAPI("/ComputerCraft_Learning/move.lua")
os.loadAPI("/ComputerCraft_Learning/time.lua")
os.loadAPI("/ComputerCraft_Learning/check_basics.lua")
os.loadAPI("/ComputerCraft_Learning/persistence.lua")
os.loadAPI("/ComputerCraft_Learning/menu.lua")
if peripheral.isPresent("Left") and peripheral.getType("Left") == "modem" then
    rednet.open("Left")
    print("Openned Wifi on the left side")
    wifi=true
end
channel=2
turtle.select(1)
start_items = {[14] = {"minecraft:diamond_pickaxe",1}, [15] = {"minecraft:chest",1}}

db_data = persistence.open_database("recipe")

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

local function getItemsBack()
    -- getting items back
    while turtle.suckUp() do
        -- getting items
    end
    -- find pickaxe
    for x=1, 16 do
        if turtle.getItemCount(x) > 0 and turtle.getItemDetail(x).name == "minecraft:diamond_pickaxe" then
            turtle.select(x)
            turtle.equipLeft()
            turtle.digUp()
            turtle.equipLeft()
            turtle.select(x)
            turtle.transferTo(14)
        end
    end
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
    -- store items on the chest
    turtle.select(15)
    turtle.placeUp()
    turtle.select(14)
    turtle.dropUp()

    turtle.craft()
    -- Getting new item name
    local new_item = {}
    local x = split(turtle.getItemDetail().name, ":")
    local short_name = x[2]
    db[short_name] = copyTable(learn)
    print("We learned "..short_name)
    getItemsBack()
    return db
end

local function has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

-- We want to know how many of each item we will need to perform the craft
-- If we don't have enough material we can request.
-- we could offer the option to get the items from an adjacent chest.
local function prepare_items(item)
    local next = next
    print("We will be crafting "..item)
    -- what we need
    item_details = {}
    for index, value in pairs(db_data[item].components.pos) do
        if type(next(item_details)) == "nil" then
            table.insert(item_details, {value, 1})
        else
            for k, v in pairs(item_details) do
                if v[1] == value then
                    item_details[k][2] = item_details[k][2] + 1
                end
            end
        end
    end
    -- what we need
    check_basics.groupSimilar()

    local allgood = true
    for k,v in pairs(item_details) do
        local found = false
        for y=1, 16 do
            if turtle.getItemCount(y) > 0 and turtle.getItemDetail(y).name == v[1] and turtle.getItemCount(y) >= v[2] then
                print("we have it")
                turtle.select(y)
                turtle.transferTo(16)
                found = true

                -- Prepare Chests
                -- if we have too many items, we can use the chest to move the excedent
                turtle.select(15)
                turtle.placeUp()
                turtle.select(14)
                turtle.dropUp()
                if turtle.getItemCount(16) > v[2] then
                    items_to_move = turtle.getItemCount(16) - v[2]
                    turtle.select(16)
                    turtle.dropUp(items_to_move)
                end
                break
            end
        end
        if not found then
            print("We need at least: "..v[2].." -  "..v[1])
            allgood = false
        end
    end

    if not allgood then
        print("Please provide de missing items to the chest above")
        error()
    else
        print("We are good to go")
    end

    already_set = {}
    for k,v in pairs(db_data[item].components.pos) do
        for y=1, 16 do
            if turtle.getItemCount(y) > 0 and turtle.getItemDetail(y).name == v and not has_value(already_set, y) and k ~= y then
                turtle.select(y)
                turtle.transferTo(k,1)
                table.insert(already_set, k)
            elseif turtle.getItemCount(y) > 0 and turtle.getItemDetail(y).name == v  and k == y then
                table.insert(already_set, k)
                break
            end
        end
    end
    turtle.craft()
    getItemsBack()
end

check_basics.checkBasicSetup(start_items)

opt_selected = menu.CUI({"Learn", "Craft"})

if opt_selected == "Learn" then
    print("Time to learn")
    learnRecipe(db_data)
elseif opt_selected == "Craft" then
    item_list = {}
    for index, value  in pairs(db_data) do
        table.insert(item_list, index)
    end
    prepare_items(menu.CUI(item_list))
end

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
