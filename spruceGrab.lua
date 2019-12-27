os.loadAPI("/ComputerCraft_Learning/move.lua")
if peripheral.isPresent("Left") and peripheral.getType("Left") == "modem" then
    rednet.open("Left")
    print("Openned Wifi on the left side")
    wifi=true
end
listen_computerId=5
direction=0

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
        if turtle.getItemDetail(1).name == "minecraft:log" then
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
            turtle.placeUp()
            bol, value = turtle.inspectUp()
            if value.state.variant == "spruce" then
                print("We have a spruce log in place we are good to go")
                if wifi == true then
                    rednet.send(listen_computerId, "We have a spruce log in place we are good to go", "spruceGrab")
                end
                turtle.digUp()
            else
                print("We NEED a spruce log on slot 1 to continue")
                if wifi == true then
                    rednet.send(listen_computerId, "We NEED a spruce log on slot 1 to continue", "spruceGrab")
                end
                -- Exiting
                error()
            end
        else
            print("We need at least one spruce log on slot 1")
            if wifi == true then
                rednet.send(listen_computerId, "We need at least one spruce log on slot 1", "spruceGrab")
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
        if turtle.getItemDetail(15).name == "minecraft:sapling" then
            move.up(1)
            turtle.select(15)
            turtle.placeDown()
            bol, value = turtle.inspectDown()
            if value.state.type == "spruce" then
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
    move.fd(1)
    turtle.select(15)
    turtle.place()
    turtle.turnRight()
    move.fd(1)
    turtle.turnLeft()
    turtle.select(15)
    turtle.place()
    turtle.turnRight()
    move.bk(1)
    turtle.select(15)
    turtle.place()
    turtle.turnLeft()
    move.bk(1)
    turtle.select(15)
    turtle.place()
end

function checkNext()
    if direction % 2 == 0 then
        turtle.turnLeft()
    else
        turtle.turnRight()
    end
    move.fd(11)
    if direction % 2 == 0 then
        turtle.turnRight()
    else
        turtle.turnLeft()
    end
    direction = direction + 1
end

function checkTreeName()
    if direction % 2 == 0 then
        tree = "first"
    else
        tree = "second"
    end
end

function doRoutine()
    checkLogType()
    checkSaplings()
    while true do
        turtle.select(1)
        if not move.fd(3) then
            bol, value = turtle.inspect()
            if value.name == "minecraft:leaves" then
                for i=1, 3 do
                    turtle.select(13)
                    turtle.dig()
                    move.fd(1)
                end
            end
        end
        while not turtle.compare() do
            checkTreeName()
            if wifi == true then
                rednet.send(listen_computerId, "Checking "..tree.." tree", "spruceGrab")
            end
            move.bk(3)
            checkNext()
            sleep(60)
            move.fd(3)
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
        sleep(60)
    end
end

doRoutine()

