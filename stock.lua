os.loadAPI("/ComputerCraft_Learning/move.lua")
os.loadAPI("/ComputerCraft_Learning/check_basics.lua")
if peripheral.isPresent("Left") and peripheral.getType("Left") == "modem" then
    rednet.open("Left")
    print("Openned Wifi on the left side")
    wifi=true
end
listen_computerId=5

-- To start the project we need to define how we want this to work.
-- 1. It should have a single entry chest
-- 2. the turtle will check this specific chest every X number os seconds
-- 3. if a item inside the chest, we will verify what is the name of the item. - turtle.getItemDetail()
-- 4. if it is an item that has a common name we will have to check its variant - turtle.inspect() - Common item names
-- 5. Open the database file and add the new item with the quantity, also location
-- 6. Put the item on the correct chest, and if that is the first item of that kind or we have a full chest, create e new one and place it.
-- 7. One option would be to create trap chests to put them side by site, and create a corridor of single chests. Creating a multi-dimension-array or Matrix
-- 7b. Another option would be to create a North, South, East, West approach, with a tower of chests with a hole in the middle, where the turtle could access.
-- database = {
--  facing = {
--      starter = 2
--      current = 1
--      }
--  item_name = "minecraft.itemname",
--  qtt = qtt of the item
--  space_left = space_left of the chest 27 * 64 slots minus qtt
--  shelf_position = {N,N,N,W,W,W}
--  chest_position = {pos=north, hight=1}
-- }
-- Learn how to craft wooden planks - DONE
-- Learn how to craft chest - DONE
-- create a save load mechanism to store the location, type, amount of each item.
-- It can also stock the charcoal, and provide it to other turtles.

start_items = {[16] = {"minecraft:coal",5}, [15] = {"minecraft:chest",1}, [14] = {"minecraft:log",10}}
database = "items_db.json"
number_of_silos = 4

function save_exists(name)
    local f=io.open(name,"r")
    if f~=nil then io.close(f) return true else return false end
end

function save_file(table,name)
    local file = fs.open(name,"w")
    file.write(textutils.serialize(table))
    file.close()
end

function load_file(name)
    local file = fs.open(name,"r")
    local data = file.readAll()
    file.close()
    return textutils.unserialize(data)
end

function swapFacing(face)
    if face == "north" then
        return 3 --south
    elseif face == "south" then
        return 1 --north
    elseif face == "west" then
        return 2 --east
    elseif face == "east" then
        return 4 --west
    end
end



function updateFacing(rotate_dir)
    --auxiliar function for rotate the turtle, and get the new facing
    --print(db_data.facing.current)
    current_dir = tonumber(db_data.facing.current)

    if rotate_dir == "r" then
        current_dir = current_dir + 1
        turtle.turnRight()
    else
        current_dir = current_dir - 1
        turtle.turnLeft()
    end
    if current_dir > 4 then
        current_dir = 1
    elseif current_dir < 1 then
        current_dir = 4
    end
    db_data.facing.current = current_dir
    save_file(db_data,database)
    print(db_data.facing.current)
end


planks = {
    name = "minecraft:planks",
    components = {[1] = {1}}
}
chest = {
    name = "minecraft:chest",
    requires = {planks.components, qtt = 2},
    components = {[2] = {1,2,3,5,7,9,10,11}}
}

function prepareToCraft(number_needed)
    -- Place chest on top
    turtle.select(15)
    turtle.placeUp()
    -- place unused items on the chest
    turtle.select(1)
    if turtle.getItemCount() > 0 then
        turtle.dropUp()
    end
    turtle.select(16)
    turtle.dropUp()
    -- keep necessary number of items on slot 14
    turtle.select(14)
    turtle.dropUp(turtle.getItemCount() - number_needed)
end

function getItemsBack()
    while turtle.suckUp() do
        -- getting items back
    end
    turtle.digUp()
    check_basics.checkBasicSetup(start_items)
end

