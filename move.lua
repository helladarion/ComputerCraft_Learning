os.loadAPI("/ComputerCraft_Learning/gascontrol.lua")

function up(qtde)
    for i=1, qtde do
        gascontrol.checkFuel()
        return turtle.up()
    end
end

function fd(qtde)
    for i=1, qtde do
        gascontrol.checkFuel()
        return turtle.forward()
    end
end

function dn(qtde)
    for i=1, qtde do
        gascontrol.checkFuel()
        return turtle.down()
    end
end

function bk(qtde)
    for i=1, qtde do
        gascontrol.checkFuel()
        return turtle.back()
    end
end

function rd(qtde)
    for i=1, qtde do
        turtle.turnRight()
        turtle.turnRight()
    end
end

