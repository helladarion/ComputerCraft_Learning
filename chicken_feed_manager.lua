modem = peripheral.wrap("right")
wifi = false
for _, side in pairs(peripheral.getNames()) do
    if peripheral.getType(side) == "modem" then
        rednet.open(side)
        print("Wifi is ON")
        wifi=true
    end
end

listen_computerId=3
tablet_id=4
MaxAmount=1200

params = { ... }

--function split(str,sep)
--    sep = sep or ":"
--    local ret = {}
--    for token in str:gmatch("[^"..sep.."]+") do
--        ret[#ret+1] = token
--    end
--    return ret
--end

local function split(inputString, separatorCharacter)
  if (type(separatorCharacter) ~= "string") then
        separatorCharacter = "\n"
  end
  local returnTable = {}
  local i = 1
  --#We're going to be editing our input string, so we need to know when we're done
  while (inputString ~= "") do
        local start,endNum = string.find(inputString,separatorCharacter)
        if (start == nil) then
          returnTable[i] = inputString
          inputString = ""
        else
          if (start == 1) then
                returnTable[i] = ""
          else
                returnTable[i] = inputString:sub(1,start-1)
          end
          inputString = inputString:sub(endNum+1)
        end
        i = i + 1
  end
  return returnTable
end

function refil_item(who, qtt)
    if wifi == true then
        print("Asking to refil "..who)
        rednet.send(listen_computerId, "feed_chicken", who.." "..qtt)
        process="working"
        count=1
        while process ~= "done" do 
            id, cmd = rednet.receive(5)
            if id ~= nil then
                if cmd.sType == "lookup" then
                    print("Received lookup check")
                else
                    print("Command Received")
                    print("[ "..id.." ] "..cmd)
                    if cmd == "Command Received" then
                        print("Doing Task")
                    elseif cmd == "Task Done" then
                        print("We are done with "..who)
                        process="done"
                    end
                end
            else
                print("idle")
                count = count + 1
            end
        end
    end
end

for slot, item in pairs(modem.list()) do
    --[[
	if string.find(item.name,"quart") then
		print(item.name)
	end
    --]]
	items_to_check={
		"minecraft:redstone", 
		"minecraft:iron_ingot", 
		"minecraft:gold_ingot", 
		"minecraft:glowstone",
		"minecraft:oak_log",
		"refinedstorage:quartz_enriched_iron",
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
                if params[1] == "feed" then
                    refil_item(item.name, seeds_needed)
                elseif params[1] == "full" then
                    while true do
                        refil_item(item.name, seeds_needed)
                        if item.count >= MaxAmount then
                            break
                        end
                    end
                elseif params[1] == "report" then
                    item_name = split(item.name,":")[2]
                    rednet.send(tablet_id, "["..item.count.."] "..item_name.." ".." "..missing)
                end
            end
		end
	end
end

