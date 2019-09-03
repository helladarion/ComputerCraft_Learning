os.loadAPI("/ComputerCraft_Learning/move.lua")
if peripheral.isPresent("Left") and peripheral.getType("Left") == "modem" then
    rednet.open("Left")
    print("Openned Wifi on the left side")
    wifi=true
end

depth = { ... }
if #depth < 1 then
    print("Usage: stairs <depth>")
    return
end

if wifi == true then
    rednet.send(5,"Doing stairs for "..depth[1].." depth")
end

function cutSides()
    if #depth > 1 then
        turtle.turnLeft()
        turtle.dig()
        turtle.turnRight()
        turtle.turnRight()
        turtle.dig()
        turtle.turnLeft()
    end
end

function torchit()
    turtle.select(15)
    turtle.placeUp()
    turtle.select(1)
end

function goDownStairs()
    for i = 1, depth[1] do
        turtle.digDown()
        move.dn(1)
        --cutSides()
        turtle.dig()
        move.fd(1)
        --cutSides()
        for x =1, 2 do
            turtle.digUp()
            move.up(1)
            --cutSides()
        end
        move.dn(1)
        if i % 5 == 0 then
            if wifi == true then
                rednet.send(5,"Torching it at "..i.." depth","stairs_info")
            end
            torchit()
        end
        move.dn(1)
    end
end

function save_file(text,name)
    local file = fs.open(name,"w")
    file.write(text)
    file.close()
end

function load_file(name)
    local file = fs.open(name,"r")
    local data = file.readAll()
    file.close()
    return data
end

-- Make the necessary number of stairs, checking the resources necessary
function createStuff(qtt)
   if qtt <= 4 then
       total_stairs = 1
   else
       total_stairs = math.ceil(qtt/4)
   end
   -- chest
   howManyTimes = 1
   leftover = total_stairs
   while leftover > 10 do
       leftover = total_stairs - 10
       howManyTimes = howManyTimes + 1
   end

   chest = {1,2,3,5,7,9,10,11}
   stairs = {1,5,6,9,10,11}
   for i=1, howManyTimes do
      if howManyTimes > 1 and howManyTimes ~= i then
         currentValue = 10
         turtle.select(13)
         turtle.suckUp(60)
      else
         currentValue = leftover
         turtle.select(13)
         turtle.suckUp(leftover*6)
      end

      for _,v in ipairs(stairs) do
          turtle.select(13)
          turtle.transferTo(v,currentValue)
      end
   end
   turtle.craft(total_stairs)
end

--createStuff(tonumber(depth[1]))
function placeStairs(qtt)
    for i=1, qtt do
        turtle.dig()
        turtle.select(13)
        turtle.place()
        move.up(1)
        move.fd(1)
        checkQtt()
    end
end

function checkQtt()
    if turtle.getItemCount(13) < 2 then
        turtle.select(14)
        turtle.transferTo(13)
        turtle.select(13)
    end
end

placeStairs(tonumber(depth[1]))
