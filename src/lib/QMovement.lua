-- Version: 0
local Public = {}

function Public.forward()
    while not turtle.forward() do
        turtle.dig()
    end
end

return Public