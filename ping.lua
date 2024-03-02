wifi = false
for _, side in pairs(peripheral.getNames()) do
    if peripheral.getType(side) == "modem" then
        rednet.open(side)
        print("Wifi is ON")
        wifi=true
    end
end

params = { ... }
return_id = params[1]

rednet.send(tonumber(return_id), os.getComputerLabel(), "")
print("Sending message back to "..return_id.." with my label: "..os.getComputerLabel())
