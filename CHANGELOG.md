# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added
- `FileLoader.lua` - class to load files based on the file both matching file pattern and containing the configured method
- `autoloader.script` - uses `FileLoader.lua` to autoload all files that end on `_autoload.script` and executes the function `register` on them
    - this scripts function `register` is now called from `gamedata/configs/script.ltx`

### Changed
- Renamed `ltx_loader.script` to `ltx_autoload.script` to make use of the newly introduced `autoloader.script`
    - this scripts function `register` is no longer called from `gamedata/configs/script.ltx`
- Refactored `ChangesetLoader.lua`
    - removed occurences of `goto continue` - was leftover from earlier experimentation
    - removed Methods `loadCallbackFiles` and `getFileExtension` (refactored into new class `FileLoader.lua`)
    - imported `FileLoader.lua` which will be used to load files that are used for Changesets
- Refactored usage of `ChangesetLoader.lua` in `ltx_loader.script` - the constructor now contains the properties that are used (instead of hiding them in the `ChangesetLoader.lua` as fallback
- Refactored some method names in `gamedata\scripts\config\Ini.lua`
    - `commitSystemLtxChanges` to `commitChanges`
    - `storeOriginalSystemLtx` to `storeOriginal`
    - `restoreOriginalSystemLtx` to `restoreOriginal`
- Changed calls to `Ini()` functions inside `ltx_loader.script` to the corresponding new ones

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
