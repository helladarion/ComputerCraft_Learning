local w, h = term.getSize()
local currTerm = term.current()
local win = window.create(currTerm, 1, 1, w, h, false)

function render()
    term.redirect(win)

    paintutils.drawBox(1, 1, w, h, colors.white)
    --paintutils.drawFilledBox(6, 1, 10, 6, colors.lightGray)
    --paintutils.drawFilledBox(1, 2, 10, 6, colors.gray)
    term.redirect(currTerm)
    win.setVisible(true)
    win.setVisible(false)
    term.setCursorPos(w-8,h)
    term.setTextColor(colors.gray)
    term.setBackgroundColor(colors.white)
    write("0O0O0O0O")
end

function statusScr()
    term.setCursorPos(2,3)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    write("Who is online:")
    term.setCursorPos(2,5)
    write("[1] - Online")
    term.setCursorPos(2,6)
    write("[6] - Offline")
end

local n=1

while true do
    render()
    statusScr()
    local x, y = term.getCursorPos()
    term.setCursorPos(2,1)
    term.setTextColor(colors.lightGray)
    term.setBackgroundColor(colors.white)
    --term.clearLine()
    if n == 1 then write(">Status<  Turtles") else write(" Status  >Turtles<") end
    term.setCursorPos(2,1)
    a, b = os.pullEvent()
    while a~="key" do a, b = os.pullEvent() end
    if b == 203 and n == 2 then n = 1 end
    if b == 205 and n == 1 then n = 2 end
    if b == 28 then print("") break end
end

if n == 1 then return print("Menu") end
if n == 2 then return print("Turtles") end
return false

