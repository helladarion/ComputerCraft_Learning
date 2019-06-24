-- Functions to keep the turtle running
function checkFuel()
    if turtle.getFuelLevel() <= 10 then
        turtle.select(16)
        turtle.refuel(1)
        print("Refueled! Fuel level at "..turtle.getFuelLevel())
    end
end
