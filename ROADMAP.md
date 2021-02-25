# Roadmap

## 1.0.0

### Planned

 - Very rudimentary load order system (not dependency management!) so modders can specify in which order their mods should be applied given that other mods exist
 - Ability to create an Changeset from Files directly (e.g. from LTX files the mod scriptfile supplies) so there is less code (creating Change instances) to work with for people who are not comfortable with (even the little) code that is currently required for this Library.
 
## Future

Note just because something nice is here, does not mean it might be possible since a lot of this depends on which capabilities the game itself exposes

 - Advanced API to modify values - e.g. instead of plainly overwriting a property value, give the possibility to do simply modifications, e.g.
   - `inv_weight (+-)10` (adds/removes 10 to the current inv_weight of the section)
   - perhaps special handling for properties that can take multiple values, e.g. `ammo_class`. Like having "+some_ammo_type" add another ammo type to the comma separated list would be nice
	 - Currently you have to specify everything since it always writes the complete value, so in the `ammo_class` case you would have to first load the `ammo_class` property of a section and store it into some value, to which you add your new ammotype and THEN add the result of that operation as a `ltx_change`
	 - This is already possible if you first read the vanilla value, just not fire and forget but requires a few lines of code in your scriptfile
 - more advanced load order system (basically a dependency system where mods can specify that they need other mods installed to work)
 - if Anomalies Version of Xray supports it: Modify the System.ltx in memory only (makes the current "copying the system.ltx" workaround obsolete)
 - integration with the Mod Manager if it makes sense (perhaps to enable / disable mods in game?) - thats a very big "perhaps" however - might not really be feasible
 - Somehow prevent loading savegames if a mod deems itself "not compatible" with existing saves? Requires changes to the Changeset script for mod authors to specify this
	- Somehow check if a savegame contains mods that deemded itself not compatible with existing saves (to prevent the game crashing)? Not sure if even possible, probably not
 
## Ideas not for this mod

 - Enable this for more files than just LTX Files - e.g. modifying existing xml files (ui & text). Perhaps even script files (however in the case of scriptfiles the best that could be done would be "append" or "prepend" to the file, could perhaps be used to modify local variables and local functions to some extent) - however at that point it would really require in-memory editing so this wouldn't cause chaos with loose file mods. However these would be separate projects to be honest


