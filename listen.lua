rednet.open("Right")
print("Waiting for signals from turtles")
peripheral.call("top", "write", "Waiting for signals from turtles")
while true do
    id, msg, prot = rednet.receive()
    if id ~= null then
        print("[ "..id.." ] "..msg.." - prot: "..prot)
        peripheral.call("top", "write", "[ "..id.." ] "..msg.." - prot: "..prot)
    end
    sleep(2)
end