function putItemOnSlot(slot)
   for i=1, 16 do
       if turtle.getItemCount(i) > 0 then
           turtle.select(i)
           turtle.transferTo(slot)
           turtle.select(1)
           break
       end
   end
end

function createStuff(qtt, what)
   prepared = false
   if what.requires then
       dothis = what.requires[1]
       req_qtt = what.requires.qtt
   else
       req_qtt = qtt
   end
   for n,v in pairs(dothis) do
       if not prepared then
           total_needed = (n * req_qtt) * qtt
           prepareToCraft(total_needed)
           prepared = true
       end
       for _,pos in pairs(v) do
           turtle.select(14) --slot where we want the planks to be at
           turtle.transferTo(pos,total_needed)
       end
   end
   turtle.craft(total_needed)
   -- put results on slot 13
   putItemOnSlot(13)
   if what.requires then
       for n,v in pairs(what.components) do
           for _,pos in pairs(v) do
               turtle.select(13)
               turtle.transferTo(pos,qtt)
           end
       end
       turtle.craft(qtt)
   end
   putItemOnSlot(13)
   getItemsBack()
end

function add_item()
    turtle.select(1)
    -- for the item get only the name after minecraft:
    local x = turtle.getItemDetail().name
    local item = string.gsub(x, "minecraft:", "")
    if db_data.items == nil then
        db_data.items = {}
    end
    if db_data.items[item] == nil then
        db_data.items[item]= {}
        db_data.items[item].name = turtle.getItemDetail().name
    end
    --check if we have a storage location for this item
    if db_data.items[item].qtt == nil then
        print("it is nil")
        current_items = 0
    else
        print("we do have a value there")
        current_items = db_data.items[item].qtt
    end
    print(current_items)
    db_data.items[item].qtt = tonumber(current_items) + tonumber(turtle.getItemDetail().count)
    if db_data.items[item].location == nil then
        print("We don't have a storage location for this one")
        silo,layer,chestk = checkFreeChest()
        db_data.items[item].location = {silo, layer, chestk}
        --print(db_data.storage[silo].layer[layer])
        db_data.storage[silo].layer[layer][chestk].current_used = turtle.getItemDetail().count
        new_chest = true
    else
        -- if the item already exists we want to store it on the same chest
        silo,layer,chestk = unpack(db_data.items[item].location)
        print(silo, layer, chestk)
        --print(db_data.storage[silo].layer[layer])
        local current_items = db_data.storage[silo].layer[layer][chestk].current_used
        db_data.storage[silo].layer[layer][chestk].current_used = tonumber(current_items) + tonumber(turtle.getItemDetail().count)
        new_chest = false
    end
    print("saving item "..item.." into "..silo.." layer "..layer.." chest "..chestk)
    -- go to storage
    print("Adding "..turtle.getItemDetail().count.." "..item.." to the database")
    walkPath(db_data.storage[silo].path)
    storeItem(new_chest, silo, layer, chestk)
    walkPath(reversePathToSilo(silo))
    save_file(db_data,database)
end

function storeItem(new_c, s, l, c)
    local layer = string.gsub(l, "l", "")
    local chest_number = string.gsub(c, "chest", "")
    move.up(layer)
    local saved_facing = db_data.facing.current
    while tonumber(db_data.facing.current) ~= tonumber(chest_number) do
        updateFacing("r")
    end
    if new_c or not turtle.detect() then
        -- if chest is new craft a new chest
        createStuff(1,chest)
        db_data.storage[s].layer[l][c].used = true
    end
    turtle.select(15)
    turtle.place()
    turtle.select(1)
    turtle.drop()
    while tonumber(db_data.facing.current) ~= tonumber(saved_facing) do
        updateFacing("r")
    end
    move.dn(layer)
end

function checkFreeChest()
    local count_layers = 0
    for silo, vsilo in pairs(db_data.storage) do
        --print("Checking Silo: "..silo) -- List of all Silos
        for layer,vlayer  in pairs(vsilo.layer) do
            --print(layer,vlayer)
            for chestk, vchest in pairs(vlayer) do
                --print(chestk, vchest)
                if not vchest.used then
                    return silo, layer, chestk
                end
            end
        end
    end
