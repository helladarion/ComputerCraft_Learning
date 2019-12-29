rednet.open("Right")
print("Waiting for signals from turtles")
monitor = peripheral.wrap("top")
while true do
    id, msg, prot = rednet.receive()
    if id ~= null then
        print("[ "..id.." ] "..msg.." - prot: "..prot)
        monitor.write("[ "..id.." ] "..msg.." - prot: "..prot)
    end
    sleep(2)
end
