
-- Fetches latest version of module from github.
-- All modules are backwards compatible, unless specified.

local args = {...}


local keywords = {
    ["install"] = true,
    ["update"] = true
}

if #args < 2 or not keywords[args[1]] then
    io.write("Usage:\n")
    -- Install will ensure version and update when version is less than specified
    io.write("qmanager install <package> [v]\n")
    
    -- Update will update package to latest version
    io.write("qmanager update <package> [v]\n")
    return nil
end

local packages = {
    ["QMovement"] = {
        name = "QMovement.lua",
        description = "Basic movement package",
        path = "https://raw.githubusercontent.com/Quadrum1/CC-Library/7eb7ba738bea95697234dcab79dc37436d1456bd/src/lib/QMovement.lua?token=GHSAT0AAAAAACDK5VPB5BOCPFMB4ABOJCB4ZDY5ESQ",
        type = "library"
    },
    ["QInstruction"] = {
        name = "QInstruction.lua",
        description = "Allows executing several commands as a string",
        path = "https://raw.githubusercontent.com/Quadrum1/CC-Library/7eb7ba738bea95697234dcab79dc37436d1456bd/src/lib/QInstruction.lua?token=GHSAT0AAAAAACDK5VPAEPYH5RPP74EKUW6YZDY5EEQ",
        type = "library"
    }
}

if not packages[args[2]] then
    io.write("Invalid package ["..args[2].."] requested\n")
    return nil
end

local function install(package, target_version)
    local response = http and http.get(package.path)
    if not response then
        error("Could not fetch " .. package.name)
    end
    
    local path = "/"
    if package.type == "library" then
        path = "/QLib/packages/"
    end
    
    if fs.exists(path .. package.name) and target_version then
        local f = io.open(path .. package.name)
        local line = f:read()
        f:close()
        line = string.gsub(line, "[%a%p%s]", "") -- Only leave digits
        
        if tonumber(line) >= target_version then
            io.write("Latest version of "..package.name.. " already installed\n")
            return
        end
    end
    
    fs.delete(path .. package.name)
    
    local handle = io.open(path .. package.name, "w")
    if handle then
        handle:write(response.readAll())
        handle:flush()
        handle:close()
    else
        error("Could not write ".. path .. package.name)
    end
    
    io.write("Successfully installed " .. package.name .."\n")
    return nil
end

install(packages[args[2]], args[3])