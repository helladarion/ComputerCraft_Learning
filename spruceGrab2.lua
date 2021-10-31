os.loadAPI("/ComputerCraft_Learning/move.lua")
os.loadAPI("/ComputerCraft_Learning/time.lua")
os.loadAPI("/ComputerCraft_Learning/check_basics.lua")
os.loadAPI("/ComputerCraft_Learning/persistence.lua")
if peripheral.isPresent("Left") and peripheral.getType("Left") == "modem" then
    rednet.open("Left")
    print("Openned Wifi on the left side")
    wifi=true
end
listen_computerId=5
--database = "sprucedb.json"
local LIMIT = 14

start_items = {[16] = {"minecraft:charcoal",5}, [15] = {"minecraft:spruce_sapling",4}, [14] = {"minecraft:bone_meal",16}}

function cleanBlackList()
    black_list = {
        "minecraft:stick"
    }

    for i=1, LIMIT do
        for _, item in pairs(black_list) do
            local currentItem = turtle.getItemDetail(i)
            if currentItem ~= nil then
                if currentItem.name == item then
                    turtle.select(i)
                    turtle.drop()
                end
            end
        end
    end
end

function checkSaplings()
    n_saplings = turtle.getItemCount(15)
    if n_saplings < 4 then
        print("We need at least 4 spruce saplings on slot 15 in order to replant")
        if wifi == true then
            rednet.send(listen_computerId, "We need at least 4 spruce saplings on slot 15 in order to replant", "spruceGrab")
        end
        -- Exiting
        error()
    end
end

function moveSuckItems(qtt)
    for i=1, qtt do
        turtle.select(15)
        turtle.suck()
        if not move.fd(1) then
            turtle.select(12)
            turtle.dig()
            move.fd(1)
        end
    end
end

function suckSaplings()
    turtle.turnRight()
    lap=2
    for x=1, 3 do
        for i=1, 4 do
            if i == 1 then
                moveSuckItems(x + (lap - 1))
            else
                moveSuckItems(x + lap)
            end
            if i < 4 then
                turtle.turnLeft()
            else
                moveSuckItems(1)
                turtle.turnLeft()
            end
        end
        lap = lap + 1
    end
    move.fd(3)
    turtle.turnLeft()
    cleanBlackList()
end

function cutit()
    turtle.dig()
    move.fd(1)
    -- Initiating while loop
    local boole, array_t = turtle.inspectUp()
    while boole and array_t.name == "minecraft:spruce_log" do
        turtle.digUp()
        turtle.dig()
        move.up(1)
        boole, array_t = turtle.inspectUp()
    end
    turtle.dig()
    turtle.turnRight()
    turtle.dig()
    move.fd(1)
    if turtle.detectUp() then
        turtle.digUp()
    end
    turtle.turnLeft()
    local boole, array_t = turtle.inspectDown()
    while boole and array_t.name == "minecraft:spruce_log" do
        turtle.digDown()
        turtle.dig()
        move.dn(1)
        boole, array_t = turtle.inspectDown()
    end
    turtle.dig()
    move.bk(1)
    turtle.turnLeft()
    move.fd(1)
    turtle.turnRight()
end

function plant()
    checkSaplings()
    if wifi == true then
        rednet.send(listen_computerId, "Re-planting "..tree.." Tree", "spruceGrab")
    end
    move.up(1)
    move.fd(2)
    turtle.select(15)
    turtle.placeDown()
    turtle.turnRight()
    move.fd(1)
    turtle.turnLeft()
    turtle.select(15)
    turtle.placeDown()
    move.bk(1)
    turtle.select(15)
    turtle.placeDown()
    turtle.turnRight()
    move.bk(1)
    turtle.select(15)
    turtle.placeDown()
    turtle.turnLeft()
    move.bk(1)
    move.dn(1)
end

function growTree()
    print("Growing tree")
    turtle.select(14)
    local boole, array_t = turtle.inspect()
    print("Values are "..array_t.name)
    while array_t.name == "minecraft:spruce_sapling" do
        if turtle.getItemCount(14) > 0 then
            move.bk(1)
            turtle.place()
            sleep(1)
            move.fd(1)
            boole, array_t = turtle.inspect()
        else
            print("We need more bone meal")
            sleep(5)
        end
    end
end

function checkStacks(stacks)
    print("We are checking the stacks")
    check_basics.groupSimilar()
    check_basics.organizeItems(13)
    local total_stacks=0
    local logs=0
    for i=1, 13 do
        if turtle.getItemDetail(i) ~= nil then
            local currentItem = turtle.getItemDetail(i)
            if currentItem.name == "minecraft:spruce_log" then
                if currentItem.count == 64 then
                    total_stacks = total_stacks + 1
                else
                    logs = logs + currentItem.count
                end
            end
        end
    end
    print("We have "..total_stacks.." stacks and "..logs.." logs.")
    if total_stacks >= tonumber(stacks) then
        print("Already have all the stacks we want")
        --exiting
        return true
    else
        return false
    end
end

function depositLogs()
    move.bk(1)
    turtle.turnLeft()
    print("Depositing what we got")
    for x=1, 13 do
        turtle.select(x)
        turtle.drop()
    end
    turtle.turnRight()
    move.fd(1)
end

function doRoutine(stacks)
    print("Starting process")
    prev_slot = turtle.getSelectedSlot()
    while not checkStacks(stacks) do
        move.fd(3)
        local boole, array_t = turtle.inspect()
        if not array_t.name == "minecraft:spruce_log" or array_t.name == nil then
            plant()
            growTree()
        else
            if wifi == true then
                rednet.send(listen_computerId, "Cutting "..tree.." Tree", "spruceGrab")
            end
            cutit()
            if turtle.getItemCount(15) < 30 then
                print("We have less than 30 saplings on our inventory, starting sapling collection")
                if wifi == true then
                    rednet.send(listen_computerId, "We have less than 30 saplings on our inventory, starting sapling collection", "spruceGrab")
                end
                suckSaplings()
            else
                move.bk(3)
            end
        end
    end
    -- Deposit the items
    depositLogs()
end

tArgs = { ... }

check_basics.checkBasicSetup(start_items)
if #tArgs == 1 then
    print("Running limited mode")
    local stacks = tArgs[1]
    print("We are going to collect "..stacks.." stacks")
    doRoutine(stacks)
else
    print("You must specify the number of stacks you want!")
end

--TODO
-- Try to use remote activation
