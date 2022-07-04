os.loadAPI("/ComputerCraft_Learning/move.lua")
os.loadAPI("/ComputerCraft_Learning/time.lua")
os.loadAPI("/ComputerCraft_Learning/check_basics.lua")
os.loadAPI("/ComputerCraft_Learning/persistence.lua")
if peripheral.isPresent("Left") and peripheral.getType("Left") == "modem" then
    rednet.open("Left")
    print("Openned Wifi on the left side")
    wifi=true
end
channel=2
turtle.select(1)

function CUI(m)
    n=1
    l=#m
    while true do
        term.clear()
        term.setCursorPos(1,2)
        for i=1, l, 1 do
            if i<10 then
                index="00"..i
            elseif i>=10 and i<100 then
                index="0"..i
            else
                index=i
            end
            if i==n then
                print(index, " ["..m[i].."]")
            else
                print(index, " ", m[i])
            end
        end
        print("Select a number[arrow up/arrow down]")
        a, b = os.pullEventRaw()
        if a == "key" then
            if b==265 and n==1 then n=l+1 end
            if b==265 and n>1 then n=n-1 end
            if b==264 and n<=l then n=n+1 end
            if b==264 and n==l+1 then n=1 end
            if b==257 then break end
        end
    end
    term.clear() term.setCursorPos(1,1)
    return m[n]
end

function pick_keys()
    while true do
        local a, b = os.pullEventRaw()
        print(a, b)
    end
end

--pick_keys()

options={
    "option1",
    "option2",
    "option3",
    "option4",
    "option5",
    "option6",
    "option7",
    "option8",
    "option9",
    "option10",
    "option11"
}
--selected = CUI(options)
--print(selected)
