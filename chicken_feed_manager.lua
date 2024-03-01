local modem = peripheral.wrap("right")
local wifi = peripheral.wrap("top")

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
			if item.count < 500 then
			    print("["..item.count.."]".." "..item.name) 
                -- Send message to aumoxarife to refil the specific chicken
                -- with the necessary amount to reach 500+
            end
		end
	end
end
