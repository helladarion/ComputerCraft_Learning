wifi = false
for _, side in pairs(peripheral.getNames()) do
    if peripheral.getType(side) == "modem" then
        rednet.open(side)
        print("Wifi is ON")
        wifi=true
    end
end

function wait_response()
    while process ~= "done" do 
        id, cmd = rednet.receive(1)
        if id ~= nil then
            if cmd.sType == "lookup" then
                print("Received lookup check")
            else
                --print("Command Received")
                print("["..id.."] "..cmd)
            end
        else
            --print("idle")
            process="done"
        end
    end
end

function list_machines()
    rednet.broadcast("ping",tostring(os.getComputerID()))
    process="working"
    wait_response()
end


params = { ... }

if #params < 1 then
    print("Usage: remote list [to list machines and ids")
    print("remote <id> <command> <args>")
    return
end

if params[1] == "list" then
    list_machines()
end

if #params > 1 then
    id = tonumber(params[1])
    cmd = params[2]
    if cmd == "feed" then
        save_id = id
        cmd = "chicken_feed_manager"
        args = "report"
        rednet.send(id,cmd,args)
        wait_response()
        id = tonumber(save_id)
        cmd = "chicken_feed_manager"
        args = "feed"
    elseif cmd == "seed" then
        cmd = "farmer"
        args = '2 r'
    elseif cmd == "report" then
        cmd = "chicken_feed_manager"
        args = "report"
    else
        args = params[3]
        if params[4] ~= nil then
            args = args .." " .. params[4]
        end
    end
    rednet.send(id,cmd,args)
    wait_response()
end

--[[
if #params < 1 then
    print("What machine to you want to control?")
    print("1. Stock Controller")
    print("2. Wheat Farmer")
end
--]]
