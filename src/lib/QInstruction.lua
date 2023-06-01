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

return Public