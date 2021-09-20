os.loadAPI("/ComputerCraft_Learning/move.lua")
os.loadAPI("/ComputerCraft_Learning/time.lua")
if peripheral.isPresent("Left") and peripheral.getType("Left") == "modem" then
    rednet.open("Left")
    print("Openned Wifi on the left side")
    wifi=true
end
channel=2
turtle.select(1)

function plantHarvestCrops()
    for x=1,9 do
        for i=1,8 do
            move.fd(1)
            checkCrops()
        end
        if x % 2 == 0 then
            turn_dir={d = turtle.turnLeft}
        else
            turn_dir={d = turtle.turnRight}
        end
        if x ~= 9 and i ~= 8 then
            turn_dir.d()
            move.fd(1)
            turn_dir.d()
            checkCrops()
        end
    end
end

function checkCrops()
    if turtle.detectDown() == false then
        turtle.select(1)
        turtle.placeDown()
    else
        _, data = turtle.inspectDown()
        if data.state.age == 7 then
            turtle.digDown()
            turtle.select(1)
            turtle.placeDown()
        end
    end
end
function doRoutine()
    move.fd(1)
    plantHarvestCrops()
    move.fd(1)
    move.rd(1)
end

function deposit(item)
    turtle.select(item)
    qtt = turtle.getItemCount(item)
    turtle.turnLeft()
    if qtt > 0 then
        turtle.drop(qtt - 1)
    end
    turtle.turnRight()
end
count = 1
while true do
    doRoutine()
    if count % 2 == 0 then
        deposit(2)
    else
        deposit(1)
    end
    count = count + 1
    time.wait(5)
end
