os.loadAPI("/ComputerCraft_Learning/move.lua")
os.loadAPI("/ComputerCraft_Learning/check_basics.lua")
if peripheral.isPresent("Left") and peripheral.getType("Left") == "modem" then
    rednet.open("Left")
    print("Openned Wifi on the left side")
    wifi=true
end
channel=5
turtle.select(1)

start_items = {[16] = {"minecraft:coal",15}, [15] = {"minecraft:torch",30}, [14] = {"minecraft:chest",2}}
-- coal on 16
-- torches on 15
-- 2 chests on 14
params = { ... }
if #params < 3 then
    print("Usage: mine_shaft <distance> <r> or <l> for right or left <howManyTimes>")
    return
end

function caveWalkDig(Qtt)
    for x=1, Qtt do
        while not move.fd(1) do
            turtle.dig()
            sleep(0.5)
        end
        digUpDown()
    end
end

function shaft(howfar)
    for x=1, howfar do
        caveWalkDig(1)
        -- place torches every 14
        if x == 1 then
            placeTorch()
        end
        if x % 14 == 0 then
            placeTorch()
        end
        if x % 50 == 0 then
            check_basics.cleanBlackList()
        end
    end
    placeTorch()
end

function digUpDown()
    while turtle.detectUp() or turtle.detectDown() do
        turtle.digUp()
        turtle.digDown()
        sleep(0.5)
    end
end

function placeTorch()
    turtle.select(15)
    turtle.placeDown()
    turtle.select(1)
    if wifi == true then
        rednet.send(channel, "I'm placing a torch", "status")
    end
end

function doTheWork()
    totalMove=tonumber(params[1])
    side=params[2]

    if wifi == true then
        rednet.send(channel, "Starting the work, shaft with "..totalMove.." and turning to the "..side, "status")
    end

    shaft(totalMove)
    -- turn and get ready to go back, from other shaft
    if wifi == true then
        rednet.send(channel, "I'm turning back", "status")
    end
    if side == "r" then
        turtle.turnRight()
    else
        turtle.turnLeft()
    end
    caveWalkDig(4)
    if side == "r" then
        turtle.turnRight()
    else
        turtle.turnLeft()
    end
    -- dig the next shaft back
    shaft(totalMove)
    -- Finishing and getting out of the way
    if side == "r" then
        turtle.turnLeft()
    else
        turtle.turnRight()
    end
    caveWalkDig(4)
    if side == "r" then
        turtle.turnLeft()
    else
        turtle.turnRight()
    end

    if wifi == true then
        rednet.send(channel, "I'm Done come see me", "status")
    end
end

check_basics.checkBasicSetup(start_items)
howmanytimes=tonumber(params[3])

for i=1, howmanytimes do
    doTheWork()
    check_basics.cleanBlackList()
    turtle.select(14)
    turtle.placeUp()
    -- cleaning turtle
    for i=1,13 do
        turtle.select(i)
        turtle.dropUp()
    end
end

