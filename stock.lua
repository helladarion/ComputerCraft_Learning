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
-- 4. if it is an item that has a common name we will have to check its variant - turtle.inspect()
-- 5. Open the database file and add the new item with the quantity, also location
-- 6. Put the item on the correct chest, and if that is the first item of that kind or we have a full chest, create e new one and place it.
-- 7. One option would be to create trap chests to put them side by site, and create a corridor of single chests. Creating a multi-dimension-array or Matrix
-- 7b. Another option would be to create a North, South, East, West approach, with a tower of chests with a hole in the middle, where the turtle could access.
-- Learn how to craft wooden planks
-- Learn how to craft chest
-- create a save load mechanism to store the location, type, amount of each item.
-- It can also stock the charcoal, and provide it to other turtles.

start_items = {[16] = {"minecraft:coal",5}, [15] = {"minecraft:chest",1}, [14] = {"minecraft:log",10}}

function save_file(table,name)
    local file = fs.open(name,"w")
    file.write(textutils.serialize(table))
    file.close()
end

function load_file(name)
    local file = fs.open(name,"r")
    local data = file.readAll()
    file.close()
    return data
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

getItemsBack()
check_basics.checkBasicSetup(start_items)
createStuff(1,chest)
