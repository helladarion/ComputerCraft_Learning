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

-- TODO Make it accept coal or charcoal as fuel
start_items = {[16] = {"minecraft:charcoal",15}, [15] = {"minecraft:chest",1}}

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



params = { ... }
if #params < 1 then
    print("Usage: xcavator <depth/layers> <r> or <l> for right or left <width> <height>")
    return
end

if params[3] ~= nil and params[4] ~= nil then
-- Excavator 9x9 following a zigzag pattern
    WIDTH = tonumber(params[3]) -- Can be even or odd
    HEIGHT = tonumber(params[4]) -- Must be odd number i.e. 7, 9, 15
    print("Selected values are "..WIDTH.." and "..HEIGHT)
else
    WIDTH = 20 -- Can be even or odd
    HEIGHT = 15 -- Must be odd number i.e. 7, 9, 15
end
local LIMIT = 15
local CHEST_SLOT = 15

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

function depositOres(steps)
    turtle.turnRight()
    move.bk(steps)
    print("Depositing what we got")
    for x=1, LIMIT do
        turtle.select(x)
        turtle.dropUp()
    end
end

function doTheWork()
    totalMove = tonumber(params[1])
    side = params[2]
    position = "floor"
    print("Starting a "..tostring(WIDTH).." by "..tostring(HEIGHT).." -> "..totalMove.." times.")

    -- Place chest to store the ores
    turtle.select(CHEST_SLOT)
    turtle.placeUp()

    caveWalkDig(1)

    if side == "r" then
        turtle.turnRight()
        current_side="r"
    else
        turtle.turnLeft()
        current_side="l"
    end

    -- TODO Calculate how much fuel is necessary to perform the run
    for y=1, totalMove do
        if turtle.getItemCount(16) < 4 then
            print("Not enough fuel to perform the run")
            error()
        end
        print("Executing layer: "..y)
        for x=1, tonumber(HEIGHT) do
            caveWalkDig(tonumber(WIDTH))
            if not (x == tonumber(HEIGHT)) then
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
                go_that_many_back = y + 1
            else
                go_that_many_back = y
            end
            turtle.turnLeft()
            current_side="l"
        else
            turtle.turnRight()
            if not (y == totalMove) then
                caveWalkDig(1)
                go_that_many_back = y + 1
            else
                go_that_many_back = y
            end
            turtle.turnRight()
            current_side="r"
        end
        cleanBlackList()
        sortInventory()
        -- first iteration when the turtle will be on top corner
        if position == "floor" then
            position = "ceiling"
        else
            position = "floor"
        end
        -- we want to check on the second iteration
        if position == "floor" and params[4] == nil then
            depositOres(go_that_many_back)
            if y ~= totalMove then
                move.fd(go_that_many_back)
                if current_side == "r" then
                    turtle.turnRight()
                else
                    turtle.turnLeft()
                end
            end
        end
    end
    if not turtle.detectDown() then
        move.dn(tonumber(HEIGHT))
    end
end

check_basics.checkBasicSetup(start_items)
doTheWork()
-- TODO
-- We want to have a resume function, so it could just continue the job if it
-- for any reason stops.
