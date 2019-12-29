if peripheral.isPresent("Left") and peripheral.getType("Left") == "modem" then
    rednet.open("Left")
    print("Openned Wifi on the left side")
    wifi=true
end
listen_computerId=5
x,y = term.getCursorPos()
function adjustScreen()
  term.clearLine()
  term.setCursorPos(x,y)
end

function wait(qtt)
  if wifi == true then
      rednet.send(listen_computerId,"Waiting "..qtt.." min to try again", "spruceGrab")
  end
  for min=qtt,1,-1 do
    for sec=60,1,-1 do
      if sec==60 then
        adjustScreen()
        print("Waiting "..min..":".."00")
        min=min-1
        sleep(1)
      elseif sec < 10 then
        adjustScreen()
        print("Waiting "..min..":".."0"..sec)
        sleep(1)
      else
        adjustScreen()
        print("Waiting "..min..":"..sec)
        sleep(1)
      end
    end
  end
end
--contador(2)
