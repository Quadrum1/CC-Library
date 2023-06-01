-- Version: 0
local Public = {}

Public.position = {
    w = 0, -- Orientation
    x = 0,
    y = 0,
    z = 0
}

function Public.forward()
    while not turtle.forward() do
        turtle.dig()
    end
    
    local w = Public.position.w
    if w == 0 then --north
        Public.position.z = Public.position.z - 1
        return
    end
    if w == 1 then --east
        Public.position.x = Public.position.x + 1
        return
    end
    if w == 2 then --south
        Public.position.z = Public.position.z + 1
        return
    end
    if w == 3 then --west
        Public.position.x = Public.position.x - 1
        return
    end
end

function Public.backwards()
    turtle.back()
    
    local w = Public.position.w
    if w == 0 then --north
        Public.position.z = Public.position.z + 1
        return
    end
    if w == 1 then --east
        Public.position.x = Public.position.x - 1
        return
    end
    if w == 2 then --south
        Public.position.z = Public.position.z - 1
        return
    end
    if w == 3 then --west
        Public.position.x = Public.position.x + 1
        return
    end
end

function Public.left()
    turtle.turnLeft()
    Public.position.w = (Public.position.w - 1) % 4
end

function Public.right()
    turtle.turnRight()
    Public.position.w = (Public.position.w + 1) % 4
end

function Public.up()
    while not turtle.up() do
        turtle.digUp()
    end
    Public.position.y = Public.position.y + 1
end

function Public.down()
    while not turtle.down() do
        turtle.digDown()
    end
    Public.position.y = Public.position.y - 1
end

return Public