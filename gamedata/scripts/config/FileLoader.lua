--[[

    Author: EngineOfDarkness

    This work is licensed under the GPL-3.0 License 

    --------------------------------------------

    Loads files which have both the configured naming patter and the configured function
    
    Usage Example:
    
    -- first require the module
    local FileLoader = require "gamedata\\scripts\\config\\FileLoader"
    
    -- then  create an instance - the first two parameters are required, the last paramter defaults to "$game_scripts$" and is the folder in which the search takes place (does not traverse to subfolders!)
    local fileLoaderInstance = FileLoader("*_my_pattern.script", "myCallback")

--]]

local FileLoader   = {}
FileLoader.__index = FileLoader

local function construct(_, fileNamePattern, callbackFunctionName, folder)
    local newFileLoader = {}
    setmetatable(newFileLoader, FileLoader)
    
    assert(fileNamePattern ~= nil and type(fileNamePattern) == "string" and fileNamePattern:len() > 0, "A filename pattern has to be defined, e.g. '*_ltx.script'")
    assert(callbackFunctionName ~= nil and type(callbackFunctionName) == "string" and callbackFunctionName:len() > 0, "A callback function name has to be defined, e.g. 'myCallbackFunction'")

    newFileLoader.fileNamePattern      = fileNamePattern
    newFileLoader.callbackFunctionName = callbackFunctionName
    newFileLoader.folder               = folder or "$game_scripts$"

    return newFileLoader
end

setmetatable(FileLoader, {__call = construct})

function FileLoader:loadFiles()
    local loadedFiles   = {}
    local files         = getFS():file_list_open_ex(self.folder, bit_or(FS.FS_ListFiles,FS.FS_RootOnly), self.fileNamePattern)
    local fileCount     = files:Size()

    for	i=0, fileCount-1 do
        local file      = files:GetAt(i)
        local filename  = file:NameShort()

        if (file:Size() > 0) then
            local fileExtension = self:getFileExtension(filename) 
            filename            = filename:sub(0, filename:len() - fileExtension:len() - 1) -- removes the file extension from the name (-1 because fileExtension does not include the dot)

            if (_G[filename] and _G[filename][self.callbackFunctionName]) then
                loadedFiles[#loadedFiles+1] = filename
            else
                printe("LTX-LIBRARY: ERROR: The filename '%s' does not provide the function '%s', skipping.", filename .. fileExtension, self.callbackFunctionName)
            end
        end
    end

    return loadedFiles
end

function FileLoader:getFileExtension(filename)
    local reversedFilename  = filename:reverse()
    local lastDotPosition   = reversedFilename:find("%.")
	
    return filename:sub(1 - lastDotPosition)
end

return FileLoader
