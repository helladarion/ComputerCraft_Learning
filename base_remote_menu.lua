function pos(...) return term.setCursorPos(...) end
function cls(...) return term.clear() end
function tCol(...) return term.setTextColor(...) end
function bCol(...) return term.setBackgroundColor(...) end
function box(...) return paintutils.drawFilledBox(...) end
function line(...) return paintutils.drawLine(...) end

x,y = term.getSize()
------------------------------------------------------------

function drawMenu()
    cls()
    pos(1,1)
    box(1,1,x,y,colors.lightBlue) -- Background
    box(2,2,25,10,colors.gray) -- Login Menu
    line(2,2,25,2,colors.lightGray) -- Top Bar
    line(23,2,25,2,colors.red) -- Exit
    line(13,4,23,4,colors.black) -- User Field
    line(13,6,23,6,colors.black) -- Pass Field
    line(4,8,10,8,colors.green) -- ( LOGIN )
    line(16,8,23,8,colors.green) -- ( CREATE )

    tCol(colors.black)
    bCol(colors.red)
    pos(24,2)
    write("X")

    tCol(colors.yellow)
    bCol(colors.gray)
    pos(4,4)
    write("USERNAME")
    pos(4,6)
    write("PASSWORD")

    tCol(colors.black)
    bCol(colors.green)
    pos(5,8)
    write("LOGIN")
    pos(17,8)
    write("CREATE")

    tCol(colors.white)
    bCol(colors.black)
end

function login()
    print("LOGIN")
end

function create()
    print("CREATE")
end


function main()
    drawMenu()
    
    while true do
        local event, button, mx, my = os.pullEvent()
        if event == "mouse_click" then
            if mx >= 13 and mx < 23 and my == 4 and button == 1 then -- UserName
                pos(13,4)
                user = read()
                pos(13,6)
                pass = read("*")
                login()
                break
            elseif mx >= 13 and mx < 23 and my == 6 and button == 1 then -- Password
                pos(13,6)
                pass = read("*")
            elseif mx >= 4 and mx < 10 and my == 8 and button == 1 then -- Login
                login()
                break
            elseif mx >= 16 and mx < 23 and my == 8 and button == 1 then -- Create
                create()
                break
            elseif mx >= 23 and mx < 25 and my == 2 and button == 1 then -- X
                os.reboot()
            end

        end
    end
end

------------------------------------------------------------

main()
