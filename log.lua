os.loadAPI("/ComputerCraft_Learning/move.lua")
os.loadAPI("/ComputerCraft_Learning/check_basics.lua")

start_items = {[16] = {"minecraft:charcoal",5}, [15] = {"minecraft:oak_sapling",4}, [14] = {"minecraft:bone_meal",16}}


function growTree()
    print("Growing tree")
    turtle.select(14)
    local boole, array_t = turtle.inspect()
    print("Values are "..array_t.name)
    while array_t.name == "minecraft:oak_sapling" do
        if turtle.getItemCount(14) > 0 then
            move.bk(1)
            turtle.place()
            sleep(1)
            move.fd(1)
            boole, array_t = turtle.inspect()
        else
            print("We need more bone meal")
            sleep(5)
        end
    end
end

function plant()
    turtle.select(15)
    turtle.place()
end

function cutit()
    turtle.dig()
    move.fd(1)
    -- Initiating while loop
    local howfar=0
    local boole, array_t = turtle.inspectUp()
    while boole and array_t.name == "minecraft:oak_log" do
        turtle.digUp()
        move.up(1)
        boole, array_t = turtle.inspectUp()
        howfar = howfar + 1
    end
    move.dn(howfar)
    move.bk(1)
end

function prepareCeiling()
    move.fd(4)
    move.up(7)
    turtle.select(1)
    turtle.placeUp()
    move.dn(7)
    move.bk(4)
end

function doRoutine(times)
    print("starting process")
    move.fd(3)
    for i=1, times do
        plant()
        growTree()
        cutit()
    end
    move.bk(3)
end

tArgs = { ... }

check_basics.checkBasicSetup(start_items)
if #tArgs == 1 then
    print("Running limited mode")
    local times = tArgs[1]
    print("We are going to repeat "..times.." times")
    doRoutine(times)
else
    prepareCeiling()
    print("You must specify the number of times you want!")
end
