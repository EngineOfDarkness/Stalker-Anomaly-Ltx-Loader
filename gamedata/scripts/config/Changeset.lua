--[[

    Author: EngineOfDarkness

    This work is licensed under the GPL-3.0 License 
    
    TODO all this validation methods are too much... perhaps I have to implement a validator object or something like that

    --------------------------------------------

    Creates a new Change "object" which holds the section name, the property name of that section and the final value

    See README.md for detailed examples
    
    -- first require the module
    local Changeset = require "gamedata\\scripts\\config\\Changeset"
    
    -- then create an instance - all but the last parameter required, last parameter can be used to modify trader files, e.g. "items\\trade\\trade_stalker_sidorovich.ltx"
    -- the first parameter has to be a table with one or more Change Instances (see Change.lua)
    local changesetInstance = Changeset({change1, Change2, ...}, "My Changeset Name", "some\\ltx.file")

--]]

local File = require "gamedata\\scripts\\config\\File"

local Changeset     = {}
Changeset.__index   = Changeset

local function construct(_, changes, name, ltx, optional)
    local newChangeset = {}
    setmetatable(newChangeset, Changeset)

    newChangeset.changes                = changes
    newChangeset.invalidChanges         = {} -- will contain invalid optional(!) changes, or if the entire changeset is optional, all failed changes that won't be applied
    newChangeset.name                   = name
    newChangeset.ltx                    = ltx
    newChangeset.optional               = optional
    newChangeset.errors                 = {} -- is currently used to decide if the changeset is valid, so contains ALL changes that caused the changeset to fail
    newChangeset.warningsInvalidChanges = {} -- contains the errors of changes that are optional, but not applied due to errors

    newChangeset:validateProperties()
    newChangeset:removeInvalidChanges()

    return newChangeset
end

setmetatable(Changeset, {__call = construct})

-- not using assert() because there is no reliable way to check which script causes this
-- no, debug.traceback cannot be used because it can happen that the calling script is NOT part of the traceback (yes, had that happen while testing using assert)
function Changeset:validateProperties()
    if type(self.name) ~= "string" then
        self:addError("Changeset ERROR: name can only be a string")
    end

    if type(self.name) == "string" and string.len(self.name) == 0 then
        self:addError("Changeset ERROR: name is required")
    end
    
    if type(self.changes) ~= "table" then
        self:addError("Changeset ERROR: changes of a changeset need to be of type table")
        return
    end

    if #self.changes == 0 then
        self:addError("Changeset ERROR: The Changeset has no changes")
        return
    end
    
    if type(self.optional) ~= "boolean" and type(self.optional) ~= "nil" then
        self:addError("Changeset ERROR: 'optional' can only be nil or a boolean value")
        return
    end
    
    if type(self.ltx) ~= "nil" then
        local fileInstance = File(self.ltx)
        
        if type(self.ltx) ~= "string" or string.len(self.ltx) == 0 then
            self:addError("Changeset ERROR: the optional propery 'ltx' is not a valid value like 'items\\trade\\trade_stalker_sidorovich.ltx'")
            return
        end
        
        if type(self.ltx) == "string" and not fileInstance:existsInGameConfigPath() then
            self:addError(string.format("Changeset ERROR: '%s' does not seem to exist", self.ltx))
            return
        end
    end

    self:validateChanges()
end

function Changeset:validateChanges()
    for changeIndex, change in ipairs(self.changes) do
        local isChange = self:isChange(change)
        local isChangeValid = false
        local isChangeValidOnLtx = false
        
        if isChange then
            isChangeValid = change:isValid()
        end
        
        if isChangeValid then
            isChangeValidOnLtx = self:isChangeValidOnLtx(change)
        end

        self:logChangeErrors(change, changeIndex, isChange, isChangeValid, isChangeValidOnLtx)
    end
end

-- logging to "logError" means the changeset becomes invalid, logging to logWarning means it won't.
-- Yeah that's in horrible need of a redo I know.
function Changeset:logChangeErrors(change, changeIndex, isChange, isChangeValid, isChangeValidOnLtx)
    if not isChange then
        self.addError(string.format("Changeset ERROR: Index '%s' of the given changes is not a Change instance, please see the readme section for 'Change'", changeIndex))
        return
    end
    
    local errorLevel = self:getErrorLevel(change)
    local logFunction = "add"..errorLevel:gsub("^%l", string.upper)
    
    if not isChangeValid then
        self[logFunction](self, string.format("Changeset %s: The Change at index '%s' in this Changeset has errors, see following messages", string.upper(errorLevel), changeIndex))

        for _, errorMessage in ipairs(change.errors) do
            self[logFunction](self, "> " .. errorMessage)
        end
        
        return
    end
    
    if not isChangeValidOnLtx then
        local iniName = self.ltx or "system.ltx"
    
        self[logFunction](self, string.format("Change %s: the section '%s' in '%s' does not exist, please use Anomalies default methods to add new sections", string.upper(errorLevel), change.section, iniName))
    end
end

function Changeset:isChange(change)
    return type(change) == "table" and type(change.isValid) == "function"
end

function Changeset:isChangeValidOnLtx(change)
    -- either we have a custom ltx to check the section in or the system.ltx
    local checkIni = self.ltx and ini_file_ex(self.ltx) or ini_sys

    return checkIni:section_exist(change.section)
end

function Changeset:getErrorLevel(change)
    local errorLevel = "error"
    
    if change.optional or (self.optional and type(change.optional) == "nil") then
        errorLevel = "warning"
    end
    
    return errorLevel
end

function Changeset:removeInvalidChanges()
    local validChanges = {}
    
    for _, change in ipairs(self.changes) do
        if self:isChange(change) and change:isValid() and self:isChangeValidOnLtx(change) then
            validChanges[#validChanges + 1] = change
        else
            self.invalidChanges[#self.invalidChanges + 1] = change
        end
    end
    
    self.changes = validChanges
end

function Changeset:getChanges()
    return self.changes
end

function Changeset:addError(message)
    self.errors[#self.errors + 1] = message
end

function Changeset:addWarning(message)
    self.warningsInvalidChanges[#self.warningsInvalidChanges + 1] = message
end

function Changeset:isValid()
    return #self.errors == 0
end

return Changeset
