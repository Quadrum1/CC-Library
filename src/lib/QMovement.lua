-- Version: 0.5
local Public = {}



-- Refactor: Use vector.new() maybe?
-- Limitation: Can only store 3 values (x,y,z), would need rotation seperately
Public.position = {
    w = 0, -- Orientation
    x = 0,
    y = 0,
    z = 0
}

function Public.getForward(modifier)
    if not modifier then modifier = 1 end
    local w = Public.position.w
    if w == 0 then --north
        return {x = Public.position.x, y = Public.position.y, z = Public.position.z - modifier}
    end
    if w == 1 then --east
        return {x = Public.position.x + modifier, y = Public.position.y, z = Public.position.z}
    end
    if w == 2 then --south
        return {x = Public.position.x, y = Public.position.y, z = Public.position.z + modifier}
    end
    if w == 3 then --west
        return {x = Public.position.x - modifier, y = Public.position.y, z = Public.position.z}
    end
end

function Public.getBackwards()
    return Public.getForward(-1)
end

function Public.forward()
    while not turtle.forward() do
        turtle.dig()
    end
    newPos = Public.getForward(1)
    Public.position.x = newPos.x
    Public.position.y = newPos.y
    Public.position.z = newPos.z
end

function Public.backwards()
    turtle.back()
    newPos = Public.getBackwards()
    Public.position.x = newPos.x
    Public.position.y = newPos.y
    Public.position.z = newPos.z
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