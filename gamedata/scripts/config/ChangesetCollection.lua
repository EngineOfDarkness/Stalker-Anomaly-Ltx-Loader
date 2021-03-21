--[[

    Author: EngineOfDarkness

    This work is licensed under the GPL-3.0 License 

    --------------------------------------------

    Creates a new ChangesetCollection "object" which can hold multiple Changesets (if you want to return multiple Changesets from one autoloaded scriptfile for example)

    See README.md for detailed examples
    
    -- first require the module
    local ChangesetCollection = require "gamedata\\scripts\\config\\ChangesetCollection"
    
    -- then create an instance and pass the Changeset Instances to it
    local changesetCollectionInstance = ChangesetCollection({changeset1, changeset2, ...})

--]]

local ChangesetCollection     = {}
ChangesetCollection.__index   = ChangesetCollection

--- private methods

local function validate(self)
    if type(self.changesets) ~= "table" then
        self:addError("ChangesetCollection can only work with tables")
        return
    end
    
    for index, changeset in ipairs(self.changesets) do
        if type(changeset) ~= "table" or type(changeset.changes) ~= "table" then
            self:addError(string.format("Index %s in the ChangesetCollection is not a Changeset", index))
        end
    end
end

local function construct(_, changesets)
    local newChangesetCollection = {}
    setmetatable(newChangesetCollection, ChangesetCollection)

    newChangesetCollection.changesets   = changesets
    newChangesetCollection.errors       = {}
    
    validate(newChangesetCollection)
    
    return newChangesetCollection
end

--- public methods

setmetatable(ChangesetCollection, {__call = construct})

function ChangesetCollection:extractChangesets(extractFunction)
    assert(type(extractFunction) == "function", "extractChangesets requires a function, example: 'extractChangesets(function(extractedChangeset) ... end)'")
    
    for _, changeset in ipairs(self.changesets) do
        extractFunction(changeset)
    end
end

function ChangesetCollection:addError(message)
    self.errors[#self.errors + 1] = message
end

function ChangesetCollection:isValid()
    return #self.errors == 0
end

return ChangesetCollection
