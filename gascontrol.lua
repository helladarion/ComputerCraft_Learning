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
function calcNeededFuel(totalsteps)
    -- one coal gives 80 movement
    local current_fuel = turtle.getFuelLevel()
    local steps_needed = totalsteps - current_fuel
    --print("We need that many steps: "..steps_needed)
    local fuel_needed = math.floor(steps_needed / 80)
    if fuel_needed > 0 then
        return steps_needed, (fuel_needed + 1)
    else
        return 0
    end
end

function precharge(fuel)
    turtle.select(1)
    while turtle.getFuelLevel() <= fuel do
        steps, fuelneeded = calcNeededFuel(fuel)
        if fuelneeded ~= nil then
            print("We still need "..fuelneeded.." charcoal pieces to walk "..steps)
        end
        local still_need = fuel - turtle.getFuelLevel()
        if still_need > 0 then
            print("Please insert fuel on slot 16")
            turtle.select(16)
            while not turtle.refuel(1) do
                print("Please insert fuel on slot 16")
                sleep(5)
            end
            print("Refueled! Fuel level at "..turtle.getFuelLevel())
        end
        turtle.select(1)
    end
end

