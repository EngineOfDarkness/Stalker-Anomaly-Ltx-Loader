--[[

    Author: EngineOfDarkness

    This work is licensed under the GPL-3.0 License 

    --------------------------------------------

    Creates a new Change "object" which holds the section name, the property name of that section and the final value

    See README.md for detailed examples
    
    -- first require the module
    local Change = require "gamedata\\scripts\\config\\Change"
    
    -- then create an instance - the first three parameters are required, the propertyValue can be "nil" if you want to remove the property
    -- the last parameter controls if this change can be discarded from the changeset if it happens to be invalid (e.g. if another mod removed a section)
    local changeInstance = Change("sectionName", "propertyName", "propertyValue")

--]]

local Change    = {}
Change.__index  = Change

local function construct(_, section, property, value, optional)
    local newChange = {}
    setmetatable(newChange, Change)

    newChange.section   = section
    newChange.property  = property
    newChange.value     = value
    newChange.optional  = optional
    newChange.errors    = {}

    newChange:validateProperties()

    return newChange
end

setmetatable(Change, {__call = construct})

-- not using assert() because there is no reliable way to check which script causes this
-- no, debug.traceback cannot be used because it can happen that the calling script is NOT part of the traceback (yes, had that happen while testing using assert)
function Change:validateProperties()
    if type(self.property) ~= "string" then
        self:addError("Change ERROR: 'property' expects a string")
    end

    if type(self.property) == "string" and string.len(self.property) == 0 then
        self:addError("Change ERROR: 'property' cannot be an empty string")
    end

    if type(self.value) == "function" then
        self:addError("Change ERROR: 'value' cannot be a function")
    end

    if type(self.section) ~= "string" then
        self:addError("Change ERROR: 'section' expects a string")
    end

    if type(self.section) == "string" and string.len(self.section) == 0 then
        self:addError("Change ERROR: 'section' cannot be an empty string")
    end
    
    if type(self.optional) ~= "boolean" and type(self.optional) ~= "nil" then
        self:addError("Change ERROR: 'optional' can only be nil or a boolean value")
        return
    end
end

function Change:addError(message)
    self.errors[#self.errors + 1] = message
end

function Change:isValid()
    return #self.errors == 0
end

function Change:isOptional()
    return self.optional
end

return Change
