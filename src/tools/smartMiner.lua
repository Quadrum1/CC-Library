
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
        if not ore_positions[Navigation.positionIndex(ores[i].pos.x, ores[i].pos.y, ores[i].pos.z)] then
            table.insert(ore, ores[i])
            ore_positions[Navigation.positionIndex(ores[i].pos.x, ores[i].pos.y, ores[i].pos.z)] = true
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
            cost = Navigation.distanceCost(pos, ore[i].pos)
            if cost < minCost then
                minCost = cost
                closestOre = i
            end
        end
        closestOre = table.remove(ore, i)
        
        Navigation.setAir(pos.x, pos.y, pos.z)
        path = Navigation.findClearPath({x=pos.x, y=pos.y, z=pos.z}, {x=closestOre.pos.x, y=closestOre.pos.y, z=closestOre.pos.z})
        Instruction.executeSet(Instruction.planDelta(path))
        searchOre()
    end 
   
   pos = Movement.position
   path = Navigation.findClearPath({x=pos.x, y=pos.y, z=pos.z}, {x=0, y=0, z=0})
   Instruction.executeSet(Instruction.planDelta(path))
end

main()