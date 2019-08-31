os.loadAPI("/ComputerCraft_Learning/gascontrol.lua")

function up(qtde)
    for i=1, qtde do
        gascontrol.checkFuel()
        if not turtle.up() then
            return turtle.up()
        end
    end
    return true
end

function fd(qtde)
    for i=1, qtde do
        gascontrol.checkFuel()
        if not turtle.forward() then
            return turtle.forward()
        end
    end
    return true
end

function dn(qtde)
    for i=1, qtde do
        gascontrol.checkFuel()
        if not turtle.down() then
            return turtle.down()
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

