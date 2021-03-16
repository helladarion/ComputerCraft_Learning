os.loadAPI("/ComputerCraft_Learning/move.lua")
if peripheral.isPresent("Left") and peripheral.getType("Left") == "modem" then
    rednet.open("Left")
    print("Openned Wifi on the left side")
    wifi=true
end
--Faz tuneis para facilitar a escavaåA5A7åA5A3o manual
-- precisa de carvåA5A3o no slot 16
-- um coblestone no slot 15
-- terra no slot 14
-- gravel no slot 13
-- flint no slot 12
-- e varias tochas no slot 11
-- a profundidade tem que ser um multiplo de 7
-- a largura tem que ser um multiplo par de 5
profundidade = { ... }
prof=1
if #profundidade < 1 then
    print( "Usar: caverna <profundidade> <largura>" )
    return
end

function escava(ateonde,vez)
    for prof=1, ateonde do
        if move.fd(1) then
            while turtle.detectUp() or turtle.detectDown() do
                turtle.digUp()
                turtle.digDown()
            end
            if vez % 5 == 0 or vez == 1 then
                if prof % 7 == 0 then
                    botaTocha()
                    limpaTurtle()
                elseif prof % 7 == 0 then
                    limpaTurtle()
                end
            end
        elseif  turtle.dig() then
                if not move.fd(1) then
                    turtle.dig()
                end
                while turtle.detectUp() or turtle.detectDown() do
                    turtle.digUp()
                    turtle.digDown()
                end
                if vez % 5 == 0 or vez == 1 then
                    if prof % 7 == 0 then
                        botaTocha()
                        limpaTurtle()
                    end
                elseif prof % 7 == 0 then
                    limpaTurtle()
                end
        else
            break
        end
    end
end

function limpaTurtle()
    for slot=12, 15 do
        turtle.select(slot)
        for i=1, 10 do
            if turtle.compareTo(i) then
                turtle.select(i)
                turtle.drop()
            end
            turtle.select(slot)
        end
        turtle.select(1)
    end
end

function ajustaInventario()
    for slot=1, 10 do
        turtle.select(slot)
        for i=1, 10 do
            if turtle.compareTo(i) then
                turtle.select(i)
                turtle.transferTo(slot)
            end
            turtle.select(slot)
        end
    end
    turtle.select(1)
end

function botaTocha()
    turtle.select(11)
    turtle.placeDown()
    turtle.select(1)
end

function quantasVezes(qtde)
    for i=1, qtde do
        if wifi == true then
            rednet.send(5,"Doing "..i.."/"..qtde,"cave")
        end
        escava(tonumber(profundidade[1]),tonumber(i))
        if i % 2 == 0 then
            turtle.turnRight()
            escava(1,i)
            turtle.turnRight()
            botaTocha()
            limpaTurtle()
            ajustaInventario()
        else
            turtle.turnLeft()
            escava(1,i)
            turtle.turnLeft()
        end
    end
end
--print(profundidade[2])
quantasVezes(tonumber(profundidade[2]))


--cada salao deveråA1 ter 40 de profundidade
