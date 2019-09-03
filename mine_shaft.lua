os.loadAPI("/ComputerCraft_Learning/move.lua")
if peripheral.isPresent("Left") and peripheral.getType("Left") == "modem" then
    rednet.open("Left")
    print("Openned Wifi on the left side")
    wifi=true
end
channel=2
turtle.select(1)

params = { ... }
if #params < 1 then
    print("Usage: mine_shaft <distance>")
    return
end

function caveWalkDig(Qtt)
    for x=1, Qtt do
        if not move.fd(1) then
            turtle.dig()
            move.fd(1)
            digUpDown()
        else
            -- break up and down
            digUpDown()
        end
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
    turtle.select(11)
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
    move.fd(3)
    if side == "r" then
        turtle.turnRight()
    else
        turtle.turnLeft()
    end

    if wifi == true then
        rednet.send(channel, "I'm Done come see me", "status")
    end
end

for i=1, 2 do
    doTheWork()
end

