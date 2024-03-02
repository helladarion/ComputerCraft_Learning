--monitor = peripheral.wrap("top")
wifi = false
for _, side in pairs(peripheral.getNames()) do
    if peripheral.getType(side) == "modem" then
        rednet.open(side)
        print("Wifi is ON")
        wifi=true
    end
--if peripheral.isPresent(side) and peripheral.getType(side) == "modem" then
end

print("["..os.getComputerID().."] Waiting for commands")
while wifi do
    id, cmd, args = rednet.receive(5)
    if id ~= nil then
        if cmd.sType == "lookup" then
            print("Received lookup check")
        else
            print("Command Received")
            print("[ "..id.." ] "..cmd.." - prot: "..args)
            shell.setDir("ComputerCraft_Learning")
            if cmd == "ping" then
                shell.run(cmd,tonumber(args))
            else
                rednet.send(id, "Command Received")
                shell.run(cmd,args)
                rednet.send(id, "Task Done")
            end
        end
    else
        print("idle")
    end
end
if not wifi then print("No Modem") end
