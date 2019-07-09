os.loadAPI("/ComputerCraft_Learning/move.lua")
if peripheral.isPresent("Left") and peripheral.getType("Left") == "modem" then
    rednet.open("Left")
    print("Openned Wifi on the left side")
    wifi=true
end

depth = { ... }
if #depth < 1 then
    print("Usage: stairs <depth>")
    return
end

if wifi == true then
    rednet.send(5,"Doing stairs for "..depth[1].." depth")
end

function cutSides()
    if #depth > 1 then
        turtle.turnLeft()
        turtle.dig()
        turtle.turnRight()
        turtle.turnRight()
        turtle.dig()
        turtle.turnLeft()
    end
end

function torchit()
    turtle.select(15)
    turtle.placeUp()
    turtle.select(1)
end

for i = 1, depth[1] do
    turtle.digDown()
    move.dn(1)
    cutSides()
    turtle.dig()
    move.fd(1)
    cutSides()
    for x =1, 2 do
        turtle.digUp()
        move.up(1)
        cutSides()
    end
    move.dn(1)
    if i % 5 == 0 then
        if wifi == true then
            rednet.send(5,"Torching it at "..i.." depth","stairs_info")
        end
        torchit()
    end
    move.dn(1)
end
