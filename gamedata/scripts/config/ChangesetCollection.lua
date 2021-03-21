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

local function construct(_, changesets)
    local newChangesetCollection = {}
    setmetatable(newChangesetCollection, ChangesetCollection)

    newChangesetCollection.changesets = changesets
    
    return newChangesetCollection
end

setmetatable(ChangesetCollection, {__call = construct})

function ChangesetCollection:validate()
    assert(type(self.changesets) == "table", "ChangesetCollection can only work with tables")
    
    for _, changeset in ipairs(self.changesets) do
        assert(changeset and type(changeset.changes) == "table", "ChangesetCollection can only contain changesets")
    end
end

function ChangesetCollection:extractChangesets(extractFunction)
    assert(type(extractFunction) == "function", "extractChangesets requires a function, example: 'extractChangesets(function(extractedChangeset) ... end)'")
    
    for _, changeset in ipairs(self.changesets) do
        extractFunction(changeset)
    end
end

return ChangesetCollection
