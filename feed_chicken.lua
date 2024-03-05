os.loadAPI("/ComputerCraft_Learning/move.lua")
os.loadAPI("/ComputerCraft_Learning/time.lua")
os.loadAPI("/ComputerCraft_Learning/check_basics.lua")
if peripheral.isPresent("Left") and peripheral.getType("Left") == "modem" then
    rednet.open("Left")
    print("Openned Wifi on the left side")
    wifi=true
end
channel=2
turtle.select(1)

params = { ... }
if #params < 1 then
    print("Usage: feed_chicken <which> <how_much>")
    return
end

--We want to add coordinates to the chicken possitions.
--Max 64 seed per turtle.suck
--We want to get back to the original position (in front of the seed barrel)
--base move is 2 dn 6 bk rt 2 and we will be in front of quartz_enriched

function walkPath(path)
    -- save all necessary steps to get to a specific location u, d, b, f, r, l
    --convert path to chicken into actions
    print(pathToSilo)
    for step in string.gmatch(path, "([^%s])") do
       if step == "b" then
           move.bk(1)
       elseif step == "f" then
           move.fd(1)
       elseif step == "u" then
           move.up(1)
       elseif step == "d" then
           move.dn(1)
       elseif step == "r" then
           turtle.turnRight()
       elseif step == "l" then
           turtle.turnLeft()
       end
    end
end

function reversePathTo(path)
    local reversePath = string.reverse(path)
    reversePath = string.gsub(reversePath, "r", "y")
    reversePath = string.gsub(reversePath, "l", "r")
    reversePath = string.gsub(reversePath, "y", "l")
    reversePath = string.gsub(reversePath, "b", "x")
    reversePath = string.gsub(reversePath, "f", "b")
    reversePath = string.gsub(reversePath, "x", "f")
    reversePath = string.gsub(reversePath, "d", "z")
    reversePath = string.gsub(reversePath, "u", "d")
    reversePath = string.gsub(reversePath, "z", "u")
    print(reversePath)
    return reversePath
end


base_move="ddbbbbbb"

chicken_types={
	["minecraft:redstone"]="rfffffr",
	["minecraft:iron_ingot"]="rffffr", 
	["minecraft:gold_ingot"]="rffuur", 
	["minecraft:glowstone"]="rfffr",
	["minecraft:oak_log"]="rfr",
	["refinedstorage:quartz_enriched_iron"]="rr",
	["minecraft:quartz"]="lfl",
	["minecraft:ender_pearl"]="rfffffruu",
	["minecraft:diamond"]="rffffruu",
	["minecraft:lapis_lazuli"]="rfuuuur",
	["minecraft:leather"]="uuuurr",
	["minecraft:obsidian"]="rffffruuuu",
	["minecraft:slime_ball"]="rfffruuuu",
	["minecraft:blaze_rod"]="lfluuuu",
	["minecraft:string"]="rfffffruuuu",
	["mekanism:ingot_osmium"]="rffuuuur",
	["minecraft:emerald"]="lfluu",
	["minecraft:xp_item"]="rruu",
	["minecraft:bone_meal"]="rfuur",
	["minecraft:netherite_scrap"]="rfffruu",
	["minecraft:coal"]="rffr"
}

for chicken, path in pairs(chicken_types) do
    if params[1] == chicken then
        turtle.select(1)
        seeds=tonumber(params[2])
        turtle.suck(seeds)
        print(chicken, path)
        full_path = base_move .. path
        --print(full_path)
        walkPath(full_path)
        print("Depositing seeds")
        turtle.drop(seeds)
        walkPath(reversePathTo(full_path))
        print("We are done")
    end
end
