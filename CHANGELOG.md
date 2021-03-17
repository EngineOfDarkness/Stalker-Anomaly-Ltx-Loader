# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

## [0.2.0] - 2021-03-17
### Added
- `gamedata\scripts\config\File.lua`
    - centralizes some file related functions (e.g. returning the filename without extension, or just the extension of a given filename)
- `gamedata\scripts\config\ChangeWriter.lua`
    - centralizes a method to write a given `Change.lua` instance to a given `Ini.lua` instance
    - Used by `ltx_autoload.script` and `trader_autoload.script`
- `gamedata\scripts\config\FileLoader.lua`
    - class to load files based on the file both matching file pattern and containing the configured method
- `gamedata\scripts\autoloader.script`
    - uses `gamedata\scripts\config\FileLoader.lua` to autoload all files that end on `_autoload.script` and executes the function `register` on them
    - this scripts function `register` is called from `gamedata/configs/script.ltx`
- `gamedata\scripts\Changeset.lua`
    - Has a new parameter in its constructor `ltx` which is the ltx being worked on. If empty then system.ltx is assumed, otherwise you can use this to e.g. work on traderfiles
- `gamedata/scripts/trader_autoload.script`
    - Autoloads scriptfiles that are used to create `Changeset.lua` instaces meant to edit trader files

### Changed
- Updated the `README.md`
- Updated the `readme.txt` based on the `README.md`
- `gamedata/scripts/ltx_autoload.script`
    - Renamed from `ltx_loader.script` to `ltx_autoload.script`
    - automatically called by `gamedata\scripts\autoloader.script`
    - this scripts function `register` is NO LONGER called from `gamedata/configs/script.ltx`
    - Refactored usage of `ChangesetLoader.lua` - the constructor now contains the autoloaded filePattern and the expected method name
    - changed calls to `Ini.lua` functions inside `ltx_loader.script` to the corresponding new ones
    - some code refactored into `ChangeWriter.lua` for reusability
    - filePattern changed from `*_ltx.script` to `*_system_mod.script`
    - methodName changed from `registerLtxModifications` to `registerSystemLtxModifications`
- `gamedata\scripts\config\Change.lua`
    - Removed ini specific section checks in (now part of `gamedata\scripts\config\Changeset.lua`)
- `gamedata\scripts\config\Changeset.lua` 
    - validates the changes (checks if the section that is about to be changed is existing), because the `Changeset.lua` knows about the ltx that it has to work on
- `gamedata\scripts\config\ChangesetLoader.lua`
    - removed occurences of `goto continue` - was leftover from earlier experimentation
    - removed Methods `loadCallbackFiles` and `getFileExtension` (refactored into new class `FileLoader.lua`)
    - imported `FileLoader.lua` which will be used to load files that are used for Changesets
- `Ini.lua`
    - Rename `commitSystemLtxChanges` to `commitChanges`
    - Rename `storeOriginalSystemLtx` to `storeBackup`
    - Rename `restoreOriginalSystemLtx` to `restoreFromBackup`
    - Change the way overwriting LTX works - now the changes are written to a temporary file first and after writing all changes, the temporary file will be copied over the original one. This seems to workaround some weird issues related to files not getting "detected" as changed by the game (notably the trader files required some wonky workarounds in order for them to be detected)

## [0.1.0] - 2021-03-07
### Added
 - `CHANGELOG.md` to document changes in this project
 - `LICENSE` - GPL-3.0 License 
 - `README.md` to document the library
 - `readme.txt` to document the library - shipped with the release archives (has an information text at the top to visit the github based readme instead because of the markdown formatting)
 - `ROADMAP.md` to define future features that may or may not be worked on
 - `gamedata\scripts\config\Change.lua` to handle a change of a mod (which value of which property in which section to modify) - one or more (inside a table) are expected by `Changeset.lua`
 - `gamedata\scripts\config\Changeset.lua` to handle multiple changes - this is what the `ChangesetLoader.lua` expects as return value from a mods `registerLtxModifications` function
 - `gamedata\scripts\config\ChangesetLoader.lua` used by the `ltx_loader.script` to load the Changeset from `*_ltx.script` files
 - `gamedata\scripts\config\Ini.lua` handles system.ltx related functions (e.g. preloading the changes, apply the changes to the system.ltx, reload the system.ltx and cache)
 - `gamedata\scripts\ltx_loader.script` the main scriptfile, uses the `ChangesetLoader.lua` and `Ini.lua` to load and apply ltx changes from mods
 - `gamedata\configs\script.ltx` to register the function `ltx_loader.register` which gets run on game start (upon entering the main menu)
 - `preview.png` a preview image for sites like moddb
