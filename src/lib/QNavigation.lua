-- Version: 1.0
Public = {}

Public.blockStorage = {}
Calc = {}
Calc.worldList = {}
Calc.openList = {}
Calc.closedList = {}
Calc.allList = {}
Calc.currentNode = {}
Calc.goal = {}

Walkable = {
    ["minecraft:water"] = true,
    ["minecraft:lava"] = true,
    ["minecraft:seagrass"] = true,
    ["minecraft:lava"] = true,
}

function positionIndex(x,y,z)
    return x .. " " .. y .. " " .. z
end

local function setBlock(x,y,z,solid, data)
    return {
        x = x,
        y = y,
        z = z,
        solid = solid,
        data = data
    }
end

function Public.setSolid(x,y,z, data)
    return setBlock(x,y,z,true, data)
end


function Public.setAir(x,y,z)
    return setBlock(x,y,z,false)
end

--Returns true if block is walkable without breaking action
function Public.walkable(block)
    if not block then return true end
    if Walkable[block.name] then return true end
    return false
end



-- Returns 1. set of blocks matching filter function
-- 2. Every scanned block in a dictionary keyed by position.
-- 3. set of keys matching 2nd return value
function Public.scanSurroundings(Movement, filter)
    
    if not filter then
        filter = function (a) 
            return false
        end
    end
    
    
    resultStorage = {}
    seenStorage = {}
    seenKeys = {}
    
    for i = 1, 4 do
        success, result = turtle.inspect()
        local pos = Movement.getForward()
        if success and not Public.walkable(result) then 
            seenStorage[positionIndex(pos.x, pos.y, pos.z)] = Public.setSolid(pos.x, pos.y, pos.z, result)
            table.insert(seenKeys, positionIndex(pos.x, pos.y, pos.z))
            
            result.pos = pos
            if filter(result) then
                table.insert(resultStorage, result)
            end
        else 
            seenStorage[positionIndex(pos.x, pos.y, pos.z)] = Public.setAir(pos.x, pos.y, pos.z)
            table.insert(seenKeys, positionIndex(pos.x, pos.y, pos.z))
        end
        Movement.right()
    end
    
    
    
    success, result = turtle.inspectUp()
    if success and not Public.walkable(result) then 
        local pos = Movement.position
        seenStorage[positionIndex(pos.x, pos.y + 1, pos.z)] = Public.setSolid(pos.x, pos.y + 1, pos.z, result)
        table.insert(seenKeys, positionIndex(pos.x, pos.y + 1, pos.z))
        
        result.pos = {}
        for k, v in pairs(Movement.position) do result.pos[k] = v end
        result.pos.y = result.pos.y + 1
        if filter(result) then
            table.insert(resultStorage, result)
        end
    else 
        local pos = Movement.position
        seenStorage[positionIndex(pos.x, pos.y + 1, pos.z)] = Public.setAir(pos.x, pos.y + 1, pos.z)
        table.insert(seenKeys, positionIndex(pos.x, pos.y + 1, pos.z))
    end
    
    local success, result = turtle.inspectDown()

    if success and not Public.walkable(result) then 
        local pos = Movement.position
        seenStorage[positionIndex(pos.x, pos.y - 1, pos.z)] = Public.setSolid(pos.x, pos.y - 1, pos.z, result)
        table.insert(seenKeys, positionIndex(pos.x, pos.y - 1, pos.z))
        
        result.pos = {}
        for k, v in pairs(Movement.position) do result.pos[k] = v end
        result.pos.y = result.pos.y - 1
        if filter(result) then
            table.insert(resultStorage, result)
        end
    else 
        local pos = Movement.position
        seenStorage[positionIndex(pos.x, pos.y - 1, pos.z)] = Public.setAir(pos.x, pos.y - 1, pos.z)
        table.insert(seenKeys, positionIndex(pos.x, pos.y - 1, pos.z))
    end
    
    return resultStorage, seenStorage, seenKeys
end

function Public.basicScan(Movement)
    _, seenStorage, seenKeys = Public.scanSurroundings(Movement)
    
    pos = Movement.position
    seenStorage[positionIndex(pos.x, pos.y, pos.z)] = Public.setAir(pos.x, pos.y, pos.z)
    table.insert(seenKeys, positionIndex(pos.x, pos.y, pos.z))
    return seenStorage, seenKeys
end

function Public.distanceCost(position1, position2)
    return math.abs(position1.x - position2.x) + math.abs(position1.y - position2.y) + math.abs(position1.z - position2.z)
end


