-- Version: 0.1
local Public = {}


Public.QInstructionCalls = {
        ["up"] = turtle.up,
        ["down"] = turtle.down,
        ["forward"] = turtle.forward,
        ["backwards"] = turtle.back,
        ["left"] = turtle.turnLeft,
        ["right"] = turtle.turnRight
}

function Public.execute(command)
    if Public.QInstructionCalls[command] then
        Public.QInstructionCalls[command]()
    end
end

function Public.executeSet(instructionSet)
    for i=1, #instructionSet, 1 do 
        Public.execute(instructionSet[i])
    end
end


local function decideWay(delta, startPos)
    if delta.y == 1 then
        set.insert("up")
    end
    if delta.y == -1 then
        set.insert("down")
    end
    
    if delta.x == 1 then
        while startPos.w ~= 1 do
            set.insert("right")
            startPos.w = (startPos.w + 1) % 4
        end
        set.insert("forward")
    end
    if delta.x == -1 then
        while startPos.w ~= 3 do
            set.insert("right")
            startPos.w = (startPos.w + 1) % 4
        end
        set.insert("forward")
    end
    
    if delta.z == 1 then
        while startPos.w ~= 2 do
            set.insert("right")
            startPos.w = (startPos.w + 1) % 4
        end
        set.insert("forward")
    end
    if delta.z == -1 then
        while startPos.w ~= 0 do
            set.insert("right")
            startPos.w = (startPos.w + 1) % 4
        end
        set.insert("forward")
    end
    
    return startPos
end

function Public.planDelta(deltaTable, startPos)
    set = {}
    while #deltaTable > 0 do
        -- Delta only contains a single vertice != 0
        delta = table.remove(deltaTable, 1)
        startPos = decideWay(delta,startPos)
    end
end

return Public