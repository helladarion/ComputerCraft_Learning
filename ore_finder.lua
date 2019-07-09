os.loadAPI("/ComputerCraft_Learning/move.lua")
if peripheral.isPresent("Left") and peripheral.getType("Left") == "modem" then
    rednet.open("Left")
    print("Openned Wifi on the left side")
    wifi=true
end
-- coal on slot 16
-- stone on slot 15
-- dirt on slot 14
-- diorite on slot 13
-- granite on slot 12
-- andeside on 11
-- gravel on 10
slotDenyStart = 10

howFar = { ... }
local depth = 0

if #howFar < 1 then
    print("Usage: ore_finder <repetitions>")
    return
end

function checkItems()
    local dontWant = 0
    for x=1, 4 do
        -- itens I don't want
        for item=slotDenyStart, 15 do
            turtle.select(item)
            if turtle.compare() then
                dontWant = dontWant + 1
            end
        end
        if dontWant == 0 then
            print("found Ore")
            if wifi == true then
                rednet.send(5, "found ore", "shaft")
            end
            turtle.dig()
        end
        turtle.turnRight()
        dontWant = 0
    end
end

function dig()
    while true do
        if move.dn(1) then
            depth = depth + 1
        elseif turtle.digDown() then
            move.dn(1)
            depth = depth + 1
        else
            -- can't go down nor dig down
            break
        end
        --close the hole you entered
        if depth == 2 then
            turtle.select(14)
            turtle.placeUp()
        end
        if depth > 2 then
            checkItems()
        end
        print(depth)
        if wifi == true then
            rednet.send(5, "I'm at "..depth, "status")
        end
    end
    -- reached the bottom.
    -- going to the next shaft
    for iUp=1, 5 do
        if not move.up(1) then
            turtle.digUp()
            move.up(1)
        end
        depth = depth - 1
    end
    for m=1,2 do
        if not move.fd(1) then
            turtle.dig()
            move.fd(1)
        end
    end
    turtle.turnRight()
    turtle.dig()
    if not move.fd(1) then
        turtle.dig()
        move.fd(1)
    end
    turtle.turnLeft()
    print("Going to the next shaft")
    if wifi == true then
        rednet.send(5, "Going to the next shaft", "status")
    end
    --I'm on the next shaft
    --And I should go down a bit
    while true do
        if move.dn(1) then
            depth = depth + 1
        elseif turtle.digDown() then
            move.dn(1)
            depth = depth + 1
        else
            -- can't go down nor dig down
            print("Can't go any further, depth: "..depth)
            if wifi == true then
                rednet.send(5, "Can't go any further, depth: "..depth, "status")
            end
            break
        end
        --close the hole you entered
        if depth == 2 then
            turtle.select(14)
            turtle.placeUp()
        end
        if depth > 2 then
            checkItems()
        end
        print(depth)
    end

    -- comming back to surface
    for goUp=1, depth do
        if not move.up(1) then
            turtle.digUp()
            sleep(0.5)
            move.up(1)
        end
        checkItems()
        print("Depth going up "..goUp.." Of "..depth)
        if wifi == true then
            if depth % 5 == 0 then
                rednet.send(5, "Depth going up "..goUp.." Of "..depth, "status")
            end
        end
    end
    turtle.select(14)
    turtle.placeDown()
end

function cleanTurtle(destroy)
    turtle.select(11)
    turtle.digUp()
    turtle.placeUp()
    for i=1, slotDenyStart do
        turtle.select(i)
        turtle.dropUp()
    end
    turtle.select(1)
    if destroy == 1 then
        turtle.digUp()
    end
end

function rechargeItems()
    for slot=slotDenyStart,16 do
        for ped=1, 10 do
            turtle.select(slot)
            if turtle.compareTo(ped) then
                if turtle.getItemCount(slot) < 10 then
                    turtle.select(ped)
                    turtle.transferTo(slot,54)
                    turtle.select(slot)
                end
                turtle.select(slot)
            end
        end
    end
    --cleanTurtle(0)
end

function runDig()
    for i=1, tonumber(howFar[1]) do
        dig()
        rechargeItems()
        depth=0
        if i < tonumber(howFar[1]) then
            for goo=1, 2 do
                if not move.fd(1) then
                    turtle.dig()
                end
            end
            turtle.turnRight()
            if not move.fd(1) then
                turtle.dig()
            end
            turtle.turnLeft()
        end
    end
    --cleanTurtle(0)
end
--rechargeItems()

runDig()