local function successorLoop(delta) 
    x = Calc.currentNode.x + delta[1]
    y = Calc.currentNode.y + delta[2]
    z = Calc.currentNode.z + delta[3]
    
    if not Calc.worldList[positionIndex(x,y,z)] then return end
    if Calc.worldList[positionIndex(x,y,z)].solid then return end
    if Calc.closedList[positionIndex(x,y,z)] then return end
        
    tentative_g = Calc.currentNode.g + 1

    if Calc.openList[positionIndex(x,y,z)] and tentative_g >= Calc.openList[positionIndex(x,y,z)].g then return end
    successor = {}
    successor.x = x
    successor.y = y
    successor.z = z
    successor.predecessor = positionIndex(Calc.currentNode.x,Calc.currentNode.y,Calc.currentNode.z)
    successor.g = tentative_g
    successor.f = tentative_g + Public.distanceCost(successor, Calc.goal)
    
    successor.data = Calc.worldList[positionIndex(x,y,z)].data
    
    Calc.openList[successor.predecessor].successor = positionIndex(x,y,z)
    Calc.openList[positionIndex(x,y,z)] = successor
    table.insert(Calc.openPositions, positionIndex(x,y,z))
end

local function expandNode()
    delta = {
    {0,1,0},{0,-1,0},
    {1,0,0},{-1,0,0},
    {0,0,1},{0,0,-1},
    }
    for i = 1, 6 do
        successorLoop(delta[i])
    end
end

local function removeMin()
    min = math.huge
    for key, pos in pairs(Calc.openPositions) do
        if Calc.openList[pos].f < min then
            min = Calc.openList[pos].f
        end
    end   

    for key, pos in pairs(Calc.openPositions) do
        if Calc.openList[pos].f == min then
            return table.remove(Calc.openPositions, key)
        end
    end 
    
end

local function A_Star_Pathfinder(start, goal, isGoal)
    -- Implements A* Algorithm, refer to Wikipedia
    
    Calc.worldList[positionIndex(start.x, start.y, start.z)].solid = false
    Calc.worldList[positionIndex(goal.x, goal.y, goal.z)].solid = false
    
    Calc.goal = goal
    
    Calc.openPositions = {}
    Calc.closedList = {}
    Calc.allList = {}
    Calc.openList = {}
    start.g = 0
    start.f = Public.distanceCost(start, Calc.goal)
    
    Calc.openList[positionIndex(start.x,start.y,start.z)] = start
    table.insert(Calc.openPositions, positionIndex(start.x,start.y,start.z))
    while #Calc.openPositions > 0 do
        currentPos = removeMin()

        Calc.currentNode = Calc.openList[currentPos]
        
        Calc.allList[positionIndex(Calc.currentNode.x,Calc.currentNode.y,Calc.currentNode.z)] = Calc.currentNode
        if isGoal(Calc.currentNode) then
            -- Goal reached, calculate taken path
            path = {}
            while Calc.currentNode and not (Calc.currentNode.x == start.x and Calc.currentNode.y == start.y and Calc.currentNode.z == start.z) do
                -- Calc path to Calc.currentNode from Calc.currentNode.predecessor
                delta_position = {
                    x = Calc.currentNode.x - Calc.openList[Calc.currentNode.predecessor].x,
                    y = Calc.currentNode.y - Calc.openList[Calc.currentNode.predecessor].y,
                    z = Calc.currentNode.z - Calc.openList[Calc.currentNode.predecessor].z
                }
                table.insert(path, 1, delta_position)
                Calc.currentNode = Calc.openList[Calc.currentNode.predecessor]
            end
            return path
        end
        -- Find all neighbors
        expandNode()
        Calc.closedList[positionIndex(Calc.currentNode.x,Calc.currentNode.y,Calc.currentNode.z)] = Calc.currentNode
    end

    --print("Did not find a path.")
    return nil
end

function Public.findClearPath(worldList, startBlock, endPosition, isGoal)
    -- Make sure to define this
    if startBlock.x == endPosition.x and startBlock.y == endPosition.y and startBlock.z == endPosition.z then
        return {}
    end
    
    if not isGoal then
        isGoal = function (block)
            return (block.x == endPosition.x and block.y == endPosition.y and block.z == endPosition.z)
        end 
    end
    
    Calc.worldList = worldList
    
    -- Can define more in-depth function here to allow multi-targetting
    -- For example, can set end position as nearest ore block, or define goal as any ore block
    Public.setAir(endPosition.x, endPosition.y, endPosition.z)
    return A_Star_Pathfinder(startBlock, endPosition, isGoal)
end


Public.positionIndex = positionIndex
return Public