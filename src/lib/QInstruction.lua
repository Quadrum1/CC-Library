-- Version: 0.1
local Public = {}
local Calc = {}

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
    if not delta then return {} end
    if not startPos then
        startPos = {w = 0}
    end
        
    local w = startPos.w
    if delta.y == 1 then
        table.insert(Calc.set, "up")
    end
    if delta.y == -1 then
        table.insert(Calc.set, "down")
    end
    
    if delta.x == 1 then
        while w ~= 1 do
            table.insert(Calc.set, "right")
            w = (w + 1) % 4
        end
        table.insert(Calc.set, "forward")
    end
    if delta.x == -1 then
        while w ~= 3 do
            table.insert(Calc.set, "right")
            w = (w + 1) % 4
        end
        table.insert(Calc.set, "forward")
    end
    
    if delta.z == 1 then
        while w ~= 2 do
            table.insert(Calc.set, "right")
            w = (w + 1) % 4
        end
        table.insert(Calc.set, "forward")
    end
    if delta.z == -1 then
        while w ~= 0 do
            table.insert(Calc.set, "right")
            w = (w + 1) % 4
        end
        table.insert(Calc.set, "forward")
    end
    
    return w
end

function Public.planDelta(deltaTable, startPos)
    if not deltaTable then return {} end
    if not startPos then return {} end
    Calc.set = {}
    local w = startPos.w
    
    while #deltaTable > 0 do
        -- Delta only contains a single vertice != 0
        delta = table.remove(deltaTable, 1)
        w = decideWay(delta,w)
    end
    return Calc.set
end

return Public