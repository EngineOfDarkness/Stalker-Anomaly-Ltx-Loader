--[[

    Author: EngineOfDarkness

    This work is licensed under the GPL-3.0 License 

    --------------------------------------------

    Takes care of loading files ending in _ltx.script (by default) and executing a method called "registerLtxModifications" inside each file that has the aforementioned pattern

--]]

local ChangesetLoader   = {}
ChangesetLoader.__index = ChangesetLoader

local function construct(_, callbackFunctionName, folder, fileNamePattern)
    local newChangesetLoader = {}
    setmetatable(newChangesetLoader, ChangesetLoader)

    newChangesetLoader.callbackFunctionName = callbackFunctionName or "registerLtxModifications"
    newChangesetLoader.folder               = folder or "$game_scripts$"
    newChangesetLoader.fileNamePattern      = fileNamePattern or "*_ltx.script"

    return newChangesetLoader
end

setmetatable(ChangesetLoader, {__call = construct})

function ChangesetLoader:processChangesets()
    local loadedFiles       = self:loadCallbackFiles()
    local validChangesets   = self:loadChangesets(loadedFiles)

    --todo rudimentary mod sorting be here

    return validChangesets
end

--loads all .script files that end like this "_ltx.script" - for example "author_modname_ltx.script"
function ChangesetLoader:loadCallbackFiles()
    local loadedFiles   = {}
    local files         = getFS():file_list_open_ex(self.folder, bit_or(FS.FS_ListFiles,FS.FS_RootOnly), self.fileNamePattern)
    local fileCount     = files:Size()

    for	i=0, fileCount-1 do
        local file      = files:GetAt(i)
        local filename  = file:NameShort()

        if (file:Size() > 0) then
            local fileExtension = self:getFileExtension(filename) 
            filename            = filename:sub(0, filename:len() - fileExtension:len() - 1) -- removes the file extension from the name (-1 because I did not include the dot in the fileExtension)

            if (_G[filename] and _G[filename][self.callbackFunctionName]) then
                loadedFiles[#loadedFiles+1] = filename
            else
                printe("LTX-LIBRARY: ERROR: The filename '%s' does not provide the function '%s', skipping.", filename .. fileExtension, self.callbackFunctionName)
            end
        end
    end

    return loadedFiles
end

-- returns the file extension (without the dot)
function ChangesetLoader:getFileExtension(filename)
    local reversedFilename  = filename:reverse()
    local lastDotPosition   = reversedFilename:find("%.")
	
    return filename:sub(1 - lastDotPosition)
end

function ChangesetLoader:loadChangesets(loadedScripts)
    local validChangesets = {}

    for _, filename in ipairs(loadedScripts) do
        local changeset = _G[filename][self.callbackFunctionName]()

        if self:isChangesetValid(changeset, filename) then
            printf("LTX-LIBRARY: Registered changes from '%s'", changeset.name)
            validChangesets[#validChangesets+1] = changeset
        end
    end

    return validChangesets
end

function ChangesetLoader:isChangesetValid(changeset, filename)
    if (not changeset or type(changeset.isValid) ~= "function") then
        printe("LTX-LIBRARY: ERROR: Return value of '%s' is not a Changeset instance, please see the readme section for 'Changeset', modification will be skipped", filename)
        return false
    end

    if not changeset:isValid() then
        printe("LTX-LIBRARY: ERROR: The Changeset from filename '%s' has the following errors, modifications will be skipped", filename)

        local allChangesetErrors = changeset.errors

        for errorIndex, errorMessage in ipairs(allChangesetErrors) do
            printe(" > " .. errorMessage)
        end

        return false
    end

    return true
end

return ChangesetLoader
