

--ensureDependencies()
Movement = require("QLib/packages/QMovement")
Instruction = require("QLib/packages/QInstruction")
Navigation = require("QLib/packages/QNavigation")



local function main()
   Navigation.scanSurroundings(Movement)
   
   Movement.forward()
   Navigation.scanSurroundings(Movement)
   
   Movement.left()
   Movement.forward()
   Navigation.scanSurroundings(Movement)
   
   Movement.forward()
   Navigation.scanSurroundings(Movement)
   
   Movement.forward()
   Navigation.scanSurroundings(Movement)
   
   Movement.left()
   Movement.forward()
   Navigation.scanSurroundings(Movement)
   
   Movement.left()
   Movement.forward()
   Navigation.scanSurroundings(Movement)
   
   Movement.forward()
   Navigation.scanSurroundings(Movement)
   
   
   pos = Movement.position
   path = Navigation.findClearPath({x=pos.x, y=pos.y, z=pos.z}, {x=0, y=0, z=0})
   print(textutils.serialise(path))
   
   if not (Movement.position.x == 0 and Movement.position.y == 0 and Movement.position.z == 0) then
    print("Manual adjustment taken.")
    Movement.forward()
    Movement.left()
   end
end

local function ensureDependencies()
    if not fs.exists("/qmanager.lua") then
        shell.run("pastebin get CODE /QLib/qmanager")
    end
    
    shell.run("qmanager install QMovement")
    shell.run("qmanager install QInstruction")
end
main()