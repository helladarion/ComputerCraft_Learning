wifi = false
for _, side in pairs(peripheral.getNames()) do
    if peripheral.getType(side) == "modem" then
        rednet.open(side)
        print("Wifi is ON")
        wifi=true
    end
end

function list_machines()
    rednet.broadcast("ping",tostring(os.getComputerID()))
    process="working"
    while process ~= "done" do 
        id, cmd = rednet.receive(5)
        if id ~= nil then
            if cmd.sType == "lookup" then
                print("Received lookup check")
            else
                --print("Command Received")
                print("[ "..id.." ] "..cmd)
            end
        else
            print("idle")
            process="done"
        end
    end
end


params = { ... }


--[[
if #params < 1 then
    print("What machine to you want to control?")
    print("1. Stock Controller")
    print("2. Wheat Farmer")
end
--]]
