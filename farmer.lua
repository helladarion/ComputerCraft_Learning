os.loadAPI("/ComputerCraft_Learning/move.lua")
os.loadAPI("/ComputerCraft_Learning/time.lua")
os.loadAPI("/ComputerCraft_Learning/check_basics.lua")
if peripheral.isPresent("Left") and peripheral.getType("Left") == "modem" then
    rednet.open("Left")
    print("Openned Wifi on the left side")
    wifi=true
end
channel=2
turtle.select(1)
start_items = {[16] = {"minecraft:coal",5}, [1] = {"minecraft:wheat_seeds",10}}

--[[
* We want to accomplish several layers of farming
* Also want it to auto setup the layers
* We need to be aware about our fuel levels
* Thi system is intended to run forever, and provide bone-meal with the extra
seeds and wheat it doesn't actually need a modem.
--]]

function createWater()
    move.dn(1,true)
    turtle.turnRight()
    turtle.dig()
    turtle.select(14)
    turtle.place()
    move.rd()
    turtle.dig()
    turtle.select(15)
    turtle.place()
    move.up(1)
end

function checkDirtAmount(needed)
    check_basics.groupSimilar()
    black_list = {
        "minecraft:cobblestone",
        "minecraft:gravel",
        "minecraft:granite",
        "minecraft:diorite",
        "minecraft:flint",
        "minecraft:andesite"
    }
    check_basics.cleanBlackList(black_list)
    check_basics.organizeItems()
    dirtTotal=0
    while dirtTotal < needed  do
        for i=1, 16 do
            itemDetail = turtle.getItemDetail(i)
            if itemDetail ~= nil and itemDetail.name == "minecraft:dirt" then
                dirtTotal = dirtTotal + itemDetail.count
            end
        end
        local stillNeed = needed - dirtTotal
        print("We still need "..stillNeed.." dirt")
        sleep(10)
    end
end

-- Prepare terrain
function prepareLayer(howMany)
    -- We also need to know how many dirt we will need for the job before start
    layerDirt=81

    start_items = {[16] = {"minecraft:charcoal",5}, [1] = {"minecraft:dirt",10}, [15] = {"minecraft:water_bucket",1}, [14] = {"minecraft:water_bucket",1}}
    -- Setup an infinite water source, and fill the buckets
    -- We want to know how many layers we will be creating
    -- Each layer will need:
    -- * 9x9=81 or a stack + 17 dirt with 1 water source in the middle
    for i=1, howMany do
        for x=1, 9 do
            for y=1, 8 do
                -- place the dirt
            end
            if x % 2 == 0 then
                turn_dir={d = turtle.turnLeft}
            else
                turn_dir={d = turtle.turnRight}
            end
            if x ~= 9 and y ~= 8 then
                turn_dir.d()
                move.fd(1)
                turn_dir.d()
            end
        end
    end
end

function plantHarvestCrops()
    for x=1,9 do
        for i=1,8 do
            move.fd(1)
            checkCrops()
        end
        if x % 2 == 0 then
            turn_dir={d = turtle.turnLeft}
        else
            turn_dir={d = turtle.turnRight}
        end
        if x ~= 9 and i ~= 8 then
            turn_dir.d()
            move.fd(1)
            turn_dir.d()
            checkCrops()
        end
    end
end

function checkPos()
    crop_list = { "minecraft:wheat_seeds",
                  "minecraft:wheat"
                }
    seed_pos=1
    wheat_pos=2
    LIMIT=15
    -- Auto detecting where the seed is
    for i=1, LIMIT do
        for _, item in pairs(crop_list) do
            local currentItem = turtle.getItemDetail(i)
            if currentItem ~= nil then
                if currentItem.name == item then
                    if item == "minecraft:wheat_seeds" then
                        seed_pos=i
                    else
                        wheat_pos=i
                    end
                end
            end
        end
    end
end

function checkCrops()
    checkPos()
    if turtle.detectDown() == false then
        turtle.select(seed_pos)
        turtle.placeDown()
    else
        _, data = turtle.inspectDown()
        if data.state.age == 7 then
            turtle.digDown()
            turtle.select(seed_pos)
            turtle.placeDown()
        end
    end
end

function doRoutine()
    move.fd(1)
    plantHarvestCrops()
    move.fd(1)
    move.rd(1)
end

function deposit(item)
    turtle.select(item)
    qtt = turtle.getItemCount(item)
    turtle.turnLeft()
    if qtt > 0 then
        turtle.dropDown(qtt - 1)
    end
    turtle.turnRight()
end


params = { ... }
if #params < 1 then
    print("Usage: farmer <layers> <p> for prepare")
    return
end
totalLayers = params[1]
if params[2] == "p" then
    checkDirtAmount(81*5)
    check_basics.checkBasicSetup(start_items)
else
    check_basics.checkBasicSetup(start_items)
    count = 1
    while true do
        doRoutine()
        check_basics.groupSimilar()
        checkPos()
        if count % 2 == 0 then
            deposit(wheat_pos)
        else
            deposit(seed_pos)
        end
        count = count + 1
        time.wait(5)
    end
end
