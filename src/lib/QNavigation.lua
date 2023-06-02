-- Version: 1.0
Public = {}

Public.blockStorage = {}
Calc = {}
Calc.openList = {}
Calc.closedList = {}
Calc.allList = {}
Calc.currentNode = {}
Calc.goal = {}

function positionIndex(x,y,z)
    return x .. " " .. y .. " " .. z
end

local function setBlock(x,y,z,solid, data)
    Public.blockStorage[positionIndex(x,y,z)] = {
        x = x,
        y = y,
        z = z,
        solid = solid,
        data = data
    }
end

function Public.setSolid(x,y,z)
    setBlock(x,y,z,true)
end


function Public.setAir(x,y,z)
    setBlock(x,y,z,false)
end


function Public.scanSurroundings(Movement, filter)
    if not filter then
        local filter = function (a) 
            return false
        end
    end
    
    resultStorage = {}
    for i = 1, 4 do
        success, result = turtle.inspect()
        pos = Movement.getForward()
        if success then 
            result.pos = pos
            if filter(result) then
                table.insert(resultStorage, result)
            end
            Public.setSolid(pos.x, pos.y, pos.z)
        else 
            Public.setAir(pos.x, pos.y, pos.z)
        end
        Movement.left()
    end
    
    success, result = turtle.inspectUp()
    pos = Movement.position
    pos.y = pos.y + 1
    if success then 
        result.pos = pos
        if filter(result) then
            table.insert(resultStorage, result)
        end
        Public.setSolid(pos.x, pos.y, pos.z)
    else 
        Public.setAir(pos.x, pos.y, pos.z)
    end
    
    success, result = turtle.inspectDown()
    pos = Movement.position
    pos.y = pos.y - 1
    if success then 
        result.pos = pos
        if filter(result) then
            table.insert(resultStorage, result)
        end
        Public.setSolid(pos.x, pos.y, pos.z)
    else 
        Public.setAir(pos.x, pos.y, pos.z)
    end
    
    return resultStorage
end

function Public.basicScan(Movement)
    Public.scanSurroundings(Movement)
    
    pos = Movement.position
    Public.setAir(pos.x, pos.y, pos.z)
end

function Public.distanceCost(position1, position2)
    return math.abs(position1.x - position2.x) + math.abs(position1.y - position2.y) + math.abs(position1.z - position2.z)
end


local function successorLoop(delta) 
    x = Calc.currentNode.x + delta[1]
    y = Calc.currentNode.y + delta[2]
    z = Calc.currentNode.z + delta[3]
    
    if not Public.blockStorage[positionIndex(x,y,z)] then return end
    if Public.blockStorage[positionIndex(x,y,z)].solid then return end
    if Calc.closedList[positionIndex(x,y,z)] then return end
        
    tentative_g = Calc.currentNode.g + 1

    if Calc.openList[positionIndex(x,y,z)] and tentative_g >= openList[positionIndex(x,y,z)].g then return end
    successor = {}
    successor.x = x
    successor.y = y
    successor.z = z
    successor.predecessor = positionIndex(Calc.currentNode.x,Calc.currentNode.y,Calc.currentNode.z)
    successor.g = tentative_g
    successor.f = tentative_g + Public.distanceCost(successor, Calc.goal)
    
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
    
    Calc.goal = goal
    
    Calc.openPositions = {}
    Calc.closedList = {}
    Calc.allList = {}
    
    start.g = 0
    start.f = Public.distanceCost(start, Calc.goal)
    
    table.insert(Calc.openPositions, positionIndex(start.x,start.y,start.z))
    while #Calc.openPositions > 0 do
        currentPos = removeMin()
        Calc.currentNode = Public.blockStorage[currentPos]
        
        Calc.allList[positionIndex(Calc.currentNode.x,Calc.currentNode.y,Calc.currentNode.z)] = Calc.currentNode
        if isGoal(Calc.currentNode) then
            -- Goal reached, calculate taken path
            path = {}
            while Calc.currentNode and not (Calc.currentNode.x == start.x and Calc.currentNode.y == start.y and Calc.currentNode.z == start.z) do
                -- Calc path to Calc.currentNode from Calc.currentNode.predecessor
                delta_position = {
                    x = Calc.currentNode.x - Public.blockStorage[Calc.currentNode.predecessor].x,
                    y = Calc.currentNode.y - Public.blockStorage[Calc.currentNode.predecessor].y,
                    z = Calc.currentNode.z - Public.blockStorage[Calc.currentNode.predecessor].z
                }
                table.insert(path, 1, delta_position)
                Calc.currentNode = Calc.openList[Calc.currentNode.predecessor]
            end
            -- Construct path here, starting at start to goal.
            print("Found a path.")
            return path
        end
        -- Find all neighbors
        expandNode()
        Calc.closedList[positionIndex(Calc.currentNode.x,Calc.currentNode.y,Calc.currentNode.z)] = Calc.currentNode
    end

    print("Did not find a path.")
    return nil
end

function Public.findClearPath(startBlock, endPosition, isGoal)
    -- Make sure to 
    if not isGoal then
        local isGoal = function (block)
            return (block.x == endPosition.x and block.y == endPosition.y and block.z == endPosition.z)
        end 
    end
    -- Can define more in-depth function here to allow multi-targetting
    -- For example, can set end position as nearest ore block, or define goal as any ore block
    return A_Star_Pathfinder(startBlock, endPosition, isGoal)
end


Public.positionIndex = positionIndex
return Public