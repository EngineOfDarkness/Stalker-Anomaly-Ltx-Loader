--[[

    Author: EngineOfDarkness

    This work is licensed under the GPL-3.0 License 

    --------------------------------------------

    Creates a new Change "object" which holds the section name, the property name of that section and the final value

    See README.md for detailed examples

--]]

local Changeset     = {}
Changeset.__index   = Changeset

local function construct(_, changes, name)
    local newChangeset = {}
    setmetatable(newChangeset, Changeset)

    newChangeset.changes    = changes
    newChangeset.name       = name
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

    if type(self.changes) ~= "table" then
        self:addError("Changeset ERROR: changes of a changeset need to be of type table")
        return
    end

    if #self.changes == 0 then
        self:addError("Changeset ERROR: The Changeset has no changes")
    end

    for changeIndex, change in pairs(self.changes) do
        if type(change.isValid) ~= "function" then
            self:addError(string.format("Changeset ERROR: Index %s of the given changes is not a Change instance, please see the readme section for 'Change'", changeIndex))
            goto continue
        end

        if not change:isValid() then
            local errorMessages = change.errors

            self:addError(string.format("Changeset ERROR: The Change at index %s in this Changeset has errors, see following messages", changeIndex))

            for _, errorMessage in ipairs(errorMessages) do
                self:addError("> " .. errorMessage)
            end
        end

        ::continue::
    end
end

function Changeset:addError(message)
    self.errors[#self.errors + 1] = message
end

function Changeset:isValid()
    return #self.errors == 0
end

return Changeset
