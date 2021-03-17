os.loadAPI("/ComputerCraft_Learning/move.lua")
os.loadAPI("/ComputerCraft_Learning/check_basics.lua")
-- Wifi related configuration Block --
if peripheral.isPresent("Left") and peripheral.getType("Left") == "modem" then
    rednet.open("Left")
    print("Openned Wifi on the left side")
    wifi=true
end
listen_computerId=5

-- End Wifi related configuration Block --
start_items = {[16] = {"minecraft:coal",15}, [15] = {"minecraft:chest",1}}

-- Database related block --
database = "xcavate_db.json"

function save_exists(name)
    local f=io.open(name,"r")
    if f~=nil then io.close(f) return true else return false end
end

function save_file(table,name)
    local file = fs.open(name,"w")
    file.write(textutils.serialize(table))
    file.close()
end

function load_file(name)
    local file = fs.open(name,"r")
    local data = file.readAll()
    file.close()
    return textutils.unserialize(data)
end
-- End Database related block --

-- Excavator 9x9 following a zigzag pattern

local WIDTH = 20
local HEIGHT = 15
local LIMIT = 14
local CHEST_SLOT = 15

params = { ... }
if #params < 1 then
    print("Usage: xcavator <depth/layers> <r> or <l> for right or left")
    return
end

function caveWalkDig(Qtt)
    for x=1, Qtt do
        while not move.fd(1) do
            turtle.dig()
            sleep(0.5)
        end
    end
end

function cleanBlackList()
    black_list = {
        "minecraft:cobblestone",
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

function checkSpace()
    for i=1, LIMIT do
        if turtle.getItemCount(i) == 0 then
            return false
        end
    end
    return true
end



function doTheWork()
    totalMove = tonumber(params[1])
    side = params[2]
    position = "floor"

    caveWalkDig(1)

    if side == "r" then
        turtle.turnRight()
        current_side="r"
    else
        turtle.turnLeft()
        current_side="l"
    end

    for y=1, totalMove do
        print("Executing layer: "..y)
        for x=1, HEIGHT do
            caveWalkDig(WIDTH)
            if not (x == HEIGHT) then
                if y % 2 == 0 then
                    turtle.digDown()
                    move.dn(1)
                else
                    turtle.digUp()
                    move.up(1)
                end
                -- finished line
                move.rd(1)
                if checkSpace() then
                    cleanBlackList()
                    sortInventory()
                end

                if current_side == "r" then
                    current_side = "l"
                else
                    current_side = "r"
                end
            end
        end
        if current_side == "r" then
            turtle.turnLeft()
            if not (y == totalMove) then
                caveWalkDig(1)
                turtle.turnLeft()
                current_side="l"
            end
        else
            turtle.turnRight()
            if not (y == totalMove) then
                caveWalkDig(1)
                turtle.turnRight()
                current_side="r"
            end
        end
        cleanBlackList()
        sortInventory()
        if position == "floor" then
            position = "ceiling"
        else
            position = "floor"
        end
    end
    if not turtle.detectDown() then
        move.dn(HEIGHT)
    end
    turtle.select(CHEST_SLOT)
    turtle.placeUp()
    for x=1, LIMIT do
        turtle.select(x)
        turtle.dropUp()
    end
end

check_basics.checkBasicSetup(start_items)
doTheWork()
