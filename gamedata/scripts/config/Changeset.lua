--[[

    Author: EngineOfDarkness

    This work is licensed under the GPL-3.0 License 

    --------------------------------------------

    Creates a new Change "object" which holds the section name, the property name of that section and the final value

    See README.md for detailed examples

--]]

local Changeset     = {}
Changeset.__index   = Changeset

local function construct(_, changes, name, ltx)
    local newChangeset = {}
    setmetatable(newChangeset, Changeset)

    newChangeset.changes    = changes
    newChangeset.name       = name
    newChangeset.ltx        = ltx
    newChangeset.errors     = {}

    newChangeset:validateProperties()

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
    
    if type(self.ltx) ~= "nil" and (type(self.ltx) ~= "string" or string.len(self.ltx) == 0) then
        self:addError("Changeset ERROR: ltx is not a valid value like 'items\\trade\\trade_stalker_sidorovich.ltx'")
    end

    if type(self.changes) ~= "table" then
        self:addError("Changeset ERROR: changes of a changeset need to be of type table")
        return
    end

    if #self.changes == 0 then
        self:addError("Changeset ERROR: The Changeset has no changes")
    end

    self:validateChanges()
end

function Changeset:validateChanges()
    for changeIndex, change in pairs(self.changes) do
        if type(change.isValid) ~= "function" then
            self:addError(string.format("Changeset ERROR: Index '%s' of the given changes is not a Change instance, please see the readme section for 'Change'", changeIndex))
            goto continue
        end

        if not change:isValid() then
            local errorMessages = change.errors

            self:addError(string.format("Changeset ERROR: The Change at index '%s' in this Changeset has errors, see following messages", changeIndex))

            for _, errorMessage in ipairs(errorMessages) do
                self:addError("> " .. errorMessage)
            end
        end
        
        self:validateChangeOnLtx(change)

        ::continue::
    end
end

function Changeset:validateChangeOnLtx(change)
    -- either we have a custom ltx to check the section in or the system.ltx
    local checkIni = self.ltx and ini_file_ex(self.ltx) or ini_sys
    local iniName = self.ltx or "system.ltx"

    -- if a change is actually valid or not needs to be confirmed in the Changeset - the Change does not know anything about which ini it's getting executed on
    if not checkIni then
        self:addError(string.format("> Change ERROR: '%s' could not be loaded", iniName))
        return
    end

    if not checkIni:section_exist(change.section) then
        self:addError(string.format("> Change ERROR: the section '%s' in '%s' does not exist, please use Anomalies default methods to add new items", self.section, iniName))
    end
end

function Changeset:addError(message)
    self.errors[#self.errors + 1] = message
end

function Changeset:isValid()
    return #self.errors == 0
end

return Changeset
