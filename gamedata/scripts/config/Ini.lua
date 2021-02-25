--[[

    Author: EngineOfDarkness

    This work is licensed under the GPL-3.0 License 

    --------------------------------------------

    I tried multiple solutions to ensure the system.ltx is almost always in a clean state:
    - deleting the UNPACKED system.ltx on game startup -> always crashes with missing sections - even if you do execute reload_ini_sys and clear_ini_cache
    - deleting the UNPACKED system.ltx on game quit via console command callback - DOESNT work reliably (if you startup game and immideatly quit it doesn't get deleted, however if you start a fresh game or a load a game and then quit it worked...)

    In both cases I made multiple different attempts (using luas own io class, using getFS, setting some variables to nil, used a custom sleep function incase gc still had to do some work, called gc, ... etc ...) all without it working properly

    So the only way to ensure that modifications get applied to a clean system.ltx is to

    - get the CURRENT system.ltx on startup and copy it somewhere else
    - then get the copy and overwrite the current system.ltx
        - this catches the case that the game crashes - I ALWAYS want a clean system.ltx to apply the modifications to
        - this is technically not neccessary on first start (since the current system.ltx is already the fresh one) but eh, not worth the additional code for now.
    - then have my library make its modifications
    - on game quit replace the modified system.ltx with the original one

    This ensures the system.ltx is always in it's clean "vanilla" state before it gets changed.

    The only thing this doesn't catch is if the game crashes AND someone then removes the mod - next game start the modded system.ltx will be loaded (but well the user can just delete the system.ltx to fall back to the vanilla one, as described in the readme)

--]]

local Ini   = {}
Ini.__index = Ini

local function construct(_, originalName, copyName)
    local newIni = {}
    setmetatable(newIni, Ini)

    newIni.originalName     = originalName or "system.ltx"
    newIni.copyName         = copyName or "original_system.ltx"
    newIni.fileSystem       = getFS()
    newIni.gameConfigPath   = newIni.fileSystem:update_path("$game_config$", "")
    newIni.originalPath     = newIni.gameConfigPath .. newIni.originalName
    newIni.copyPath         = newIni.gameConfigPath .. newIni.copyName
    newIni.requestedChanges = {}

    return newIni
end

setmetatable(Ini, {__call = construct})

function Ini:reloadSystemIni()
    printf("LTX-LIBRARY: Reloading and Clearing ini cache")
    reload_ini_sys()
    clear_ini_cache(ini_sys)
end

function Ini:commitSystemLtxChanges()
    local iniFileEx = ini_file_ex(self.originalName, true)

    for _, requestedChange in ipairs(self.requestedChanges) do
        local method    = requestedChange.method
        local vars      = requestedChange.vars

        iniFileEx[method](iniFileEx, unpack(vars))
    end

    printf("LTX-LIBRARY: Saving %s", self.originalName)
    iniFileEx:save()

    iniFileEx               = nil
    self.requestedChanges   = {}
end

-- stores the original "system.ltx" as it was on start of the game
function Ini:storeOriginalSystemLtx()
    -- check if there is no copy currently
    if lfs.attributes(self.copyPath) == nil then
        printf("LTX-LIBRARY: Stored a copy of the original '%s' named '%s'", self.originalPath, self.copyPath)

        self.fileSystem:file_copy(self.originalPath, self.copyPath)

        return true
    end

    printe("LTX-LIBRARY: The original %s has already been created!", self.originalName)
    return false 
end

-- restores the original "system.ltx" that should have been stored using storeOriginalSystemLtx
function Ini:restoreOriginalSystemLtx()
    -- check if there is copy that can be restored
    if lfs.attributes(self.copyPath) ~= nil then
        printf("LTX-LIBRARY: Restored the original '%s' from '%s'", self.originalPath, self.copyPath)

        self.fileSystem:file_copy(self.copyPath, self.originalPath)
        -- yes we have to do an empty write here, otherwise "quitting" without loading or starting a new game will not restore the original ini (original in terms of values, not "looks")
        self:commitSystemLtxChanges()
        self.reloadSystemIni()

        return true
    end

    printe("LTX-LIBRARY: ERROR: Nothing to restore, did you execute storeOriginalSystemLtx() beforehand?")
    return false
end

-- the change will be cached and actually written in commitSystemLtxChanges
function Ini:write_value(section, property, value)
    self.requestedChanges[#self.requestedChanges + 1] = {method = "w_value", vars = {section, property, value}}
end

-- the change will be cached and actually written in commitSystemLtxChanges
function Ini:remove_line(section, property)
    self.requestedChanges[#self.requestedChanges + 1] = {method = "remove_line", vars = {section, property}}
end

return Ini