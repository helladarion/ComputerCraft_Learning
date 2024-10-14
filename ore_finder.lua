os.loadAPI("/ComputerCraft_Learning/move.lua")
os.loadAPI("/ComputerCraft_Learning/check_basics.lua")
if peripheral.isPresent("Left") and peripheral.getType("Left") == "modem" then
    rednet.open("Left")
    print("Openned Wifi on the left side")
    wifi=true
end
start_items = {[16] = {"minecraft:charcoal",15}, [15] = {"minecraft:chest",1}}
-- coal on slot 16
-- stone on slot 15
-- dirt on slot 14
-- diorite on slot 13
-- granite on slot 12
-- andeside on 11
-- gravel on 10
slotDenyStart = 14

howFar = { ... }
local depth = 0
local LIMIT=15

if #howFar < 1 then
    print("Usage: ore_finder <repetitions>")
    return
end

function checkItems()
    black_list = {
        "minecraft:cobblestone",
        "minecraft:deepslate",
        "minecraft:tuff",
        "minecraft:stone",
        "minecraft:gravel",
        "minecraft:granite",
        "minecraft:diorite",
        "minecraft:flint",
        "minecraft:dirt",
        "minecraft:andesite"
    }
    local dontWant = 0
    for i=1, 4 do
        for _, item in pairs(black_list) do
	    local boole, array_t = turtle.inspect()
	    if not boole or array_t.name == item then
		    dontWant = dontWant + 1
	    end
        end
        if dontWant == 0 then
            if wifi == true then
                rednet.send(5, "found ore", "shaft")
            end
            turtle.dig()
        end
        turtle.turnRight()
        dontWant = 0
    end
end

function cleanBlackList()
    black_list = {
        "minecraft:cobblestone",
        "minecraft:cobble_deepslate",
        "minecraft:tuff",
        "minecraft:gravel",
        "minecraft:granite",
        "minecraft:diorite",
        "minecraft:flint",
        "minecraft:dirt",
        "minecraft:andesite"
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

function dig()
    while true do
        if move.dn(1,true) then
            depth = depth + 1
            boole, array_v = turtle.inspectDown()
	    if array_v.name == "minecraft:bedrock" then
            	-- can't go down nor dig down
            	break
	    end
        end
        --close the hole you entered
        if depth == 2 then
            turtle.select(1)
            turtle.placeUp()
        end
        if depth > 2 then
            checkItems()
        end
        print(depth)
	if depth == 64 then
    	    cleanBlackList()
        end
        if wifi == true then
            rednet.send(5, "I'm at "..depth, "status")
        end
    end
    -- reached the bottom.
    -- going to the next shaft
    cleanBlackList()
    for iUp=1, 5 do
	move.up(1,true)
        depth = depth - 1
    end
    for m=1,2 do
        move.fd(1,true)
    end
    turtle.turnRight()
    turtle.dig()
    move.fd(1,true)
    turtle.turnLeft()
    print("Going to the next shaft")
    if wifi == true then
        rednet.send(5, "Going to the next shaft", "status")
    end
    --I'm on the next shaft
    --And I should go down a bit
    while true do
        if move.dn(1,true) then
            depth = depth + 1
        else
            -- can't go down nor dig down
            boole, array_v = turtle.inspectDown()
	    if array_v.name == "minecraft:bedrock" then
            	-- can't go down nor dig down
            	print("Can't go any further, depth: "..depth)
            	break
	    end
            if wifi == true then
                rednet.send(5, "Can't go any further, depth: "..depth, "status")
            end
        end
        --close the hole you entered
        if depth == 2 then
            turtle.select(1)
            turtle.placeUp()
        end
        if depth > 2 then
            checkItems()
        end
        print(depth)
    end

    -- comming back to surface
    for goUp=1, depth do
        move.up(1,true)
        checkItems()
        print("Depth going up "..goUp.." Of "..depth)
        if wifi == true then
            if depth % 5 == 0 then
                rednet.send(5, "Depth going up "..goUp.." Of "..depth, "status")
            end
        end
    end
    turtle.select(1)
    turtle.placeDown()
end

function cleanTurtle(destroy)
    turtle.select(15)
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

function sortInventory()
    for slot=1, LIMIT do
        local currentItem = turtle.getItemDetail(slot)
        if currentItem ~= nil and currentItem.count ~= 64 then
            turtle.select(slot)
            for i=1, LIMIT do
                if turtle.compareTo(i) then
                    turtle.select(i)
                    turtle.transferTo(slot)
                end
                turtle.select(slot)
            end
        end
    end
    turtle.select(1)
end

function runDig()
    for i=1, tonumber(howFar[1]) do
	print("Starting here")
        dig()
	sortInventory()
        --rechargeItems()
        depth=0
        if i < tonumber(howFar[1]) then
            for goo=1, 2 do
                move.fd(1,true)
            end
            turtle.turnRight()
            move.fd(1,true)
            turtle.turnLeft()
        end
    end
    --cleanTurtle(0)
end
--rechargeItems()

runDig()



