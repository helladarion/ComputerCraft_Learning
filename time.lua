if peripheral.isPresent("Left") and peripheral.getType("Left") == "modem" then
    rednet.open("Left")
    print("Openned Wifi on the left side")
    wifi=true
end
listen_computerId=5
function adjustScreen()
  term.clear()
  term.setCursorPos(1,1)
end

function wait(qtt)
  for min=qtt,1,-1 do
    for sec=60,1,-1 do
      if sec==60 then
        adjustScreen()
        print("Waiting "..min..":".."00")
        if wifi == true then
            rednet.send(listen_computerId,"Waiting "..min..":".."00", "spruceGrab")
        end
        min=min-1
        sleep(1)
      elseif sec < 10 then
        adjustScreen()
        print("Waiting "..min..":".."0"..sec)
        if wifi == true then
            rednet.send(listen_computerId,"Waiting "..min..":".."0", "spruceGrab")
        end
        sleep(1)
      else
        adjustScreen()
        print("Waiting "..min..":"..sec)
        if wifi == true then
            rednet.send(listen_computerId,"Waiting "..min..":"..sec, "spruceGrab")
        end
        sleep(1)
      end
    end
  end
end
--contador(2)
