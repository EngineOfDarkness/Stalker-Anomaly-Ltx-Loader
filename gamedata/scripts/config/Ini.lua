--[[

    Author: EngineOfDarkness

    This work is licensed under the GPL-3.0 License 

    --------------------------------------------
    
    TODO needs better docs

    I tried multiple solutions to ensure the system.ltx is almost always in a clean state:
    - deleting the UNPACKED system.ltx on game startup -> always crashes with missing sections - even if you do execute reload_ini_sys and clear_ini_cache
    - deleting the UNPACKED system.ltx on game quit via console command callback - DOESNT work reliably (if you startup game and immideatly quit it doesn't get deleted, however if you start a fresh game or a load a game and then quit it worked...)

    In both cases I made multiple different attempts (using luas own io class, using getFS, setting some variables to nil, used a custom sleep function incase gc still had to do some work, called gc, ... etc ...) all without it working properly

    So the only way to ensure that modifications get applied to a clean system.ltx is to

    - get the CURRENT system.ltx on startup and backup it somewhere else
    - then get the backup and overwrite the current system.ltx
        - this catches the case that the game crashes - I ALWAYS want a clean system.ltx to apply the modifications to
        - this is technically not neccessary on first start (since the current system.ltx is already the fresh one) but eh, not worth the additional code for now.
    - then have my library make its modifications
    - on game quit replace the modified system.ltx with the original one

    This ensures the system.ltx is always in it's clean "vanilla" state before it gets changed.

    The only thing this doesn't catch is if the game crashes AND someone then removes the mod - next game start the modded system.ltx will be loaded (but well the user can just delete the system.ltx to fall back to the vanilla one, as described in the readme)

--]]

local File = require "gamedata\\scripts\\config\\File"

local Ini   = {}
Ini.__index = Ini

local function construct(_, originalName, backupName, tempName)
    local newIni = {}
    setmetatable(newIni, Ini)
    
    originalName = originalName or "system.ltx"
    
    local fileInstance      = File(originalName)
    local fileLessExtension = fileInstance:removeExtension()

    newIni.originalName     = originalName
    newIni.backupName       = backupName or fileLessExtension .. ".backup"
    newIni.tempName         = tempName or fileLessExtension .. ".temp"
    newIni.fileSystem       = getFS()
    newIni.gameConfigPath   = newIni.fileSystem:update_path("$game_config$", "")
    newIni.originalPath     = newIni.gameConfigPath .. newIni.originalName
    newIni.backupPath       = newIni.gameConfigPath .. newIni.backupName
    newIni.tempPath         = newIni.gameConfigPath .. newIni.tempName
    newIni.requestedChanges = {}

    return newIni
end

setmetatable(Ini, {__call = construct})

function Ini:reloadSystemIni()
    printf("LTX-LIBRARY: Reloading and Clearing ini cache")
    reload_ini_sys()
    clear_ini_cache(ini_sys)
end

function Ini:commitChanges()
    self:createTemporaryFromBackup() -- we'll write to a temp file and copy that over the original, because this for some reason causes less issues
    
    local iniFileEx = ini_file_ex(self.tempName, true)

    for _, requestedChange in ipairs(self.requestedChanges) do
        local method    = requestedChange.method
        local vars      = requestedChange.vars

        iniFileEx[method](iniFileEx, unpack(vars))
    end

    printf("LTX-LIBRARY: Saving %s", self.tempPath)
    iniFileEx:save()

    iniFileEx               = nil
    self.requestedChanges   = {}
    
    self:overwriteOriginalWithTemporary()
end

function Ini:createTemporaryFromBackup()
    printf("LTX-LIBRARY: Create temporary file '%s' from '%s'", self.tempPath, self.backupPath)
    self.fileSystem:file_copy(self.backupPath, self.tempPath)
end

function Ini:overwriteOriginalWithTemporary()
    printf("LTX-LIBRARY: Overwrite original file '%s' with '%s'", self.originalPath, self.tempPath)
    self.fileSystem:file_copy(self.tempPath, self.originalPath)
end

-- stores the original file as it was on start of the game
function Ini:storeBackup()
    -- check if there is no backup currently
    if lfs.attributes(self.backupPath) == nil then
        printf("LTX-LIBRARY: Stored a backup of the original '%s' named '%s'", self.originalPath, self.backupPath)

        self.fileSystem:file_copy(self.originalPath, self.backupPath)

        return true
    end

    printe("LTX-LIBRARY: The backup for '%s' has already been created!", self.originalPath)
    return false 
end

-- restores the original file that should have been stored using storeBackup
function Ini:restoreFromBackup()
    -- check if there is backup that can be restored
    if lfs.attributes(self.backupPath) ~= nil then
        printf("LTX-LIBRARY: Restored the original '%s' from '%s'", self.originalPath, self.backupPath)

        self.fileSystem:file_copy(self.backupPath, self.originalPath)

        return true
    end

    printe("LTX-LIBRARY: ERROR: Nothing to restore, did you execute storeBackup() beforehand?")
    return false
end

-- the change will be cached and actually written in commitChanges
function Ini:write_value(section, property, value)
    self.requestedChanges[#self.requestedChanges + 1] = {method = "w_value", vars = {section, property, value}}
end

-- the change will be cached and actually written in commitChanges
function Ini:remove_line(section, property)
    self.requestedChanges[#self.requestedChanges + 1] = {method = "remove_line", vars = {section, property}}
end

return Ini
