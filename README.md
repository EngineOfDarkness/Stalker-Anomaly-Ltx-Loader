# Stalker-Anomaly-Ltx-Loader

A Lua based solution to change Stalker Anomaly LTX Files on the fly once the game starts.

This Library Collects changes from several 3rd party scriptfiles and applies them once on game start.

Protip: Use Mod Organizer 2 to install mods - if you use JSGME or Manual Installation, don't complain about the lenghty [Uninstall](#uninstall) process of this Library when it was in use. You have been warned.

**Note this is a Pre-Release Version, so things are subject to change until 1.0.0 is done and as such Semantic Versioning (important for Mod Developers only) does not apply yet - this Library is a proof of concept for now**

## Table of Contents

- [Who is this for](#who-is-this-for)
    - [Mod Users](#mod-users)
    - [Mod Developers](#mod-developers)
- [Savegame compatibility](#savegame-compatibility)
- [Requirements](#requirements)
    - [No other should overwrite `gamedata\configs\script.ltx`](#no-other-should-overwrite-gamedataconfigsscriptltx)
    - [LTX specific requirements](#ltx-specific-requirements)
- [How to use](#how-to-use)
    - [For Endusers](#for-endusers)
        - [Install](#install)
        - [Uninstall](#uninstall)
            - [JSGME or MO2](#jsgme-or-mo2)
            - [I installed everything manually](#i-installed-everything-manually)
    - [For Mod Developers](#for-mod-developers)
        - [Modify system.ltx specific properties](#modify-systemltx-specific-properties)
        - [Modify trader ltx specific properties](#modify-trader-ltx-specific-properties)
        - [API Documentation](#api-documentation)
            - [Change](#change)
            - [Changeset](#changeset)
        - [Useful Side-Effect for Modders - Autoload Fix for certain Callbacks](#useful-side-effect-for-modders---autoload-fix-for-certain-callbacks)
- [Roadmap](#roadmap)
- [Remove LTX Files](#remove-ltx-files)
    - [Mod Organizer](#mod-organizer)
    - [JSGME or "I installed everything manually"](#jsgme-or-i-installed-everything-manually)
- [How it works](#how-it-works)
- [Donations](#donations) 

## Who is this for

### Mod Users

As an End-User you only need this Library if a Mod you downloaded actually requires you to install it.

If you have no such mod installed, this Library does nothing and you dont need it.

### Mod Developers

Mod Developers who want to make changes to existing LTX files (vanilla or other mods) while being minimally invasive (so no more overwriting entire ltx files just to change a few properties) - thus improving mod cross-compatibility for mods that make use of this Library.

Currently works with LTX Files that are either registered through the system.ltx or on trader files

Mods that edit exactly the same properties of the same section still "conflict", albeit that here simply the last loaded mod wins (at least for now, see [Roadmap](/ROADMAP.md) )

But PLEASE do NOT use this Library to add new items (aka "sections" - for example weapons). Vanilla Anomaly already has this feature since at least 1.5.1

**The comment in vanilla file `configs\items\items\base.ltx` reads as follows:**

```
;; NOTICE FOR MODDERS ;;
; unless you need to edit already existing items, do NOT edit the "items_*" files but make a new one that defines your new items
; eg. "items_mymod.ltx"
; it will be automatically included and won't cause conflict with other mods that add/edit items
```

## Savegame compatibility

- A new Savegame may be required when installing - depends on what the Mods that make use of this Library do - please consult the Readmes of those or ask the Modauthor
- A new Savegame may be required when uninstalling - depends on what the Mods that make use of this Library do - please consult the Readmes of those or ask the Modauthor
 
This Library itself (without having any other Mods installed that make use of it) can be safely added / removed anytime (just follow the [Uninstall](#uninstall) instructions)

## Requirements

### No other should overwrite `gamedata\configs\script.ltx`

**The ONLY vanilla file that is being shipped / overriden is `gamedata\configs\script.ltx` - this simply has added ONE entry at the very beginning of `class_registrators` which is `autoloader.register`**

To my knowledge there is no addon for anomaly out there that touches this file (and is rarely touched itself), and there really is no need for any mod to do so currently. As such it is compatible with any other mod currently out there and will not conflict.

### LTX specific requirements

If you need to install a mod that touches the `system.ltx` or any other LTX (like for example `items\trade\trade_stalker_sidorovich.ltx`, then you need to install that mod BEFORE you start the game with this Library installed for the FIRST TIME.

This is ABSOLUTELY required because my Library "copies" the vanilla LTX in question to use as a clean base to apply the changes to.

If you made a mistake with this, do the following

- Remove the files based on the following pattern from your `gamedata\configs` directory
    - `*.backup.ltx`
    - `*.temp.ltx`
- Reinstall the LTX files from your mods
- Start the game again - the Library will now create `*.backup.ltx` and `*.temp.ltx` files based on your modded LTX files

## How to use

### For Endusers

#### Install

Simply install into the Anomaly folder (where the "gamedata" folder resides) like you are used to with any other mod.

Preferrably use JSGME or even better MO2 (Mod Organizer 2, at least Version 2.4 or upwards is required for proper Anomaly support from the get go).

#### Uninstall

##### JSGME or MO2

Deactivate the Library and then see [Remove LTX Files](#remove-ltx-files)

##### I installed everything manually

If you did the archaic "I installed everything manually" way to install mods, you need to at least remove the following files (or better yet, start fresh - I mean that's what you get by doing it manually when there are better ways like JSGME or even better MO2)

- Follow the instructions for your case in [Remove LTX Files](#remove-ltx-files)
- Remove `gamedata\configs\script.ltx` (this disables the autoloading and prevents it from recreating the system.ltx, technically you can stop here, unless you want to clean up properly)
- To clean up, remove the following scriptfiles (they will be doing pretty much nothing if you've done step 2 though) 
    - `gamedata\scripts\config\Change.lua`
    - `gamedata\scripts\config\Changeset.lua`
    - `gamedata\scripts\config\ChangesetLoader.lua`
    - `gamedata\scripts\config\ChangeWriter.lua`
    - `gamedata\scripts\config\File.lua`
    - `gamedata\scripts\config\FileLoader.lua`
    - `gamedata\scripts\config\Ini.lua`
    - `gamedata\scripts\autoloader.script`
    - `gamedata\scripts\ltx_autoload.script`
    - `gamedata\scripts\trader_autoload.script`

### For Mod Developers

Install the Library like you would any other Mod (follow the above instructions basically)

Notice the examples here are intentionally very verbose - you could just cram everything in the function into one line without using any variables, but that is not really good code (well at least if you try to make use of guidelines from e.g. "Clean Code: A Handbook of Agile Software Craftsmanship" to keep your code easy to read and maintain - hard to read / maintain code is not good code)

#### Modify system.ltx specific properties

1. Create a .script file, for example `authorname_modname_system_mod.script` - the filename needs to end on `_system_mod.script`
    - you can create as many different files (e.g. for organizational purposes) as you want
3. Import both `Change.lua` (see [Change](#change)) and `Changeset.lua` (see [Changeset](#changeset)) by using require inside the file you just created
```lua
local Change = require "gamedata\\scripts\\config\\Change"
local Changeset = require "gamedata\\scripts\\config\\Changeset"
```
2. Create a new function called `registerSystemLtxModifications` - this function has no parameters
3. You now need to create the changes you want to apply, say for example we want to change the `switch_distance` property of the `alife` section to `20` and we want to change the property `inv_weight` of the section `bolt` to `1`
    1. `local switchDistance = Change("alife", "switch_distance", 20)`
    2. `local boltWeight = Change("bolt", "inv_weight", 1)`
4. Now that you created the [Change](#change) "instances", you need to pass them to an instance of [Changeset](#changeset) and return said instance
    1. `return Changeset({switchDistance, boltWeight}, "My Changeset Name")`
6. Thats it, the changes will now be applied when you start the game. If you want to check if this file has been loaded you can take a look at the console / logfile - the loaded files (and errors, if there are any) will be shown.

The complete example for `authorname_modname_system_mod.script` would look like this 

```lua
local Change = require "gamedata\\scripts\\config\\Change"
local Changeset = require "gamedata\\scripts\\config\\Changeset"

function registerSystemLtxModifications()
	local switchDistance = Change("alife", "switch_distance", 20)
	local boltWeight = Change("bolt", "inv_weight", 1)
	
	return Changeset({switchDistance, boltWeight}, "My Changeset Name")
end
```

#### Modify trader ltx specific properties

1. Create a .script file, for example `authorname_modname_trader_mod.script` - the filename needs to end on `_trader_mod.script`
    - you can create as many different files (e.g. for organizational purposes) as you want
3. Import both `Change.lua` (see [Change](#change)) and `Changeset.lua` (see [Changeset](#changeset)) by using require inside the file you just created
```lua
local Change = require "gamedata\\scripts\\config\\Change"
local Changeset = require "gamedata\\scripts\\config\\Changeset"
```
2. Create a new function called `registerTraderLtxModifications` - this function has no parameters
3. You now need to create the changes you want to apply, say for example we want to make Sidorovich sell the Version 2 and 3.1 PDA at the start of the game but not V1
    1. `local pdaV1 = Change("supplies_1", "device_pda_1", nil)`
    2. `local pdaV2 = Change("supplies_1", "device_pda_2", "1, 1")`
    3. `local pdaV3 = Change("supplies_1", "device_pda_3", "1, 1")`
4. Now that you created the [Change](#change) "instances", you need to pass them to an instance of [Changeset](#changeset) with the optional last parameter pointing to the trader file and return said instance.
    1. `return Changeset({pdaV1, pdaV2, pdaV3}, "My Changeset Name", "items\\trade\\trade_stalker_sidorovich.ltx")`
6. Thats it, the changes will now be applied when you start a new game (for existing games this only updates when the Trader restocks). If you want to check if this file has been loaded you can take a look at the console / logfile - the loaded files (and errors, if there are any) will be shown.

The complete example for `authorname_modname_trader_mod.script` would look like this 

```lua
local Change = require "gamedata\\scripts\\config\\Change"
local Changeset = require "gamedata\\scripts\\config\\Changeset"

function registerTraderLtxModifications()
	local pdaV1 = Change("supplies_1", "device_pda_1", nil)
	local pdaV2 = Change("supplies_1", "device_pda_2", "1, 1")
	local pdaV3 = Change("supplies_1", "device_pda_3", "1, 1")
	
	return Changeset({pdaV1, pdaV2, pdaV3}, "My Changeset Name", "items\\trade\\trade_stalker_sidorovich.ltx")
end
```

But what if you want to change a file under `configs\scripts\` instead? Well simple

```lua
local Change = require "gamedata\\scripts\\config\\Change"
local Changeset = require "gamedata\\scripts\\config\\Changeset"

function registerTraderLtxModifications()
	local someChange = Change("logic@bar_barman", "trade", "items\\trade\\some_file.ltx") --  if you "trade" with barman he would have no items, because that trade file does not exist in this example
	
	return Changeset({someChange}, "My Changeset Name", "scripts\\bar\\bar_barman.ltx")
end
```

#### API Documentation

##### Change

This "class" takes three required parameters

1. `section` (type: `string`)
2. `property` (type: `string`)
3. `value` (type: any except `function`)
    - this means you cannot pass a function itself, but you can pass a string like `some_scriptname.someScriptFunction` (as used by vanilla anomaly in some instances, e.g. for custom item functors etc.)
    - if you pass `nil` then the property will be removed, pass an empty string if you want the property to be empty.
    - **Handle removal with extra care, the inheriting behaviour of sections (e.g. `[myitem]:parent`) cannot be used at this point, because the `system.ltx` has already been processed, so if you remove a required property the game crashes even if the property is defined in the "parent" section**

##### Changeset

This "class" takes two required parameters and one optional one

1. `changes` (type: `table`, required)
    - this should contain a table with one or more [Change](#change) instances
2. `changesetName` (type: `string`, required)
    - a name that describes the changeset - will currently only be used in logs, but is still required. Try to keep this unique (e.g. something like "Authorname - Modname" or something like that
3. `ltx` (type: `string`, optional)
    - if not given then the changes will be done on the system.ltx (so if you want to make changes that are contained within the system.ltx then this can be kept empty)
    - if given, the changes will be done on the specified ltx file, example `items\\trade\\trade_stalker_sidorovich.ltx`

#### Useful Side-Effect for Modders - Autoload Fix for certain Callbacks

As you may or may not know, Anomaly has a rudimentary way to "autoload" scriptfiles by adding a function called `on_game_start` to a custom script file and then using `RegisterScriptCallback` (see `axr_main.script` for available callbacks)

While this mostly works, it will NOT work for e.g. the `main_menu_on_init` callback.

Reason being that `on_game_start` does not get run when you startup the game itself, but when you start a **new game** OR **load a saved game**. At this point `main_menu_on_init` has already been fired and as such it is impossible to use this callback in the intended way in vanilla anomaly.

You can simply create a new file named something like `authorname_mymod_autoload.script` (the script just has to end on `_autoload.script` so you can name it however you want) and contain a function called `register`.

Inside the `register` function you can simply register the callback. For Example

`authorname_mymod_autoload.script`
```
function main_menu_on_init()
	printf("hello ui init") -- see console output
end

function register()
    RegisterScriptCallback("main_menu_on_init", main_menu_on_init)
end
```

The reason this works is because the `autoloader.script` included in `gamedata\configs\script.ltx` is being executed on game startup (see [How it works](#how-it-works) for details) and searches for scripts ending on `_autoload.script` to execute.

A proper fix to the callback System would need to be done in vanilla anomaly (that is not in the scope of this project), but at that point the way the callback system works should probably be refactored aswell.

What do I mean? For example if two Authors want to create NEW Callbacks for their Mods (so 3rd parties can extend their mods) those two Authors currently have to MANUALLY edit `axr_main.script` thus having a hard conflict (aka one of the two mod authors needs to maintain patches). This of course gets worse the more mod authors want to add their own callbacks.

## Roadmap

See [Roadmap](/ROADMAP.md)

## Remove LTX Files

In general, this mod creates

- Remove the files based on the following pattern from your `gamedata\configs` directory
    - `*.backup.ltx`
    - `*.temp.ltx`
- Reinstall the LTX files from your mods
- Start the game again - the Library will now create `*.backup.ltx` and `*.temp.ltx` files based on your modded LTX files

### Mod Organizer

The LTX files will be at the bottom of the load order as part of a mod called `Overwrite`.

If you know you have no manually added files, Overwrite should only contain files created by the Library - these can be safely deleted assuming you have no mods installed that make changes inside the files themselves

You can either double-click `Overwrite` to bring up a filelist and manually delete these files, or if you are SURE there are no mod files in there, simply delete the `Overwrite` mod.

There may be a third file (a cachefile) in there if you use the Anomaly debug mode which can be safely deleted aswell.

### JSGME or "I installed everything manually"

You need to manually go to your `gamedata\configs` directory and remove the LTX files from there.

- Remove the files based on the following pattern from your `gamedata\configs` directory
    1. `*.backup.ltx`
    2. `*.temp.ltx`
    3. Also delete the original file, e.g. if you delete `system.backup.ltx` and `system.temp.ltx` also delete `system.ltx`
- **Reinstall the LTX files (from other mods) you deleted them in step 3**

## How it works

Due to the additional file being "registered" in `gamedata\configs\script.ltx`  the function `register` in scriptfile `autoloader.script` is executed on game start (when entering the main menu, so before loading or starting any game)

The `autoloader.script` then searches for scripts named `*_autoload.script` and executes the `register` function inside them. Currently there are two autoloaders

- `ltx_autoload.script`
    - Autoloads all scriptfiles named `*_system_mod.script` and executes the function `registerSystemLtxModifications` inside them
- `trader_autoload.script`
    - Autoloads all scriptfiles named `*_trader_mod.script` and executes the function `registerTraderLtxModifications` inside them
    - Requires a [Changeset](#changeset) with the third parameter being defined
    
Both functions that are called need to return a [Changeset](#changeset), which itself contains at least one or more "instances" of [Change](#change).

Basically:
- [Changeset](#changeset) would be similar to a Collection
- [Change](#change) would be an Item in a Collection

Both autoloaders ensure that LTX files which are modified will be backed up - said backup will be called `*.backup.ltx`.

When the autoloaders apply the changes, the Backup will be copied to a new file called `*.temp.ltx` - this is the file the changes will be applied to.
This file will be recreated everytime you start the game (to ensure the Changes are always written to the last "known good" vanilla / modded LTX that was backed up)

When the [Changesets](#changeset) have been completely applied, the `*.temp.ltx` is saved and THEN will overwrite the original vanilla file.

Finally both autoloaders clear the ini cache and reload the system.ini

When you quit the game, the original LTX files will be restored from `*.backup.ltx` - the `*.temp.ltx` files remain as is (but get overwritten anyway on subsequent game starts)

## Donations

Please check my [Donations Repository](https://github.com/EngineOfDarkness/donations) for options to donate
