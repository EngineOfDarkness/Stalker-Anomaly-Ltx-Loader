--[[

    Author: EngineOfDarkness

    This work is licensed under the GPL-3.0 License 

    --------------------------------------------

    Takes care of Loading Changeset Instances from files which have both the configured naming patter and the configured function
    
    The folder is optional and defaults to "$game_scripts$"

    Usage Example:
    
    -- first require the module
    local ChangesetLoader = require "gamedata\\scripts\\config\\ChangesetLoader"
    
    -- then create an instance - the first two parameters are required, the last paramter defaults to "$game_scripts$" and is the folder in which the search takes place (does not traverse to subfolders!)
    local ChangesetLoaderInstance = ChangesetLoader("*_ltx.script", "registerLtxModifications")

--]]

local FileLoader = require "gamedata\\scripts\\config\\FileLoader"

local ChangesetLoader   = {}
ChangesetLoader.__index = ChangesetLoader

local function construct(_, fileNamePattern, callbackFunctionName, folder)
    local newChangesetLoader = {}
    setmetatable(newChangesetLoader, ChangesetLoader)
    
    assert(fileNamePattern ~= nil and type(fileNamePattern) == "string" and fileNamePattern:len() > 0, "A filename pattern has to be defined, e.g. '*_ltx.script'")
    assert(callbackFunctionName ~= nil and type(callbackFunctionName) == "string" and callbackFunctionName:len() > 0, "A callback function name has to be defined, e.g. 'myCallbackFunction'")

    newChangesetLoader.callbackFunctionName = callbackFunctionName
    newChangesetLoader.fileLoader           = FileLoader(fileNamePattern, callbackFunctionName, folder)

    return newChangesetLoader
end

setmetatable(ChangesetLoader, {__call = construct})

function ChangesetLoader:processChangesets()
    local validChangesets = self:loadChangesets()

    --todo rudimentary mod sorting be here

    return validChangesets
end

function ChangesetLoader:loadChangesets()
    local loadedScripts     = self.fileLoader:loadFiles()
    local validChangesets   = {}

    for _, filename in ipairs(loadedScripts) do
        local changeset = _G[filename][self.callbackFunctionName]()

        if self:isChangeset(changeset) and self:isChangesetValid(changeset, filename) then
            printf("LTX-LIBRARY: Registered changes from '%s'", changeset.name)
            validChangesets[#validChangesets+1] = changeset
        end
        
        if self:isChangesetCollection(changeset) then
            changeset:extractChangesets(function(extractedChangeset)
                if self:isChangesetValid(extractedChangeset, filename) then
                    printf("LTX-LIBRARY: Registered changes from '%s'", extractedChangeset.name)
                    validChangesets[#validChangesets+1] = extractedChangeset
                end
            end)
        end
    end

    return validChangesets
end

function ChangesetLoader:isChangeset(changeset)
    return changeset and type(changeset.changes) == "table"
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

function ChangesetLoader:isChangesetCollection(changeset)
    return changeset and type(changeset.extractChangesets) == "function"
end

return ChangesetLoader
