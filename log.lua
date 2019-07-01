os.loadAPI("/ComputerCraft_Learning/move.lua")

gascontrol.checkFuel()
turtle.select(1)
turtle.dig()
move.fd(1)
while turtle.compareUp() do
    turtle.digUp()
    gascontrol.checkFuel()
    move.up(1)
end
while not turtle.detectDown() do
    gascontrol.checkFuel()
    move.dn(1)
end

