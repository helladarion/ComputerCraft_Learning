--monitor = peripheral.wrap("top")
wifi = false
side="Right"
if peripheral.isPresent(side) and peripheral.getType(side) == "modem" then
    rednet.open(side)
    print("Wifi is ON")
    wifi=true
end

print("["..os.getComputerID().."] Waiting for commands")
while wifi do
    id, cmd, args = rednet.receive(5)
    if id ~= null then
        print("Command Received")
        print("[ "..id.." ] "..cmd.." - prot: "..args)
        if cmd == "wood" then
            shell.setDir("ComputerCraft_Learning")
            shell.run("log",args)
        end
        --monitor.write("[ "..id.." ] "..msg.." - prot: "..prot)
    else
        print("idle")
        sleep(2)
    end
end
if not wifi then print("No Modem") end
