os.loadAPI("/ComputerCraft_Learning/move.lua")
os.loadAPI("/ComputerCraft_Learning/check_basics.lua")
os.loadAPI("/ComputerCraft_Learning/persistence.lua")
local myName = shell.getRunningProgram()
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
-- TODO
-- from start position we want to save where the chest is and have a resume option
-- still not sure how to keep the order of the steps.
-- IDEA:
-- we want to detect if the turtle is currently running. running=true/false
-- we also want to save what was the request params
-- we also want to know what is left to be done.
-- we also want to check where we stopped and be able to resume.


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
    if Qtt > 0 then
        for x=1, tonumber(Qtt) do
            while not move.fd(1) do
                turtle.dig()
                sleep(0.5)
            end
            db_data.position.curr_width = Qtt - x
            persistence.save_database(db_data,myName)
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
    move.bk(steps)
    print("Depositing what we got")
    for x=1, LIMIT do
        turtle.select(x)
        turtle.dropUp()
    end
end

function doTheWork()
-- Calc how much movement will be needed to perform the run
-- WIDTH * HEIGHT * totalDepth + ((totalDeth/2)*(totalDepth/2)+1)
-- 20

    db_data = persistence.open_database(myName)
    -- we want to check if we stopped in the middle or if that is a new run
    if db_data.running == false or db_data.running == nil then
        -- new run
        print("This is a new run")
        db_data.position = {}
        check_basics.checkBasicSetup(start_items)
        db_data.running = true
        totalDepth = tonumber(params[1])
        side = params[2]
        startSide = side
        position = "floor"
        current_width = WIDTH
        current_height = HEIGHT
        gascontrol.precharge(WIDTH * HEIGHT * totalDepth + ((totalDepth/2)*(totalDepth/2)+1))
        print("Starting a "..tostring(WIDTH).." by "..tostring(HEIGHT).." -> "..totalDepth.." times.")
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
    else
        print("We are resuming the task")
        -- resuming run
        -- TODO Fix reading values from json.
        resumed = true
        totalDepth = db_data.totalDepth
        side = db_data.position.curr_side
        startSide = db_data.startSide
        position = db_data.position.curr_pos
        WIDTH = db_data.width
        HEIGHT = db_data.height
        current_width = (db_data.position.curr_width -1)
        current_height = db_data.position.curr_height
        --print("WIDTH VALUE: "..db_data[1].porsition)
        print("Resuming a "..tostring(WIDTH).." by "..tostring(HEIGHT).." -> "..totalDepth.." times.")
        current_side = db_data.position.curr_side
    end
    -- Store start info
    db_data.totalDepth = totalDepth -- param[1]
    db_data.startSide = startSide -- param[2]
    db_data.width = WIDTH -- param[3]
    db_data.height = HEIGHT -- param[4]

    db_data.position.curr_side = current_side
    db_data.position.curr_pos = position

    -- TODO Calculate how much fuel is necessary to perform the run
    for y=1, totalDepth do
        db_data.position.curr_y = y -- totalDepth
        --if turtle.getItemCount(16) < 4 then
        --    print("Not enough fuel to perform the run")
        --    error()
        --end
        print("Executing layer: "..y)
        if db_data.position.curr_height == HEIGHT or db_data.position.curr_height == nil then
            current_height = 1
        else
            curr_height = db_data.position.curr_height
        end
        for x=tonumber(current_height), tonumber(HEIGHT) do
            db_data.position.curr_height = x -- HEIGHT
            if resumed == true then
                caveWalkDig(current_width)
                resumed = false
            else
                caveWalkDig(WIDTH)
            end
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
                db_data.position.curr_side = current_side
                persistence.save_database(db_data,myName)
            end
        end
        if current_side == "r" then
            turtle.turnLeft()
            if not (y == totalDepth) then
                caveWalkDig(1)
                go_that_many_back = y + 1
            else
                go_that_many_back = y
            end
            turtle.turnLeft()
            current_side="l"
        else
            turtle.turnRight()
            if not (y == totalDepth) then
                caveWalkDig(1)
                go_that_many_back = y + 1
            else
                go_that_many_back = y
            end
            turtle.turnRight()
            current_side="r"
        end
        db_data.position.curr_side = current_side
        cleanBlackList()
        sortInventory()
        -- first iteration when the turtle will be on top corner
        if position == "floor" then
            position = "ceiling"
        else
            position = "floor"
        end
        db_data.position.curr_pos = position
        -- Do the deposit with any size
        -- we want to check on the second iteration
        if position == "floor" then
            if current_side == "r" then
                turtle.turnLeft()
            else
                turtle.turnRight()
            end
            print("My side is "..current_side.." we will go back that many "..go_that_many_back)
            depositOres(go_that_many_back)
            if y ~= totalDepth then
                move.fd(go_that_many_back)
                if current_side == "r" then
                    turtle.turnRight()
                else
                    turtle.turnLeft()
                end
            end
        end
        db_data.totalDepth = db_data.totalDepth - y
        persistence.save_database(db_data,myName)
    end
    if not turtle.detectDown() then
        move.dn(tonumber(HEIGHT))
    end
    if totalDepth % 2 ~= 0 then
        if WIDTH % 2 == 0 then
            move.fd(WIDTH)
            if startSide == "r" then
                turtle.turnRight()
            else
                turtle.turnLeft()
            end
        else
            if startSide == "r" then
                turtle.turnLeft()
            else
                turtle.turnRight()
            end
        end
        depositOres(go_that_many_back)
    end

    db_data.running = false
    persistence.save_database(db_data,myName)
    print("I'm done here boss")
end

doTheWork()
persistence.remove_db(myName)
-- TODO
-- Resume not working perfectly
-- calculate all necessary fuel do performe the task
--
-- DATABASE Structure
--[[
db_data = persistence.open_database(myName)

db_data.position = {}
db_data.running = false
db_data.totalDepth = params[1] -- param[1]
db_data.startSide = params[2] -- param[2]
db_data.width = 0 -- param[3]
db_data.height = 0 -- param[4]
-- Task in progress
db_data.position.curr_y = 5 -- totalDepth
db_data.position.curr_x = 0 -- HEIGHT
db_data.position.curr_width = 0 -- WIDTH
db_data.position.curr_side = "l"
db_data.position.curr_pos = "floor"

persistence.save_database(db_data,myName)
print(db_data.position.curr_pos)

--]]
