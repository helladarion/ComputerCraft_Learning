os.loadAPI("/ComputerCraft_Learning/move.lua")
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
    end
    -- reached the bottom.
    -- going to the next shaft
    depth = depth - 5
    move.up(5)
    for m=1,2 do
        if not move.fd(1) then
            turtle.dig()
            move.fd(1)
        end
    end
    turtle.turnRight()
    turtle.dig()
    move.fd(1)
    turtle.turnLeft()
    --I'm in the next shaft
    --And I should go down a bit
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
    end

    -- comming back to surface
    for goUp=1, depth do
        if not move.up(1) then
            turtle.digUp()
            move.up(1)
        end
        checkItems()
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
                while not turtle.forward() do
                    turtle.dig()
                end
            end
            turtle.turnRight()
            while not move.fd(1) do
                turtle.dig()
            end
            turtle.turnLeft()
        end
    end
    --cleanTurtle(0)
end
--rechargeItems()

runDig()



