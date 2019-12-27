-- Functions to keep the turtle running
function checkFuel()
    if turtle.getFuelLevel() <= 10 then
        turtle.select(16)
        while not turtle.refuel(1) do
            print("Please insert fuel on slot 16")
            sleep(2)
        end
        print("Refueled! Fuel level at "..turtle.getFuelLevel())
        turtle.select(1)
    end
end
