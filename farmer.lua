os.loadAPI("/ComputerCraft_Learning/move.lua")
os.loadAPI("/ComputerCraft_Learning/time.lua")
os.loadAPI("/ComputerCraft_Learning/check_basics.lua")
if peripheral.isPresent("Left") and peripheral.getType("Left") == "modem" then
    rednet.open("Left")
    print("Openned Wifi on the left side")
    wifi=true
end
channel=2
turtle.select(1)
start_items = {[16] = {"minecraft:coal",5}, [1] = {"minecraft:wheat_seeds",10}}

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

function checkPos()
    crop_list = { "minecraft:wheat_seeds",
                  "minecraft:wheat"
                }
    seed_pos=1
    wheat_pos=2
    LIMIT=15
    -- Auto detecting where the seed is
    for i=1, LIMIT do
        for _, item in pairs(crop_list) do
            local currentItem = turtle.getItemDetail(i)
            if currentItem ~= nil then
                if currentItem.name == item then
                    if item == "minecraft:wheat_seeds" then
                        seed_pos=i
                    else
                        wheat_pos=i
                    end
                end
            end
        end
    end
end

function checkCrops()
    checkPos()
    if turtle.detectDown() == false then
        turtle.select(seed_pos)
        turtle.placeDown()
    else
        _, data = turtle.inspectDown()
        if data.state.age == 7 then
            turtle.digDown()
            turtle.select(seed_pos)
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
        turtle.dropDown(qtt - 1)
    end
    turtle.turnRight()
end

check_basics.checkBasicSetup(start_items)

count = 1
while true do
    doRoutine()
    check_basics.groupSimilar()
    checkPos()
    if count % 2 == 0 then
        deposit(wheat_pos)
    else
        deposit(seed_pos)
    end
    count = count + 1
    time.wait(5)
end
