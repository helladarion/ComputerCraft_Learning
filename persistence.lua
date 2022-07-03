-- Database functions

--local initPath = "./ComputerCraft_Learning/persistence.lua"
--loadfile(initPath, getfenv())(fs.getDir(initPath))
-- basename = string.gsub(fs.getName(shell.getRunningProgram()),".lua","")
function getCallerData(program)
    pwd = fs.getDir(program)
    basename = string.gsub(fs.getName(program),".lua","")
    return basename
end

-- print("Here is the program name ".. basename)

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
-- End Database functions

function open_database(caller)
    dbname = "./db/"..getCallerData(caller).."_db.json"
    if save_exists(dbname) then
        local db_file = load_file(dbname)
        print("Database exists")
        if db_file == nil then
            print("database empty or invalid, deleting it")
            fs.delete(dbname)
            error()
        end
        -- print(db_data.facing.starter)
        return db_file
    else
        local db_file = {}
        print("Creating New DB")
        save_file(db_file,dbname)
        return db_file
    end
end

function remove_db(caller)
    dbname = "./db/"..getCallerData(caller).."_db.json"
    fs.delete(dbname)
end

function save_database(db_data,caller)
    dbname = "./db/"..getCallerData(caller).."_db.json"
    print("Saving DB")
    save_file(db_data,dbname)
end

function tprint(tbl, indent)
    if not indent then indent = 0 end
    local toprint = string.rep(" ", indent) .. "{\r\n"
    indent = indent + 2
    for k, v in pairs(tbl) do
        toprint = toprint .. string.rep(" ", indent)
        if (type(k) == "number") then
            toprint = toprint .. "[" ..k.. "] = "
        elseif (type(k) == "string") then
            toprint = toprint .. k .. "= "
        end
        if (type(v) == "number") then
            toprint = toprint .. v .. ",\r\n"
        elseif (type(v) == "string") then
            toprint = toprint .. "\"" .. v .. "\",\r\n"
        elseif (type(v) == "table") then
            toprint = toprint .. tprint(v, indent + 2) .. ",\r\n"
        else
            toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
        end
    end
    toprint = toprint .. string.rep(" ", indent-2) .. "}"
    return toprint
end
--[[
database_name = "./ComputerCraft_Learning/db/items_db.json"
db_data = open_database(database_name)

db_data.position = {}
db_data.running = false
db_data.totalMove = 0 -- param[1]
db_data.startSide = r -- param[2]
db_data.width = 0 -- param[3]
db_data.height = 0 -- param[4]
-- Task in progress
db_data.position.curr_y = 0 -- totalMove
db_data.position.curr_x = 0 -- HEIGHT
db_data.position.curr_width = 0 -- WIDTH
db_data.position.curr_side = "l"
db_data.position.curr_pos = "floor"

save_file(db_data,database_name)

--db_data.memory.position = {}
--db_data.memory.position.f = 0
--db_data.memory.position.b = 0
--db_data.memory.position.u = 0
--db_data.memory.position.d = 0
--db_data.memory.position.r = 0
--db_data.memory.position.l = 0
--]]