end

function walkPath(path)
    -- save all necessary steps to get to a specific location u, d, b, f, r, l
    --convert path to silo into actions
    print(pathToSilo)
    for step in string.gmatch(path, "([^%s])") do
       if step == "b" then
           move.bk(1)
       elseif step == "f" then
           move.fd(1)
       elseif step == "u" then
           move.up(1)
       elseif step == "d" then
           move.dn(1)
       elseif step == "r" then
           updateFacing("r")
       elseif step == "l" then
           updateFacing("l")
       end
    end
    -- save_file(db_data,database)
end

function reversePathToSilo(silo)
    local reversePath = string.reverse(db_data.storage[silo].path)
    --print(db_data.storage[silo].path) -- Original Path
    reversePath = string.gsub(reversePath, "r", "y")
    reversePath = string.gsub(reversePath, "l", "r")
    reversePath = string.gsub(reversePath, "y", "l")
    reversePath = string.gsub(reversePath, "b", "x")
    reversePath = string.gsub(reversePath, "f", "b")
    reversePath = string.gsub(reversePath, "x", "f")
    reversePath = string.gsub(reversePath, "u", "d")
    --print(reversePath)
    return reversePath
end

function checkChest()
    turtle.select(1)
    turtle.suck()
    if turtle.getItemCount() == 0 then
        --print("No new items")
        error()
    end
    add_item()
end

function createBaseSilos(db_data,qtt)
    if qtt > 10 then
        qtt = 10
        print("Max value 10, setting to max")
    end
    db_data.storage = {}
    for i=1,qtt do
        if i % 2 == 0 then -- if i is even
            direction = "l"
        else
            direction = "r"
        end
        if i < 3 then
            mainDist = "bbb"
        elseif i >= 3 and i < 5 then
            mainDist = "bbbbbb"
        elseif i >= 5 and i < 7 then
            mainDist = "bbbbbbbbb"
        elseif i >= 7 and i < 9 then
            mainDist = "bbbbbbbbbbbb"
        elseif i >= 9 then
            mainDist = "bbbbbbbbbbbbbbb"
        end
        db_data.storage["silo"..i] = {path = mainDist..""..direction.."fff", layer = {}}
        for lay=1,4 do
            db_data.storage["silo"..i].layer["l"..lay] = {}
            for cap=1,4 do
                db_data.storage["silo"..i].layer["l"..lay]["chest"..cap] = { used = false, total_capacity = 27 * 64, current_used = 0 }
            end
        end
    end
    --save_file(db_data,database)
end

function getStarterFacingDirection()
    --We need to check if we have this information saved, and if not just save it.
    if save_exists(database) then
       local db_data = load_file(database)
       print("database Exists")
       if db_data == nil then
           print("database empty or invalid, deleting it")
           fs.delete(database)
           error()
       end
       -- print(db_data.facing.starter)
       return db_data
    else
       local db_data = {}
       print("Creating New DB")
       --place a chest, inspect, swapFacing and save the facing info
       turtle.select(15)
       turtle.place()
       bol, value = turtle.inspect()
       turtle.dig()
       starter_dir = value.state.facing
       db_data.facing = {}
       db_data.facing.starter = swapFacing(starter_dir)
       db_data.facing.current = swapFacing(starter_dir)
       --create the base chest
       createStuff(1,chest)
       turtle.select(15)
       turtle.place()
       createBaseSilos(db_data,number_of_silos)
       save_file(db_data,database)
       return db_data
    end
end

check_basics.checkBasicSetup(start_items)
db_data = getStarterFacingDirection()
while true do
    checkChest()
    sleep(3)
end


--siloToGo = "silo4"
--
--walkPath(db_data.storage[siloToGo].path)
---- do the storage of the item here
--sleep(10)
--walkPath(reversePathToSilo(siloToGo))

