os.loadAPI("/ComputerCraft_Learning/gascontrol.lua")

function up(qtde)
    for i=1, qtde do
        turtle.up()
        gascontrol.checkFuel()
    end
end

function fd(qtde)
    for i=1, qtde do
        turtle.forward()
        gascontrol.checkFuel()
    end
end

function dn(qtde)
    for i=1, qtde do
        turtle.down()
        gascontrol.checkFuel()
    end
end

function bk(qtde)
    for i=1, qtde do
        turtle.back()
        gascontrol.checkFuel()
    end
end

function rd(qtde)
    for i=1, qtde do
        turtle.turnRight()
        turtle.turnRight()
    end
end

