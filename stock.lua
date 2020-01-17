os.loadAPI("/ComputerCraft_Learning/move.lua")
os.loadAPI("/ComputerCraft_Learning/check_basics.lua")
if peripheral.isPresent("Left") and peripheral.getType("Left") == "modem" then
    rednet.open("Left")
    print("Openned Wifi on the left side")
    wifi=true
end
listen_computerId=5
start_items = {[16] = {"minecraft:coal",5}, [15] = {"minecraft:torch",20}, [14] = {"minecraft:crafting_table",1}, [13] = {"minecraft:chest",2}}
