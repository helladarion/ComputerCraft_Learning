os.loadAPI("/ComputerCraft_Learning/move.lua")
os.loadAPI("/ComputerCraft_Learning/time.lua")
os.loadAPI("/ComputerCraft_Learning/check_basics.lua")
if peripheral.isPresent("Left") and peripheral.getType("Left") == "modem" then
    rednet.open("Left")
    print("Openned Wifi on the left side")
    wifi=true
end
listen_computerId=5
database = "sprucedb.json"
local LIMIT = 14

start_items = {[16] = {"minecraft:charcoal",5}, [15] = {"minecraft:spruce_sapling",8}, [1] = {"minecraft:spruce_log",1}}
--start_items = {[16] = {"minecraft:coal",5}, [15] = {"minecraft:spruce_sapling",8}}

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

function load_database()
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
        db_data.direction = 0
        save_file(db_data,database)
        return db_data
    end
end

function checkLogType()
    n_logs = turtle.getItemCount(1)
    if n_logs < 1 then
        print("We need at least one spruce wood on slot 1")
        if wifi == true then
            rednet.send(listen_computerId, "We need at least one spruce wood on slot 1", "spruceGrab")
        end
        -- Exiting
        error()
    else
        -- Checking first if it a minecraft log
        if turtle.getItemDetail(1).name == "minecraft:spruce_log" then
            print("We do have a log on the slot 1")
            if wifi == true then
                rednet.send(listen_computerId, "We do have a log on the slot 1", "spruceGrab")
            end
            -- Checking what type it is
            print("Checking log type")
            if wifi == true then
                rednet.send(listen_computerId, "Checking log type", "spruceGrab")
            end
            turtle.select(1)
            if turtle.detectUp() then
                turtle.digUp()
            end
            turtle.placeUp()
            bol, value = turtle.inspectUp()
            if value.name == "minecraft:spruce_log" then
                print("We have a spruce log in place we are good to go")
                if wifi == true then
                    rednet.send(listen_computerId, "We have a spruce log in place we are good to go", "spruceGrab")
                end
                turtle.digUp()
            else
                print("This program is intended to work with spruce trees")
                if wifi == true then
                    rednet.send(listen_computerId, "This program is intended to work with spruce trees", "spruceGrab")
                end
                -- Exiting
                error()
            end
        else
            print("This program is intended to work with spruce trees")
            if wifi == true then
                rednet.send(listen_computerId, "This program is intended to work with spruce trees", "spruceGrab")
            end
            -- Exiting
            error()
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
    else
        -- Check if they are the right type of sapplings
        prev_slot = turtle.getSelectedSlot()
        if turtle.getItemDetail(15).name == "minecraft:spruce_sapling" then
            move.up(1)
            turtle.select(15)
            turtle.placeDown()
            bol, value = turtle.inspectDown()
            if value.name == "minecraft:spruce_sapling" then
                print("All good we have the right type of sapling")
                if wifi == true then
                    rednet.send(listen_computerId, "All good we have the right type of sapling", "spruceGrab")
                end
                -- getting the sappling back
                turtle.digDown()
                -- switching back to the previous slot
                turtle.select(prev_slot)
                move.dn(1)
           else
                print("That is not the right type of sapling")
                if wifi == true then
                    rednet.send(listen_computerId, "That is not the right type of sapling", "spruceGrab")
                end
                -- getting the sappling back
                turtle.digDown()
                -- switching back to the previous slot
                turtle.select(prev_slot)
                move.dn(1)
                -- Exiting
                error()
            end
        else
            print("Those are not saplings, we need spruce saplings on slot 15")
            if wifi == true then
                rednet.send(listen_computerId, "Those are not saplings, we need spruce saplings on slot 15", "spruceGrab")
            end
            -- Exiting
            error()
        end
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
    turtle.select(1)
    turtle.dig()
    move.fd(1)
    while turtle.compareUp() do
        turtle.digUp()
        turtle.dig()
        move.up(1)
    end
    turtle.dig()
    turtle.turnRight()
    turtle.dig()
    move.fd(1)
    if turtle.detectUp() then
        turtle.digUp()
    end
    turtle.turnLeft()
    while turtle.compareDown() do
        turtle.digDown()
        turtle.dig()
        move.dn(1)
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

