--[[

    Author: EngineOfDarkness

    This work is licensed under the GPL-3.0 License 

    --------------------------------------------
    
    Centralize code used in multiple loaders to write a change to a certain ini
    
    Usage Example:
    
    -- first require the module
    local ChangeWriter = require "gamedata\\scripts\\config\\ChangeWriter"
    
    -- then create an instance
    local changeWriterInstance = ChangeWriter()
    
    -- lastly execute a function, e.g. writeChangeToIni
    changeWriterInstance:writeChangeToIni(aChangeInstance, aIniInstance)
--]]

local ChangeWriter    = {}
ChangeWriter.__index  = ChangeWriter

local function construct(_)
    local newChangeWriter = {}
    setmetatable(newChangeWriter, ChangeWriter)

    return newChangeWriter
end

setmetatable(ChangeWriter, {__call = construct})

function ChangeWriter:writeChangeToIni(change, ini)
    local section   = change.section
    local property  = change.property
    local value     = change.value

    if value then
        printf(" > LTX-LIBRARY: Applying value '%s' to property '%s' of section '%s'", value, property, section)
        ini:write_value(section, property, value)
    else
        --note handle with extra care, the inheriting behaviour of sections cannot be used at this point, so if you remove a required property the game crashes
        printf(" > LTX-LIBRARY: Removing property '%s' of section '%s' because the value was set to nil", property, section)
        ini:remove_line(section, property)
    end
end

return ChangeWriter
