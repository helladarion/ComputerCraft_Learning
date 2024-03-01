local modem = peripheral.wrap("right")
side="top"
if peripheral.isPresent(side) and peripheral.getType(side) == "modem" then
    rednet.open(side)
    print("Openned Wifi on the ".. side .." side")
    wifi=true
end
listen_computerId=3
MaxAmount=200

params = { ... }

function refil_item(who, qtt)
    if wifi == true then
        print("Asking to refil "..who)
        rednet.send(listen_computerId, "feed_chicken", who.." "..qtt)
        sleep(25)
        id=nil
        --[[
        while id == nil do 
            id, cmd, args = rednet.receive(5)
            if cmd.sType == "lookup" then
                print("Received lookup check")
            else
                print("Command Received")
                print("[ "..id.." ] "..cmd.." - prot: "..args)
                if cmd == "Task Done" then
                    print("Process Done")
                    break
                else
                    print("idle")
                    sleep(2)
                end
            end
        end
        --]]
    end
end

for slot, item in pairs(modem.list()) do
	--[[
	if string.find(item.name,"rod") then
		print(item.name)
	end
	--]]
	items_to_check={
		"minecraft:redstone", 
		"minecraft:iron_ingot", 
		"minecraft:gold_ingot", 
		"minecraft:glowstone",
		"minecraft:oak_log",
		"minecraft:quartz_enriched_iron",
		"minecraft:quartz",
		"minecraft:ender_pearl",
		"minecraft:diamond",
		"minecraft:lapis_lazuli",
		"minecraft:leather",
		"minecraft:obsidian",
		"minecraft:slime_ball",
		"minecraft:blaze_rod",
		"minecraft:string",
		"mekanism:ingot_osmium",
		"minecraft:emerald",
		"minecraft:xp_item",
		"minecraft:bone_meal",
		"minecraft:netherite_scrap",
		"minecraft:coal"
	}
	for _, iname in pairs(items_to_check) do
		if item.name == iname then
			if item.count < MaxAmount then
                missing = MaxAmount - item.count
                seeds_needed=math.ceil(missing / 3)
                if seeds_needed > 64 then
                    seeds_needed=64
                end
			    print("["..item.count.."]".." "..item.name, missing) 
                print("We need to add "..seeds_needed.. " seeds")
                -- Send message to aumoxarife to refil the specific chicken
                -- with the necessary amount to reach 500+
                if #params == 1 then
                    refil_item(item.name, seeds_needed)
                end
            end
		end
	end
end

