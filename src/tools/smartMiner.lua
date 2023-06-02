

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
   
   Movement.forward()
   Navigation.scanSurroundings(Movement)
end

local function ensureDependencies()
    if not fs.exists("/qmanager.lua") then
        shell.run("pastebin get CODE /QLib/qmanager")
    end
    
    shell.run("qmanager install QMovement")
    shell.run("qmanager install QInstruction")
end
main()