# Stalker-Anomaly-Ltx-Loader

A Lua based solution to change Stalker Anomaly LTX Files on the fly once the game starts.

This Library Collects changes from several 3rd party scriptfiles and applies them once on game start.

**Note this is a Pre-Release Version, so things are subject to change until 1.0.0 is done and as such Semantic Versioning (important for Mod Developers only) does not apply yet - this Library is a proof of concept for now**

This Readme is in Markdown format, please go visit the https://github.com/EngineOfDarkness/Stalker-Anomaly-Ltx-Loader/blob/main/README.md for proper formatting and to ensure the linked sections work

Things like the CHANGELOG, ROADMAP and LICENSE are not included in the "release" archive because Mod Managers like MO2 or JSGME will trigger "conflicts" when two mods have the same files (even though the files are unused by the game itself - e.g. if two mods have a "LICENSE" file they will show up as conflicts which is nonsense since the file is unused by Stalker Anomaly)

## Who is this for

### Mod Users

As an End-User you only need this Library if a Mod you downloaded actually requires you to install it.

If you have no such mod installed, this Library does nothing and you dont need it.

### Mod Developers

Mod Developers who want to make changes to existing LTX files (vanilla or other mods) while being minimally invasive (so no more overwriting entire ltx files just to change a few properties) - thus improving mod cross-compatibility for mods that make use of this Library.

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

**The ONLY vanilla file that is being shipped / overriden is `gamedata\configs\script.ltx` - this simply has added ONE entry at the very beginning of `class_registrators` which is `ltx_loader.register`**

To my knowledge there is no addon for anomaly out there that touches this file (and is rarely touched itself), and there really is no need for any mod to do so currently. As such it is compatible with any other mod currently out there and will not conflict.

### `system.ltx` specific requirements

If you need to install a mod that touches the `system.ltx`, then you need to install that mod BEFORE you start the game with this Library installed for the FIRST TIME.

This is ABSOLUTELY required because my Library "copies" the vanilla `system.ltx` to use as a clean base to apply the changes to.

If you made a mistake with this, simply remove the `original_system.ltx` from the gamedata\configs directory, add your modified `system.ltx` again and start the game again. My Library will now copy your "modded" `system.ltx` to `original_system.ltx` and use it as a base on subsequent starts of the game.

## How to use

### For Endusers

#### Install

Simply install into the Anomaly folder (where the "gamedata" folder resides) like you are used to with any other mod.

Preferrably use JSGME or even better MO2 (Mod Organizer 2, at least Version 2.4 or upwards is required for proper Anomaly support from the get go).

#### Uninstall

##### JSGME or MO2

