--[[

    Author: EngineOfDarkness

    This work is licensed under the GPL-3.0 License 

    --------------------------------------------

    Some functions to ease working with files (e.g. getting the file extension or getting the filename without extension)
    
    Usage Example:
    
    -- first require the module
    local File = require "gamedata\\scripts\\config\\File"
    
    -- then  create an instance - the first parameter is required
    local fileInstance = File("my_file.ltx")
    
    -- lastly execute some function, e.g. removeExtension
    local filenameLessExtension = fileInstance:removeExtension() - variable now contains "my_file"

--]]

local File   = {}
File.__index = File

local function construct(_, filename)
    local newFile = {}
    setmetatable(newFile, File)

    newFile.filename = filename
    
    newFile:validateProperties()

    return newFile
end

setmetatable(File, {__call = construct})

-- not using assert() because there is no reliable way to check which script causes this
-- no, debug.traceback cannot be used because it can happen that the calling script is NOT part of the traceback (yes, had that happen while testing using assert)
function File:validateProperties()
    if type(self.filename) ~= "string" then
        printe("Changeset ERROR: 'filename' can only be a string")
    end

    if type(self.filename) == "string" and string.len(self.filename) == 0 then
        printe("Changeset ERROR: 'filename' is required")
    end
end

-- returns the filename given upon construction of this "object" without the extension
function File:removeExtension()
    local fileExtension = self:getExtension()
    
    return self.filename:sub(0, self.filename:len() - fileExtension:len() - 1) -- removes the file extension from the name (-1 because fileExtension does not include the dot)
end

-- returns the extension of the filename given upon construction of this "object"
function File:getExtension()
    local reversedFilename  = self.filename:reverse()
    local lastDotPosition   = reversedFilename:find("%.")
	
    return self.filename:sub(1 - lastDotPosition)
end

-- checks if the file exists inside the games config dir (can also check subdirs if you give the path as part of the filename)
function File:existsInGameConfigPath()
    local fileSystem = getFS()
    
    return fileSystem:exist("$game_config$", self.filename)
end

return File
