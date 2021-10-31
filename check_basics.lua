function groupSimilar()
    for i=1, 16 do
        if turtle.getItemCount(i) > 0  and turtle.getItemCount(i) < 64 then
            itemID = turtle.getItemDetail(i).name
            for x=1, 16 do
                if turtle.getItemCount(x) > 0 and turtle.getItemCount(x) < 64 and  x ~= i and turtle.getItemDetail(x).name ==  itemID and turtle.getItemDetail(x).name ~= "minecraft:chest" then
                    turtle.select(i)
                    turtle.transferTo(x)
                    break
                end
            end
        end
    end
end

function organizeItems(limit)
    limit = limit or 12
    for i=1, limit do
        freeSlot=nil
        if turtle.getItemCount(i) == 0 then
            freeSlot=i
            for x=i, limit do
                if turtle.getItemCount(x) > 0 then
                    turtle.select(x)
                    turtle.transferTo(freeSlot)
                    break
                end
            end
        end
    end
end

local LIMIT = 15

function cleanBlackList()
    black_list = {
        "minecraft:cobblestone",
        "minecraft:gravel",
        "minecraft:granite",
        "minecraft:diorite",
        "minecraft:flint",
        "minecraft:dirt",
        "minecraft:andesite"
    }

    for i=1, LIMIT do
        for _, item in pairs(black_list) do
            local currentItem = turtle.getItemDetail(i)
            if currentItem ~= nil then
                if currentItem.name == item then
                    turtle.select(i)
                    turtle.drop()
                end
            end
        end
    end
end

--start_items = {[16] = {"minecraft:coal",5}, [15] = {"minecraft:torch",10}, [14] = {"minecraft:crafting_table",1}, [13] = {"minecraft:chest",2}}
function checkBasicSetup(start_items, on_hold)
    groupSimilar()
    local allgood = true
    for i=1, 16 do
        if turtle.getItemCount(i) == 0 then
            swap_spot = i
            break
        end
    end
    if not swap_spot then
        print("We have no empty spots, getting rid of some cobblestone")
        for x=1, 16 do
            if turtle.getItemDetail(x).name == "minecraft:cobblestone" then
                turtle.select(x)
                turtle.dropDown()
                swap_spot = x
                break
            end
        end
    end
    for k,v in pairs(start_items) do
        local found = false
        for y=1, 16 do
            if turtle.getItemCount(y) > 0 and turtle.getItemDetail(y).name == v[1]  and k ~= y and turtle.getItemCount(y) >= v[2] then
                turtle.select(k)
                turtle.transferTo(swap_spot)
                turtle.select(y)
                if on_hold ~= nil then
                   qtde_item = on_hold[k]
                   print(qtde_item, k)
                   turtle.transferTo(k,qtde_item)
                else
                    turtle.transferTo(k)
                end
                swap_spot = y
                found = true
                break
            elseif turtle.getItemCount(y) > 0 and turtle.getItemDetail(y).name == v[1]  and k == y and turtle.getItemCount(y) >= v[2] then
                found = true
                break
            end
        end
        if not found then
            print("We need at least: "..v[2].." -  "..v[1])
            allgood = false
        end
    end
    if not allgood then
        print("Please provide de missing items")
        error()
    else
        print("We are good to go")
    end
end