function checkNext()
    db_data = load_database()
    if db_data.direction % 2 == 0 then
        turtle.turnLeft()
    else
        turtle.turnRight()
    end
    move.fd(11,true)
    if db_data.direction % 2 == 0 then
        turtle.turnRight()
    else
        turtle.turnLeft()
    end
    db_data.direction = db_data.direction + 1
    save_file(db_data,database)
end

function checkTreeName()
    db_data = load_database()
    if db_data.direction % 2 == 0 then
        tree = "first"
    else
        tree = "second"
    end
end

function doRoutine(qtt)
    local running = true
    checkLogType()
    checkSaplings()
    while running do
        -- Not running the first one for free.
        if qtt ~= nil and tonumber(qtt) > 0 then
            qtt = tonumber(qtt) - 1
            if tonumber(qtt) == 0 then
                running = false
            end
        else
            print("That is it, not running.")
            running = false
        end
        while turtle.getItemCount(16) < 2 do
            print("Not doing this run, we need more coal on stot 16")
            sleep(30)
        end
        -- Removing any leaves from the top of the turtle
        if turtle.detectUp() then
            turtle.select(12)
            turtle.digUp()
            turtle.dropUp()
        end
        turtle.select(1)
        if not move.fd(3) then
            bolee, value_l = turtle.inspect()
            if value_l.name == "minecraft:spruce_leaves" then
                for i=1, 3 do
                    turtle.select(13)
                    turtle.dig()
                    move.fd(1)
                end
                turtle.digUp()
                turtle.dropUp()
                turtle.select(1)
            end
        elseif turtle.detectUp() then
            turtle.select(12)
            turtle.digUp()
            turtle.dropUp()
            turtle.select(1)
        end
        turtle.select(1)
        while not turtle.compare() do
            checkTreeName()
            if wifi == true then
                rednet.send(listen_computerId, "Checking "..tree.." tree", "spruceGrab")
            end
            if not turtle.inspect() then
                plant()
            end
            move.bk(3)
            checkNext()
            time.wait(1)
            move.fd(3)
            turtle.select(1)
        end
        checkTreeName()
        if wifi == true then
            rednet.send(listen_computerId, "Cutting "..tree.." Tree", "spruceGrab")
        end
        cutit()
        plant()
        if turtle.getItemCount(15) < 30 then
            print("We have less than 30 saplings on our inventory, starting sapling collection")
            if wifi == true then
                rednet.send(listen_computerId, "We have less than 30 saplings on our inventory, starting sapling collection", "spruceGrab")
            end
            suckSaplings()
        else
            move.bk(3)
        end
        time.wait(3)
        total_stacks=0
        for i=1, 14 do
            if turtle.getItemCount(i) ~= nil and turtle.getItemCount(i) == 64 then
                total_stacks = total_stacks + 1
            end
        end
        if total_stacks >= 8 then
            print("Already have all the stacks we want")
            --exiting
            error()
        end
    end
end

tArgs = { ... }

check_basics.checkBasicSetup(start_items)
if #tArgs == 1 then
    print("Running limited mode")
    local qtt = tArgs[1]
    --local itemQtt = tArgs[2]
    --print("You just requested "..itemQtt.." of "..itemID)
    print("We are going to collect wood "..qtt.." times")
    doRoutine(qtt)
else
    print("You must specify the number of times your want to run!")
end


--TODO
-- Deploy logs to the storage system
-- Only activate if the storage is low on wood. - Stop when we get 8 stacks of 64
