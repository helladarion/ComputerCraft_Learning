--monitor = peripheral.wrap("top")
wifi = false
if peripheral.isPresent("Left") and peripheral.getType("Left") == "modem" then
    rednet.open("Left")
    print("Wifi is ON")
    wifi=true
end
channel=2

print("Waiting for commands")
while wifi do
    id, cmd, args = rednet.receive(5)
    if id ~= null then
        print("Command Received")
        print("[ "..id.." ] "..cmd.." - prot: "..args)
        if cmd == "wood" then
            shell.run("ComputerCraft_Learning/spruceGrab",args)
        end
        --monitor.write("[ "..id.." ] "..msg.." - prot: "..prot)
    else
        print("idle")
        sleep(2)
    end
end
