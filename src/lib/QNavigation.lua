-- Version: 0.8
Public = {}

Public.blockStorage = {}
Calc = {}
Calc.openList = {}
Calc.closedList = {}
Calc.allList = {}
Calc.currentNode = {}
Calc.goal = {}

local function positionIndex(x,y,z)
    return x .. " " .. y .. " " .. z
end

local function setBlock(x,y,z,solid)
    Public.blockStorage[positionIndex(x,y,z)] = {
        x = x,
        y = y,
        z = z,
        solid = solid
    }
end

function Public.setSolid(x,y,z)
    setBlock(x,y,z,true)
end


function Public.setAir(x,y,z)
    setBlock(x,y,z,false)
end

function Public.scanSurroundings(Movement)
    for i = 1, 4 do
        success, result = turtle.inspect()
        pos = Movement.getForward()
        if success then 
            Public.setSolid(pos.x, pos.y, pos.z)
        else
            Public.setAir(pos.x, pos.y, pos.z)
        end
        Movement.left()
    end
    success, result = turtle.inspect()
    pos = Movement.position
    pos.z = pos.z + 1
    if success then 
        Public.setSolid(pos.x, pos.y, pos.z)
    else
        Public.setAir(pos.x, pos.y, pos.z)
    end
    
    success, result = turtle.inspect()
    pos = Movement.position
    pos.z = pos.z - 1
    if success then 
        Public.setSolid(pos.x, pos.y, pos.z)
    else
        Public.setAir(pos.x, pos.y, pos.z)
    end
    
    pos = Movement.position
    Public.setAir(pos.x, pos.y, pos.z)
end

local function distanceCost(position1, position2)
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
    successor.f = tentative_g + distanceCost(successor, Calc.goal)
    
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

local function findAnyPath(start, goal, diggingAllowed)
    -- Implements A* Algorithm, refer to Wikipedia
    
    Calc.goal = goal
    
    Calc.openList = {}
    Calc.openPositions = {}
    Calc.closedList = {}
    Calc.allList = {}
    
    start.g = 0
    start.f = distanceCost(start, Calc.goal)
    Calc.openList[positionIndex(start.x,start.y,start.z)] = start
    table.insert(Calc.openPositions, positionIndex(start.x,start.y,start.z))
    while #Calc.openPositions > 0 do
        currentPos = removeMin()
        print("At ".. currentPos)
        Calc.currentNode = Calc.openList[currentPos]
        
        Calc.allList[positionIndex(Calc.currentNode.x,Calc.currentNode.y,Calc.currentNode.z)] = Calc.currentNode
        if Calc.currentNode.x == goal.x and Calc.currentNode.y == goal.y and Calc.currentNode.z == goal.z then
            -- Goal reached, calculate taken path
            Calc.currentNode = start
            while Calc.currentNode and not (Calc.currentNode.x == goal.x and Calc.currentNode.y == goal.y and Calc.currentNode.z == goal.z) do
                io.write("->".. positionIndex(Calc.currentNode.x,Calc.currentNode.y,Calc.currentNode.z))
                Calc.currentNode = Calc.openList[Calc.currentNode.successor]
            end
            -- Construct path here, starting at start to goal.
            print("Found a path.")
            return -- FOUND PATH
        end
        expandNode()
        Calc.closedList[positionIndex(Calc.currentNode.x,Calc.currentNode.y,Calc.currentNode.z)] = Calc.currentNode
    end

    print("Did not find a path.")
end

function Public.findAnyPath(startPosition, endPosition)
    findAnyPath(startPosition, endPosition, true)
end

function Public.findClearPath(startPosition, endPosition)
    findAnyPath(startPosition, endPosition, false)
end

return Public