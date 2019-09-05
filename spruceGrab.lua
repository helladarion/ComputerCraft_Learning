os.loadAPI("/ComputerCraft_Learning/move.lua")
if peripheral.isPresent("Left") and peripheral.getType("Left") == "modem" then
    rednet.open("Left")
    print("Openned Wifi on the left side")
    wifi=true
end
channel=2

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
    turtle.select(15)
    move.fd(1)
    turtle.place()
    turtle.turnRight()
    move.fd(1)
    turtle.turnLeft()
    turtle.place()
    turtle.turnRight()
    move.bk(1)
    turtle.place()
    turtle.turnLeft()
    move.bk(1)
    turtle.place()
end
cutit()
--plant()
function cutNext()
    turtle.turnLeft()
    move.fd(6)
    turtle.turnRight()
end
