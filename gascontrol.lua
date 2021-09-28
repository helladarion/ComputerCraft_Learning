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

-- Calculate necessary amount
function calcNeededFuel(steps)
    -- one coal gives 80 movement
    local current_fuel = turtle.getFuelLevel()
    local calc_needed = steps / 80
    local needed = calc_needed - current_fuel
    if needed > 0 then
        return needed - current_fuel
    else
        return 0
    end
end

calcNeededFuel(300)
