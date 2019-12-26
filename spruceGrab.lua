os.loadAPI("/ComputerCraft_Learning/move.lua")
if peripheral.isPresent("Left") and peripheral.getType("Left") == "modem" then
    rednet.open("Left")
    print("Openned Wifi on the left side")
    wifi=true
end
listen_computerId=5
direction=0

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
    print(direction)
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
    while true do
        turtle.select(1)
        move.fd(3)
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
        move.bk(3)
        sleep(60)
    end
end

doRoutine()

