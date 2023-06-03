
ore = {}
ore_positions = {}
world = {}

local function ensureDependencies()
    shell.run("qmanager install QMovement")
    shell.run("qmanager install QInstruction")
    shell.run("qmanager install QNavigation")
end
ensureDependencies()

Movement = require("QLib/packages/QMovement")
Instruction = require("QLib/packages/QInstruction")
Navigation = require("QLib/packages/QNavigation")

Instruction.QInstructionCalls.up = Movement.up
Instruction.QInstructionCalls.down = Movement.down
Instruction.QInstructionCalls.forward = Movement.forward
Instruction.QInstructionCalls.backwards = Movement.backwards
Instruction.QInstructionCalls.left = Movement.left
Instruction.QInstructionCalls.right = Movement.right

local function searchOre()
    local filter = function (result) -- Checks for ore
        return result.tags["c:ores"]
    end
    
    ores, blocks, blockKeys = Navigation.scanSurroundings(Movement, filter)

    
    for i = 1, #ores do
        if not ore_positions[Navigation.positionIndex(ores[i].pos.x, ores[i].pos.y, ores[i].pos.z)] then
            table.insert(ore, ores[i])
            ore_positions[Navigation.positionIndex(ores[i].pos.x, ores[i].pos.y, ores[i].pos.z)] = true
        end
    end
    
    -- Save observation data to ledger
    for i = 1, #blockKeys do
        world[blockKeys[i]] = blocks[blockKeys[i]]
    end
end

local function main()
    print("p ", Movement.position.x, Movement.position.y,Movement.position.z, Movement.position.w)
    searchOre()
    print("p ", Movement.position.x, Movement.position.y,Movement.position.z, Movement.position.w)
    
    while #ore > 0 do
        minCost = math.huge
        closestOre = nil
        local pos = Movement.position
        for i = 1, #ore do
            cost = Navigation.distanceCost(pos, ore[i].pos)
            if cost < minCost then
                minCost = cost
                closestOre = i
            end
        end
        closestOre = table.remove(ore, i)
        print("1 ", Movement.position.x, Movement.position.y,Movement.position.z, Movement.position.w)
        print(#world)
        local pos = Movement.position
        
        world[Navigation.positionIndex(pos.x, pos.y, pos.z)] = Navigation.setAir(pos.x, pos.y, pos.z)
        path = Navigation.findClearPath(world, {x=pos.x, y=pos.y, z=pos.z}, {x=closestOre.pos.x, y=closestOre.pos.y, z=closestOre.pos.z})
        print(textutils.serialise(path))
        
        instructions = Instruction.planDelta(path, Movement.position.w)
        print(textutils.serialise(instructions))
        Instruction.executeSet(instructions)
        Navigation.setAir(closestOre.pos.x, closestOre.pos.y, closestOre.pos.z)
        searchOre()
    end 
   
   local pos = Movement.position
   print("p ", Movement.position.x, Movement.position.y,Movement.position.z, Movement.position.w)
   Navigation.setAir(pos.x, pos.y, pos.z)
   path = Navigation.findClearPath(world, {x=pos.x, y=pos.y, z=pos.z}, {x=0, y=0, z=0})
   print("3 " , Movement.position.z, Movement.position.w)
   Instruction.executeSet(Instruction.planDelta(path, pos))
   print("4 " , Movement.position.z, Movement.position.w) -- This is wrong..., why?
   -- Direction in which turtle is pointing is remembered wrong?
end

main()