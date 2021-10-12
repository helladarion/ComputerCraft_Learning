os.loadAPI("/ComputerCraft_Learning/gascontrol.lua")

function up(qtde, destroy)
    destroy = destroy or false
    for i=1, qtde do
        gascontrol.checkFuel()
        if not turtle.up() then
            if destroy then
                turtle.digUp()
                sleep(0.5)
                turtle.up()
            end
            --return turtle.up()
        end
    end
    return true
end

function fd(qtde, destroy)
    destroy = destroy or false
    for i=1, qtde do
        gascontrol.checkFuel()
        if not turtle.forward() then
            if destroy then
                while not turtle.forward() do
                    turtle.dig()
                    sleep(0.5)
                end
            end
            --return turtle.forward()
        end
    end
    return true
end

function dn(qtde, destroy)
    destroy = destroy or false
    for i=1, qtde do
        gascontrol.checkFuel()
        if not turtle.down() then
            if destroy then
                turtle.digDown()
                sleep(0.5)
                turtle.down()
            end
            --return turtle.down()
        end
    end
    return true
end

function bk(qtde)
    for i=1, qtde do
        gascontrol.checkFuel()
        if not turtle.back() then
            return turtle.back()
        end
    end
    return true
end

function rd(qtde)
    for i=1, qtde do
        turtle.turnRight()
        turtle.turnRight()
    end
end

