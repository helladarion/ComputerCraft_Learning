os.loadAPI("/ComputerCraft_Learning/move.lua")
os.loadAPI("/ComputerCraft_Learning/time.lua")
os.loadAPI("/ComputerCraft_Learning/check_basics.lua")
side="Right"
if peripheral.isPresent(side) and peripheral.getType(side) == "modem" then
    rednet.open(side)
    print("Openned Wifi on the "..side.." side")
    wifi=true
end
channel=2
turtle.select(1)
start_items = {[16] = {"minecraft:coal",5}, [1] = {"minecraft:wheat_seeds",10}}
gap_between_layers=3
wait_between_checks=2

--[[
* We want to accomplish several layers of farming
* Also want it to auto setup the layers
* We need to be aware about our fuel levels
* Thi system is intended to run forever, and provide bone-meal with the extra
seeds and wheat it doesn't actually need a modem.
--]]

function createWater()
    turtle.turnRight()
    move.fd(1)
    turtle.select(1)
    turtle.place()
    for i=1, 3 do
        turtle.turnRight()
        turtle.place()
        move.rd(1)
        turtle.place()
        turtle.turnRight()
        if i ~= 3 then
            move.bk(1)
        end
    end
    move.rd(1)
    turtle.place()
    move.bk(1)
    turtle.select(14)
    turtle.place()
    move.rd(1)
    turtle.select(15)
    turtle.place()
    turtle.turnLeft()
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
    for i=1, 16 do
        itemDetail = turtle.getItemDetail(i)
        if itemDetail ~= nil and itemDetail.name == "minecraft:dirt" then
            dirtTotal = dirtTotal + itemDetail.count
        end
    end
    if dirtTotal < needed then
        local stillNeed = needed - dirtTotal
        print("We still need "..stillNeed.." dirt")
        error()
    end
end

-- Prepare terrain
function prepareLayer(howManyLayers)
    -- We also need to know how many dirt we will need for the job before start
    layerDirt=81
    checkDirtAmount(layerDirt*howManyLayers+8)
    start_items = {[16] = {"minecraft:charcoal",5}, [1] = {"minecraft:dirt",64}, [15] = {"minecraft:water_bucket",1}, [14] = {"minecraft:water_bucket",1}}
    check_basics.checkBasicSetup(start_items)
    createWater()
    -- fill buckets
    turtle.select(14)
    turtle.placeDown()
    turtle.select(15)
    turtle.placeDown()

    -- Setup an infinite water source, and fill the buckets
    -- We want to know how many layers we will be creating
    -- Each layer will need:
    -- * 9x9=81 or a stack + 17 dirt with 1 water source in the middle
    for i=1, howManyLayers do
        -- prepare all the layers
        print("Starting to prepare layer: "..i)
        -- we want to have those platforms suspended
        move.up(gap_between_layers)
        for pass=1, 2 do
            for x=1, 9 do
                for y=1, 9 do
                    -- deal with missing dirt
                    if turtle.getItemCount(1) < 2 then
                        check_basics.groupSimilar()
                        check_basics.organizeItems()
                    end
                    turtle.select(1)
                    move.fd(1)
                    if x == 5 and y == 5 and pass == 1 then
                        -- place dirt one layer down and place water
                        move.dn(1)
                        turtle.placeDown()
                        move.up(1)
                        if turtle.getItemDetail(14).name == "minecraft:water_bucket" then
                            bucket=14
                        else
                            bucket=15
                        end
                        turtle.select(bucket)
                        turtle.placeDown()
                        turtle.select(1)
                    else
                        if pass == 1 then
                            turtle.placeDown()
                        else
                            turtle.digDown()
                        end
                    end
                end
                if x % 2 == 0 then
                    turn_dir={d = turtle.turnLeft}
                else
                    turn_dir={d = turtle.turnRight}
                end
                if x ~= 9 and y ~= 9 then
                    move.fd(1)
                    turn_dir.d()
                    move.fd(1)
                    turn_dir.d()
                end
            end
            move.fd(1)
            if pass == 1 then
                move.up(1)
            else
                -- refil bucket 14
                print("Refilling water bucket")
                turtle.select(14)
                move.dn(i*(gap_between_layers+1))
                turtle.placeDown()
                move.up(i*(gap_between_layers+1))
                turtle.select(1)
            end
            move.rd(1)
        end
        if i < tonumber(howManyLayers) then
            print("We are done with layer: "..i)
            time.wait(1)
        else
            print("Job done boss")
            move.dn(i*(gap_between_layers+1))
        end
    end
end

function plantHarvestCrops()
    for x=1,9 do
        for i=1,9 do
            move.fd(1)
            checkCrops()
        end
        if x % 2 == 0 then
            turn_dir={d = turtle.turnLeft}
        else
            turn_dir={d = turtle.turnRight}
        end
        if x ~= 9 and i ~= 9 then
            move.fd(1)
            turn_dir.d()
            move.fd(1)
            turn_dir.d()
        end
    end
end
--[[
function deposit(item)
    turtle.select(item)
    qtt = turtle.getItemCount(item)
    turtle.turnLeft()
    if qtt > 0 then
        turtle.dropDown(qtt - 1)
    end
    turtle.turnRight()
end
--]]
function checkPos(deposit)
    deposit = deposit or false
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
                        if deposit then
                            turtle.select(seed_pos)
                            turtle.turnRight()
                            turtle.drop()
                            turtle.turnLeft()
                        end
                    else
                        wheat_pos=i
                        if deposit then
                            turtle.select(wheat_pos)
                            turtle.turnLeft()
                            turtle.drop()
                            turtle.turnRight()
                        end
                    end
                end
            end
        end
    end
    -- Getting seeds to replant the first crops
    if deposit then
    	turtle.turnRight()
    	turtle.suck(10)
    	turtle.turnLeft()
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
    move.up(1*(gap_between_layers+1))
    plantHarvestCrops()
    move.fd(1)
    move.rd(1)
end

params = { ... }
if #params < 1 then
    print("Usage: farmer <layers> <p> for prepare")
    return
end
totalLayers = params[1]
if params[2] == "p" then
    prepareLayer(totalLayers)
else
    check_basics.checkBasicSetup(start_items)
    count = 1
    while true do
        for i=1, totalLayers do
            doRoutine()
            check_basics.groupSimilar()
            check_basics.organizeItems()
            checkPos()
        end
        move.dn(totalLayers*(gap_between_layers+1))
        print("We need to deposit the items.")
        checkPos(true)
        while turtle.getItemCount(16) < 5 do
            print("Man I can't do another run. please refil slot 16")
            sleep(30)
	    print("Auto Recharging")
	    turtle.turnRight()
	    turtle.turnRight()
	    turtle.suck(10)
	    turtle.turnLeft()
	    turtle.turnLeft()
        end
        count = count + 1
        time.wait(wait_between_checks)
    end
end
