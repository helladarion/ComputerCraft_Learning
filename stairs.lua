os.loadAPI("/ComputerCraft_Learning/move.lua")
os.loadAPI("/ComputerCraft_Learning/check_basics.lua")
if peripheral.isPresent("Left") and peripheral.getType("Left") == "modem" then
    rednet.open("Left")
    print("Openned Wifi on the left side")
    wifi=true
end
listen_computerId=5
start_items = {[16] = {"minecraft:coal",5}, [15] = {"minecraft:torch",20}, [14] = {"minecraft:crafting_table",1}, [13] = {"minecraft:chest",2}}
-- Torches on 15
-- crafting table on 14
-- 2 chests on 13

depth = { ... }
if #depth < 1  or #depth > 64 then
    print("Usage: stairs <depth>")
    print("We can only make <depth> until 64")
    return
end

if wifi == true then
    rednet.send(listen_computerId,"Doing stairs for "..depth[1].." depth")
end

function cutSides()
    if #depth > 1 then
        turtle.turnLeft()
        turtle.dig()
        turtle.turnRight()
        turtle.turnRight()
        turtle.dig()
        turtle.turnLeft()
    end
end

function torchit()
    turtle.select(15)
    turtle.placeUp()
    turtle.select(1)
end

function goDownStairs()
    turtle.select(1)
    for i = 1, depth[1] do
        turtle.digDown()
        move.dn(1)
        --cutSides()
        turtle.dig()
        move.fd(1)
        --cutSides()
        for x =1, 2 do
            turtle.digUp()
            move.up(1)
            --cutSides()
        end
        move.dn(1)
        if i % 5 == 0 then
            if wifi == true then
                rednet.send(listen_computerId,"Torching it at "..i.." depth","stairs")
            end
            torchit()
        end
        move.dn(1)
    end
end
-- Chest Section

function prepareInventory()
    -- we need to store the items
    -- we could create a chest, but I'm not really sure about that yet - NOPE we need a clean inventory to craft anything
    -- we could also move the items to the side, and remove the trash, dirt, and not coblestone and ores - NOPE that doesn't work
    local black_list = {"minecraft:stone", "minecraft:dirt", "minecraft:gravel"}
    -- We need to place the chest on top and fill it with the items, but we can also remove the trash.
    if turtle.getItemDetail(14) == "minecraft:diamond_pickaxe" then
        -- swap the crafting table with the picaxe
        turtle.equipRight()
    end
    turtle.turnLeft()
    sleep(2)
    turtle.dig()
    turtle.select(13)
    turtle.place(1)
    turtle.placeUp(1)
    turtle.select(14)
    turtle.equipRight()
    for i=1, 16 do
        for _,v in ipairs(black_list) do
            --print(i.." and "..v)
            if turtle.getItemCount(i) > 0 and turtle.getItemDetail(i).name == v then
                turtle.select(i)
                turtle.dropDown()
            elseif turtle.getItemCount(i) > 0 and turtle.getItemDetail(i).name == "minecraft:cobblestone" then
                -- store cobblestone on the left chest
                turtle.select(i)
                turtle.drop()
            end
        end
        -- store all other items
        turtle.select(i)
        turtle.dropUp()
    end
    --turtle.turnRight()
end

chest = {1,2,3,5,7,9,10,11}
stairs = {1,5,6,9,10,11}
-- Make the necessary number of stairs, checking the resources necessary
function createStuff(qtt, what)
   -- checking if we have a crafting table on slot 14
   --if turtle.getItemDetail(14) == "minecraft:crafting_table" then
   --    -- swap the crafting table with the picaxe
   --    turtle.equipRight()
   --else
   --    print("We need a crafting table on slot 14 in order to craft stairs")
   --     if wifi == true then
   --         rednet.send(listen_computerId, "We need a crafting table on slot 14 in order to craft stairs", "stairs")
   --     end
   --    error()
   --end
   if qtt <= 4 then
       total_stairs = 1
   else
       total_stairs = math.ceil(qtt/4)
   end
   -- chest
   howManyTimes = 1
   leftover = total_stairs
   while leftover > 10 do
       leftover = total_stairs - 10
       howManyTimes = howManyTimes + 1
   end

   for i=1, howManyTimes do
      if howManyTimes > 1 and howManyTimes ~= i then
         currentValue = 10
         turtle.select(12)
         turtle.suck(60)
      else
         currentValue = leftover
         turtle.select(12)
         turtle.suck(leftover*6)
      end

      for _,v in ipairs(what) do
          turtle.select(12)
          turtle.transferTo(v,currentValue)
      end
   end
   turtle.craft(total_stairs)
end

function getItemsBack()
    while turtle.suckUp() do
        --nothing here, only sucking up the items back
    end
    while turtle.suck() do
        -- nothing here, only sucking up the items back
    end
    -- find an empty spot
    for i=1, 16 do
        if turtle.getItemCount(i) > 0 and  turtle.getItemDetail(i).name == "minecraft:diamond_pickaxe" then
            turtle.select(i)
            turtle.equipRight()
            break
        end
    end
    --getting the chests back
    turtle.dig()
    turtle.digUp()
    for i=1, 16 do
        if turtle.getItemCount(i) == 0 then
            swap_spot = i
            break
        end
    end
    if not swap_spot then
        print("We have no empty spots, getting rid of some cobblestone")
        for x=1, 16 do
            if turtle.getItemDetail(x).name == "minecraft:cobblestone" then
                turtle.select(x)
                turtle.dropDown()
                swap_spot = x
                break
            end
        end
    end
    starting_items = {[16] = "minecraft:coal", [15] = "minecraft:torch", [14] = "minecraft:crafting_table", [13] = "minecraft:chest", [12] = "minecraft:stone_stairs"}
    for y=1, 16 do
        for k,v in pairs(starting_items) do
            --print(k..": "..v)
            if turtle.getItemCount(y) > 0 and turtle.getItemDetail(y).name == v  and k ~= y then
                turtle.select(k)
                turtle.transferTo(swap_spot)
                turtle.select(y)
                turtle.transferTo(k)
                swap_spot = y
                break
            end
        end
    end
    turtle.turnRight()
end

function placeStairs(qtt)
    turtle.turnRight()
    turtle.turnRight()
    move.fd(1)
    for i=1, qtt do
        turtle.dig()
        turtle.select(12)
        turtle.place()
        move.up(1)
        move.fd(1)
        --checkQtt()
    end
    move.fd(3)
    turtle.turnRight()
    turtle.turnRight()
end

--function checkQtt()
--    if turtle.getItemCount(12) < 2 then
--        turtle.select(14)
--        turtle.transferTo(13)
--        turtle.select(13)
--    end
--end
check_basics.checkBasicSetup(start_items)
goDownStairs()
prepareInventory()
createStuff(tonumber(depth[1]), stairs)
getItemsBack()
placeStairs(tonumber(depth[1]))