Simply deactivate the Library and then see [Remove system.ltx](#remove-systemltx)

##### I installed everything manually

If you did the archaic "I installed everything manually" way to install mods, you need to at least remove the following files (or better yet, start fresh - I mean that's what you get by doing it manually when there are better ways like JSGME or even better MO2)

1. Follow the instructions for your case in [Remove system.ltx](#remove-systemltx)
2. Remove `gamedata\configs\script.ltx` (this disables the autoloading and prevents it from recreating the system.ltx, technically you can stop here, unless you want to clean up properly)
3. To clean up, remove the following scriptfiles (they will be doing pretty much nothing if you've done step 2 though) 
    1. `gamedata\scripts\config\Change.lua`
    1. `gamedata\scripts\config\Changeset.lua`
    3. `gamedata\scripts\config\ChangesetLoader.lua`
    4. `gamedata\scripts\config\Ini.lua`
    5. `gamedata\scripts\ltx_loader.script`

### For Mod Developers

Install the Library like you would any other Mod (follow the above instructions basically)

Then to make use of the Library:

1. Create a .script file, for example `authorname_modname_ltx.script` - the filename needs to end on `_ltx.script`
3. Import both `Change.lua` (see [Change](#change)) and `Changeset.lua` (see [Changeset](#changeset)) by using require inside the file you just created
```lua
local Change = require "gamedata\\scripts\\config\\Change"
local Changeset = require "gamedata\\scripts\\config\\Changeset"
```
2. Create a new function called `registerLtxModifications` - this function takes no parameters
3. You now need to create the changes you want to apply, say for example we want to change the `switch_distance` property of the `alife` section to `20` and we want to change the property `inv_weight` of the section `bolt` to `1`
    1. `local switchDistance = Change("alife", "switch_distance", 20)`
    2. `local boltWeight = Change("bolt", "inv_weight", 1)`
4. Now that you created the "instances", you need to pass them to an instance of Changeset and return said instance
    1. `return Changeset({switchDistance, boltWeight}, "My Changeset Name")`
6. Thats it, the changes will now be applied when you start the game. If you want to check this you can take a look at the console / logfile - the loaded files (and errors, if there are any) will be shown

The complete example for `authorname_modname_ltx.script` would look like this 

```lua
local Change = require "gamedata\\scripts\\config\\Change"
local Changeset = require "gamedata\\scripts\\config\\Changeset"

function registerLtxModifications()
	local switchDistance = Change("alife", "switch_distance", 20)
	local boltWeight = Change("bolt", "inv_weight", 1)
	
	return Changeset({switchDistance, boltWeight}, "My Changeset Name")
end
```

Notice the example here is intentionally very verbose - you could just cram everything in the function into one line without using any variables, but that is not really good code (well at least if you try to make use of guidelines from e.g. "Clean Code: A Handbook of Agile Software Craftsmanship" to keep your code easy to read and maintain - hard to read / maintain code is not good code)

Following is a quick documentation of the two important scripfiles that you actively need to use

#### Change

This "class" takes three required parameters

1. `section` (type: `string`)
2. `property` (type: `string`)
3. `value` (type: any except `function`)
    - this means you cannot pass a function itself, but you can pass a string like `some_scriptname.someScriptFunction` (as used by vanilla anomaly in some instances, e.g. for custom item functors etc.)
    - if you pass `nil` then the property will be removed, pass an empty string if you want the property to be empty.
    - **Handle removal with extra care, the inheriting behaviour of sections (e.g. `[myitem]:parent`) cannot be used at this point, because the `system.ltx` has already been processed, so if you remove a required property the game crashes even if the property is defined in the "parent" section**

#### Changeset

This "class" takes two required parameters

1. `changes` (type: `table`) - this should contain a table with one or more [Change](#change) instances
2. `changesetName` (type: `string`) - a name that describes the changeset - will currently only be used in logs, but is still required.

#### Useful Side-Effect for Modders - Autoload Fix for certain Callbacks

As you may or may not know, Anomaly has a rudimentary way to "autoload" scriptfiles by adding a function called `on_game_start` to a custom script file and then using `RegisterScriptCallback` (see `axr_main.script` for available callbacks)

While this mostly works, it will NOT work for e.g. the `main_menu_on_init` callback.

Reason being that `on_game_start` does not get run when you startup the game itself, but when you start a **new game** OR **load a saved game**. At this point `main_menu_on_init` has already been fired and as such it is impossible to use this callback in the intended way in vanilla anomaly.

You can simply add a `RegisterScriptCallback` inside the `registerLtxModifications` function you just made and use the `main_menu_on_init` callback that way.

Extending on the above example

```lua
local Change = require "gamedata\\scripts\\config\\Change"
local Changeset = require "gamedata\\scripts\\config\\Changeset"

function registerLtxModifications()
	RegisterScriptCallback("main_menu_on_init", main_menu_on_init)

	local switchDistance = Change("alife", "switch_distance", 20)
	local boltWeight = Change("bolt", "inv_weight", 1)
	
	return Changeset({switchDistance, boltWeight}, "My Changeset Name")
end

function main_menu_on_init()
	printf("hello ui init") -- see console output
end
```

The reason this works is because the `ltx_loader.script` gets included in `gamedata\configs\script.ltx` which basically is being executed on game startup, see [How it works](#how-it-works) for details.

A proper fix to the callback System would need to be done in vanilla anomaly (that is not in the scope of this project), but at that point the way the callback system works should probably be refactored aswell.

What do I mean? For example if two Authors want to create NEW Callbacks for their Mods (so 3rd parties can extend their mods) those two Authors currently have to MANUALLY edit `axr_main.script` thus having a hard conflict (aka one of the two mod authors needs to maintain patches). This of course gets worse the more mod authors want to add their own callbacks.

## Roadmap

See [Roadmap](/ROADMAP.md)

## Remove system.ltx

### Mod Organizer:

The `system.ltx` will be at the bottom of the load order as part of a mod called `Overwrite`. If you know you have no manually added files, Overwrite should only contain `system.ltx` and `original_system.ltx` - both of these can be safely deleted assuming you have no mods installed that make changes inside the `system.ltx`

You can either double-click `Overwrite` to bring up a filelist and manually delete these two files, or if you are SURE there are only these two files there, simply delete the `Overwrite` mod.

There may be a third file (a cachefile) in there if you use the Anomaly debug mode which can be safely deleted aswell.

**If you had mods installed that made changes in the `system.ltx` then please reinstall those afterwards**

### JSGME or "I installed everything manually":

You need to manually go to your gamedata\configs directory and remove the `system.ltx` and `original_system.ltx` from there.
 
**If you had mods installed that made changes in the `system.ltx` then please reinstall those afterwards**

## How it works

Due to the additional file being "registered" in `gamedata\configs\script.ltx`  the function `register` in scriptfile `ltx_loader.script` is executed on game start (when entering the main menu, so before loading or starting any game)

The first step is to create a copy of the ORIGINAL `system.ltx` - said copy will be called `original_system.ltx`.

The next step is to copy `original_system.ltx` to `system.ltx` - this is to ensure that all modifications that are done from the loader are always done on a "vanilla" `system.ltx` - this is because the `ltx_loader.script` writes the changes to disk. This is mostly done to catch an edge case (if the game crashes) so it is ensured that modifications are always made on a vanilla `system.ltx`

Once that is done, the `ltx_loader.script` basically execute all scriptfiles that end on `_ltx.script` and runs the function `registerLtxModifications` inside them.

Said function needs to return an "instance" of [Changeset](#changeset) which itself contains one or more "instances" of [Change](#change) 

Basically:
- [Changeset](#changeset) would be similar to a Collection
- [Change](#change) would be an Item in a Collection

`ltx_loader.script` thus having collected the Collections ([Changeset](#changeset)) of multiple mods, will then "write" the Item(s) [Change](#change) of each Collection to the `system.ltx` when the game is started.

Finally the vanilla functions to reload the now modified `system.ltx` aswell as cache cleaning are called.

When you quit the game, the original `system.ltx` will be restored from `original_system.ltx`

## Donations

Please check my [Donations Repository](https://github.com/EngineOfDarkness/donations) for options to donate
