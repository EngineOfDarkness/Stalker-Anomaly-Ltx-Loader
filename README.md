# Stalker-Anomaly-Ltx-Loader 0.2.1

A Lua based solution to change Stalker Anomaly LTX Files on the fly once the game starts.

This Library Collects changes from several 3rd party scriptfiles and applies them once on game start.

**Note this is a Pre-Release Version, so things are subject to change until 1.0.0 is done and as such Semantic Versioning (important for Mod Developers only) does not apply yet - this Library is a proof of concept for now**

If you have a problem, please copy the output of your Log and create an [Issue](https://github.com/EngineOfDarkness/Stalker-Anomaly-Ltx-Loader/issues)

## Table of Contents

- [Who is this for](#who-is-this-for)
    - [Mod Users](#mod-users)
    - [Mod Developers](#mod-developers)
- [Savegame compatibility](#savegame-compatibility)
- [Requirements](#requirements)
    - [Mod Managers](#mod-managers)
    - [No other should overwrite `gamedata\configs\script.ltx`](#no-other-should-overwrite-gamedataconfigsscriptltx)
    - [LTX specific requirements](#ltx-specific-requirements)
- [How to use](#how-to-use)
    - [For Endusers](#for-endusers)
        - [Install](#install)
        - [Updating other Mods that don't use the Library](#updating-other-mods-that-dont-use-the-library)
        - [Uninstall](#uninstall)
            - [JSGME or MO2](#jsgme-or-mo2)
            - [Manual Installation](#manual-installation)
        - [Remove LTX Files](#remove-ltx-files)
            - [Mod Organizer](#mod-organizer)
            - [JSGME or Manual Installation](#jsgme-or-manual-installation)
    - [For Mod Developers](#for-mod-developers)
        - [Modify system.ltx specific properties](#modify-systemltx-specific-properties)
        - [Modify trader ltx specific properties](#modify-trader-ltx-specific-properties)
        - [API Documentation](#api-documentation)
            - [Change](#change)
            - [Changeset](#changeset)
        - [Useful Side-Effect for Modders - Autoload Fix for certain Callbacks](#useful-side-effect-for-modders---autoload-fix-for-certain-callbacks)
- [Roadmap](#roadmap)
- [Changelog](#changelog)
- [How it works](#how-it-works)
- [Donations](#donations) 

## <a name="who-is-this-for"></a>Who is this for

### <a name="mod-users"></a>Mod Users

As an End-User you only need this Library if a Mod you downloaded actually requires you to install it.

If you have no such mod installed, this Library does nothing and you dont need it.

### <a name="mod-developers"></a>Mod Developers

Mod Developers who want to make changes to existing LTX files (vanilla or other mods) while being minimally invasive (so no more overwriting entire ltx files just to change a few properties) - thus improving mod cross-compatibility for mods that make use of this Library.

Currently works with LTX Files that are either registered through the system.ltx or on trader files

Mods that edit exactly the same properties of the same section still "conflict", albeit that here simply the last loaded mod wins (at least for now, see [Roadmap](/ROADMAP.md) )

But PLEASE do NOT use this Library to add new items (aka "sections" - for example weapons). Vanilla Anomaly already has this feature since at least 1.5.1 (at least for items)

**The comment in vanilla file `configs\items\items\base.ltx` reads as follows:**

```
;; NOTICE FOR MODDERS ;;
; unless you need to edit already existing items, do NOT edit the "items_*" files but make a new one that defines your new items
; eg. "items_mymod.ltx"
; it will be automatically included and won't cause conflict with other mods that add/edit items
```

## <a name="savegame-compatibility"></a>Savegame compatibility

- A new Savegame may be required when installing - depends on what the Mods that make use of this Library do - please consult the Readmes of those or ask the Modauthor
- A new Savegame may be required when uninstalling - depends on what the Mods that make use of this Library do - please consult the Readmes of those or ask the Modauthor
 
This Library itself (without having any other Mods installed that make use of it) can be safely added / removed anytime (just follow the [Uninstall](#uninstall) instructions)

## <a name="requirements"></a>Requirements

In general, when I refer to something like "manual way" or "manual installation" I mean that you copied files manually into the Anomaly Directory without using JSGME or MO2.

### <a name="mod-managers"></a>Mod Managers

While you can generally use this Library with Manual Installations or JSGME, I do not recommend it due to the complex [Uninstall](#uninstall) or Troubleshooting process that it may require from you, the user.

Mod Organizer 2 (Version 2.4 and up) is currently the easiest way to handle this (given that you only install Mods via MO2 and not manually aswell)

### <a name="no-other-should-overwrite-gamedataconfigsscriptltx"></a>No other Mod should overwrite `gamedata\configs\script.ltx`

**The ONLY vanilla file that is being shipped / overriden is `gamedata\configs\script.ltx` - this simply has added ONE entry at the very beginning of `class_registrators` which is `autoloader.register`**

To my knowledge there is no addon for anomaly out there that touches this file (and is rarely touched itself), and there really is no need for any mod to do so currently. As such it is compatible with any other mod currently out there and will not conflict.

### <a name="ltx-specific-requirements"></a>LTX specific requirements

If you need to install, remove or update a mod that touches LTX files, you are required to do the following if you have started the Game with my Library and Mods that use my Library at least once

- Stop the game
- Follow [Remove LTX Files](#remove-ltx-files) for your use-case (MO2, JSGME or Manual Installation)
- Install / Remove / Update your mods in question
- Start the game again - the Library will now create `*.backup` and `*.temp` files based on your Installed / Removed / Updated LTX Files

This is required because my Library "copies" the vanilla / modded LTX in question on first startup to `*.backup` - this backup file will be used on subsequent starts as a baseline for the modifications.

The reason that the Library doesn't copy the the vanilla / modded LTX each gamestart is that at when you quit the game it writes back the vanilla / modded LTX from `*.backup`. However the problem arises when the game crashes - now the vanilla / modded LTX is not the "original" anymore but the one modified by the Library, which is why `*.backup` is used as a basefile.

## <a name="how-to-use"></a>How to use

### <a name="for-endusers"></a>For Endusers

#### <a name="install"></a>Install

Either use a Mod Manager like JSGME or MO2 or install into the Anomaly folder (where the "gamedata" folder resides) like any other addon.

#### <a name="updating-other-mods-that-dont-use-the-library"></a>Updating other Mods that don't use the Library

If you have other Mods installed that do not make use of this Library, it is required that you follow [LTX specific requirements](#ltx-specific-requirements) when you update those.

This is to ensure that the Modifications this Library makes, is made on the correct ltx file.

#### <a name="uninstall"></a>Uninstall

##### <a name="jsgme-or-mo2"></a>JSGME or MO2

Deactivate the Library in your Mod Manager and then follow [Remove LTX Files](#remove-ltx-files) for your use-case

##### <a name="manual-installation"></a>Manual Installation

If you installed mods the manual way, you need to either remove the following files or start with a fresh gamedata folder - whatever you feel more comfortable with.

1. Remove
    - `gamedata\configs\script.ltx`
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
2. Follow the instructions for your case in [Remove LTX Files](#remove-ltx-files)
   
#### <a name="remove-ltx-files"></a>Remove LTX Files

##### <a name="mod-organizer"></a>Mod Organizer

The LTX files will be at the bottom of the load order as part of a mod called `Overwrite`.

In general among the vanilla file that was modified, there will be two more files with the following pattern (`*` would be the vanilla filename)

- `*.backup`
- `*.temp`

If you have not installed mods manually into the Anomaly directory

- Simply delete the `Overwrite` mod.

If you have installed mods manually into the Anomaly directory

- double-click `Overwrite` to bring up a filelist and manually delete all files with the pattern mentioned above
- I also recomment deleting the vanilla files you modded in `Overwrite` and then reinstall the mods you installed manually afterwards

There may be a third file (a cachefile) in there if you use the Anomaly debug mode which can be safely deleted aswell.

##### <a name="jsgme-or-manual-installation"></a>JSGME or Manual Installation

You need to manually go to your `gamedata\configs` directory and remove the files from there.

- JSGME: Disable all Mods
- Remove the files based on the following pattern from your `gamedata\configs` directory and all available subdirectories
    1. `*.backup`
    2. `*.temp`
    3. Also delete the original file, e.g. if you delete `system.backup` and `system.temp` also delete `system.ltx`
- JSGME: Re-Enable the Mods
- Reinstall Mods you added manually to the Anomaly Directory

### <a name="for-mod-developers"></a>For Mod Developers

Install the Library like you would any other Mod (follow [Install](#install) basically)

Notice the examples here are intentionally very verbose - you could just cram everything in the function into one line without using any variables, but that is not really good code (well at least if you try to make use of guidelines from e.g. "Clean Code: A Handbook of Agile Software Craftsmanship" to keep your code easy to read and maintain - hard to read / maintain code is not good code)

If you have problems, the first thing you can do is check the Console (or the logfile in the directory `appdata\logs` if you quit the game already) - the Library generates Messages that start with `LTX-LIBRARY`.

#### <a name="modify-systemltx-specific-properties"></a>Modify system.ltx specific properties

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
    1. `return Changeset({switchDistance, boltWeight}, "My Unique Changeset Name")`
6. Thats it, the changes will now be applied when you start the game. If you want to check if this file has been loaded you can take a look at the console / logfile - the loaded files (and errors, if there are any) will be shown.

The complete example for `authorname_modname_system_mod.script` would look like this 

```lua
local Change = require "gamedata\\scripts\\config\\Change"
local Changeset = require "gamedata\\scripts\\config\\Changeset"

function registerSystemLtxModifications()
	local switchDistance = Change("alife", "switch_distance", 20)
	local boltWeight = Change("bolt", "inv_weight", 1)
	
	return Changeset({switchDistance, boltWeight}, "My Unique Changeset Name")
end
```

#### <a name="modify-trader-ltx-specific-properties"></a>Modify trader ltx specific properties

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
    1. `return Changeset({pdaV1, pdaV2, pdaV3}, "My Unique Trader Changeset Name", "items\\trade\\trade_stalker_sidorovich.ltx")`
6. Thats it, the changes will now be applied when you start a new game (for existing games this only updates when the Trader restocks). If you want to check if this file has been loaded you can take a look at the console / logfile - the loaded files (and errors, if there are any) will be shown.

The complete example for `authorname_modname_trader_mod.script` would look like this 

```lua
local Change = require "gamedata\\scripts\\config\\Change"
local Changeset = require "gamedata\\scripts\\config\\Changeset"

function registerTraderLtxModifications()
	local pdaV1 = Change("supplies_1", "device_pda_1", nil)
	local pdaV2 = Change("supplies_1", "device_pda_2", "1, 1")
	local pdaV3 = Change("supplies_1", "device_pda_3", "1, 1")
	
	return Changeset({pdaV1, pdaV2, pdaV3}, "My Unique Trader Changeset Name", "items\\trade\\trade_stalker_sidorovich.ltx")
end
```

But what if you want to change a file under `configs\scripts\` instead? Well simple

```lua
local Change = require "gamedata\\scripts\\config\\Change"
local Changeset = require "gamedata\\scripts\\config\\Changeset"

function registerTraderLtxModifications()
	local someChange = Change("logic@bar_barman", "trade", "items\\trade\\some_file.ltx") --  if you "trade" with barman he would have no items, because that trade file does not exist in this example
	
	return Changeset({someChange}, "My Unique Trader Changeset Name", "scripts\\bar\\bar_barman.ltx")
end
```

#### <a name="api-documentation"></a>API Documentation

##### <a name="change"></a>Change

This "class" takes three required parameters

1. `section` (type: `string`)
2. `property` (type: `string`)
3. `value` (type: any except `function`)
    - this means you cannot pass a function itself, but you can pass a string like `some_scriptname.someScriptFunction` (as used by vanilla anomaly in some instances, e.g. for custom item functors etc.)
    - if you pass `nil` then the property will be removed, pass an empty string if you want the property to be empty.
    - **Handle removal with extra care, the inheriting behaviour of sections (e.g. `[myitem]:parent`) cannot be used at this point, because the `system.ltx` has already been processed, so if you remove a required property the game crashes even if the property is defined in the "parent" section**

##### <a name="changeset"></a>Changeset

This "class" takes two required parameters and one optional one

1. `changes` (type: `table`, required)
    - this should contain a table with one or more [Change](#change) instances
2. `changesetName` (type: `string`, required)
    - a name that describes the changeset - will currently only be used in logs, but is still required. Try to keep this unique (e.g. something like "Authorname - Modname - XYZ" or something like that)
3. `ltx` (type: `string`, optional)
    - if not given then the changes will be done on the system.ltx (so if you want to make changes that are contained within the system.ltx then this can be kept empty)
    - if given, the changes will be done on the specified ltx file, example `items\\trade\\trade_stalker_sidorovich.ltx`

#### <a name="useful-side-effect-for-modders---autoload-fix-for-certain-callbacks"></a>Useful Side-Effect for Modders - Autoload Fix for certain Callbacks

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

What do I mean by refactoring? For example if two Authors want to create NEW Callbacks for their Mods (so 3rd parties can extend their mods through the use of callbacks) those two Authors currently have to MANUALLY edit `axr_main.script` thus having a hard conflict (one of the two mod authors needs to maintain compatibility patches for this file). This of course gets worse the more mod authors want to add their own callbacks.

## <a name="changelog"></a>Changelog

See [Changelog here](https://github.com/EngineOfDarkness/Stalker-Anomaly-Ltx-Loader/blob/main/CHANGELOG.md)

## <a name="roadmap"></a>Roadmap

See [Roadmap](/ROADMAP.md)

## <a name="how-it-works"></a>How it works

Due to the additional file being "registered" in `gamedata\configs\script.ltx`  the function `register` in scriptfile `autoloader.script` is executed on game start (when entering the main menu, so before loading or starting any game)

The `autoloader.script` then searches for scripts named `*_autoload.script` and executes the `register` function inside them. Currently there are two autoloaders

- `ltx_autoload.script`
    - Autoloads all scriptfiles named `*_system_mod.script` and executes the function `registerSystemLtxModifications` inside them
    - Currently Ignores the 3rd parameter (which LTX to modify) of any [Changeset](#changeset)
- `trader_autoload.script`
    - Autoloads all scriptfiles named `*_trader_mod.script` and executes the function `registerTraderLtxModifications` inside them
    - Requires a [Changeset](#changeset) with the third parameter being defined
    
Both functions that are called need to return a [Changeset](#changeset), which itself contains at least one or more "instances" of [Change](#change).

Basically:
- [Changeset](#changeset) would be similar to a Collection
- [Change](#change) would be an Item in a Collection

Both autoloaders ensure that LTX files which are modified will be backed up - said backup will be called `*.backup`.

When the autoloaders apply the changes, the Backup will be copied to a new file called `*.temp` - this is the file the changes will be applied to.
This file will be recreated everytime you start the game (to ensure the Changes are always written to the last "known good" vanilla / modded LTX that was backed up)

When the [Changesets](#changeset) have been completely applied, the `*.temp` is saved and THEN will overwrite the original vanilla file.

Finally both autoloaders clear the ini cache and reload the system.ini

When you quit the game, the original LTX files will be restored from `*.backup` - the `*.temp` files remain as is (but get overwritten anyway on subsequent game starts)

## <a name="donations"></a>Donations

Please check my [Donations Repository](https://github.com/EngineOfDarkness/donations) for options to donate
