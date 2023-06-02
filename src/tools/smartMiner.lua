
ore = {}
ore_positions = {}


local function ensureDependencies()
    shell.run("qmanager install QMovement")
    shell.run("qmanager install QInstruction")
    shell.run("qmanager install QNavigation")
end
ensureDependencies()

Movement = require("QLib/packages/QMovement")
Instruction = require("QLib/packages/QInstruction")
Navigation = require("QLib/packages/QNavigation")

Instruction.QInstructionCalls = {
        ["up"] = Movement.up,
        ["down"] = Movement.down,
        ["forward"] = Movement.forward,
        ["backwards"] = Movement.backwards,
        ["left"] = Movement.left,
        ["right"] = Movement.right
}

local function searchOre()
    local filter = function (result) -- Checks for ore
        return result.tags["c:ores"]
    end
    ores = Navigation.scanSurroundings(Movement, filter)
    for i = 1, #ores do
        if not ore_positions[Navigation.positionIndex(ores[i].pos)] then
            table.insert(ore, ores[i])
        else
            ore_positions[Navigation.positionIndex(ores[i].pos)] = true
        end
    end
end

local function main()
    searchOre()
    while #ore > 0 do
        minCost = math.huge
        closestOre = nil
        pos = Movement.position
        for i = 1, #ore do
            cost = distanceCost(pos, ore[i].pos)
            if cost < minCost then
                minCost = cost
                closestOre = ore[i]
            end
        end
        
        local isGoal = function (block)
            return (block.x == closestOre.pos.x and block.y == closestOre.pos.y and block.z == closestOre.pos.z)
        end
        Navigation.findClearPath({x=pos.x, y=pos.y, z=pos.z}, {x=closestOre.x, y=closestOre.y, z=closestOre.z})
        Instruction.executeSet(Instruction.planDelta(path))
        searchOre()
    end 
   
   pos = Movement.position
   path = Navigation.findClearPath({x=pos.x, y=pos.y, z=pos.z}, {x=0, y=0, z=0})
   print(textutils.serialise(path))
   Instruction.executeSet(Instruction.planDelta(path))
end

main()