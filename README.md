# AutoLockPicker
Unlock script for vehicles and locked doors for Arma 3 Epoch

# =======================
# AutoLockPicker is here!
# =======================

What is it? I hear you ask.

It's a lock picking script which can unlock locked doors and locked vehicles.

Stop before you go any further, if you are using the standard antihack I'm afraid this won't work for you as it requires the use of player addActions. I'm sure someone could modify this to work by adding actions to vehicles and doors instead though (which are allowed in the standard antihack).

Not using the standard antihack? Then you are good to go!

The script has a 20% chance to successfully unlock any locked door or vehicle and a 10% chance to electrocute the player causing between 50% and 90% overall damage and giving some funky sound and visual effects :)

It uses 1 x Electronic Components and 1 x Small Salvage Metal to be able to activate the AutoLockPicker (which are consumed in the attempt to unlock).

If you are carrying both items and are next to a door or vehicle you get a scroll wheel action to attach the AutoLockPicker. Then use the mousewheel again to select to activate the AutoLockPicker.


# =======================
Credits:
# =======================

The starting point for this script was StealthSticks ExplosivestoVehicle script (http://www.armaholic.com/page.php?id=21652) 
Electrocution visual after effects are from here http://www.altisliferpg.com/topic/224-effects-on-marijuana-use/

I have also created a modified version of Leighams ud.pbo (http://epochmod.com/forum/index.php?/topic/32432-release-actionmenu-working-with-stock-ah/) to handle the unlocking of vehicles as it has to be done server side otherwise they just relock within a few seconds.
(If you already use ud.pbo this will not clash with it)



# =======================
How do I Install this badboy?
# =======================

Step 1: Add the required Battleye Filters:
# =======================
Add the following to publicvariable.txt
!="AUTOLOCKPICK"


Add the following to scripts.txt:
 
line 1 (BIS_fnc_) !"call BIS_fnc_SetPitchBank"

Around line 5 (attachTo) !"_autolockpick attachTo [_unit,[0,0,0]," !"_autolockpick attachTo [_nearVehicle, [0,0,0.2]];"

Around line 21 (exec) execVM !"AutoLockPicker.sqf"

Around line 19 (playableunits) !="if(AllowInSafeZone && count playableUnits >= _MinimumPlayers) then"
 
Around line 47 (setDamage) !="player setDamage1;"
 


Step 2 Installation:
# =======================

Place AutoLockPicker.sqf in your mission file and add a call for it to your mission init file (I initialise it from onPlayerRespawn.sqf):

Here is the onPlayerRespawn.sqf I use: (if you don't already have an onPlayerRespawn.sqf just copy the one supplied into your mission folder)


if (!isDedicated and hasInterface) then 
{
	waitUntil {alive vehicle player};	
	waitUntil {typeOF player != "VirtualMan_EPOCH"};			

	// Activate AutoLockPicker
	[] execVM "custom\AutoLockPicker.sqf";	
	systemchat("AutoLockPicker activated...");
};

Edit your description.ext and add the following:
class CfgSounds
{
	class shocker
	{
		name = "electrocute";
		// filename, volume, pitch
		sound[] = {"sounds\electrocute.ogg", 1, 1};
		titles[] = {};
	};		
};

Then create a folder called sounds in your mission folder and copy electrocute.ogg inside it (from the download)

Step Install the Server side addon:
# =======================
Place a3_epoch_autolockpicker.pbo in @epochhive/addons


Step 4 All done!
# =======================
Yay!
