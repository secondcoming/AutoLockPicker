/*
	AutoLockPicker
	by second_coming (http://epochmod.com/forum/index.php?/user/16619-second-coming/) with help from SpiRe
	
	Allow players to have a chance to lock pick any vehicle or locked door (also a chance to eloctrocute on failed unlocking!)
	
	Initial Script Code: Stealthstick's "Explosive-To-Vehicle" Script
	Electrocution effect: http://www.altisliferpg.com/topic/224-effects-on-marijuana-use/

	v1.2 Swapped to cursortarget instead of the nearest item to get around putting the AutoLockPicker onto the wrong item
		Added variables for the materials required
		Added EnergyRequired
		Added AllowLockPicksNear to stop multiple locks being placed together
		
	*/	

// ======================================================================================================================================================================================
// User configurable Variables
// ======================================================================================================================================================================================

// Which locks can be opened
LockpickLandVehicles 					= true;						// All land vehicles (cars, vans, trucks etc)  	::: acceptable values true or false
LockpickAir 						= true; 					// Helis and jets  								::: acceptable values true or false
LockpickShip 						= true;						// Boats, jetskis and submarines  				::: acceptable values true or false
LockpickEpochDoors 					= true;						// Epoch build-able doors  						::: acceptable values true or false

// Chance to succeed or be electrocuted
SuccessChanceVehicles					= 20;						// (Between 1-100) % Chance to successfully pick the lock
SuccessChanceEpochDoors					= 20;						// (Between 1-100) % Chance to successfully pick the lock
ElectrocuteChance 					= 10;						// (Between 1-100) % Chance of electrocution on if the lock pick fails

// Damage Settings
InflictDamage 						= true;						// If true damage is added, if false just stun		
MinimumDamage 						= 50;						// (Between 1-100) min% of full health Damage to inflict must be less than MaximumDamage
MaximumDamage 						= 90;						// (Between 1-100) max% of full health Damage to inflict must be more than MinimumDamage
StunTime 						= 15;						// Time in seconds to stun the player on electrocution (if it doesn't kill them)

// Materials Required to Create AutoLockPicker
EnergyRequired						= 100;						// Amount of energy expended operating AutoLockPicker (0 for zero energy required)
MaterialRequired1					= 'CircuitParts';				// First material required to create AutoLockPicker (default is 'CircuitParts' or Electronic Component)
MaterialRequired1Count					= 1;
MaterialRequired2					= 'ItemCorrugated';				// Second material required to create AutoLockPicker (default is 'ItemCorrugated' or small metal parts)
MaterialRequired2Count					= 1;

// Usage Restrictions
AllowInSafeZone						= false;					// (Leave true if you don't use inSafezone) Allow use of AutoLockPicker in safezones 
																// (using the boolean variable inSafezone set here http://epochmod.com/forum/index.php?/topic/32555-extended-safezone-script-working/)
_MinimumPlayers 					= 0;						// Number of players required online before the option to lock pick becomes available (set to 0 to always allow)
AllowLockPicksNear					= false;					// (Leave true for no restriction) selecting false will make the script check if one has been placed within 5m of the player

// ======================================================================================================================================================================================
// End of User configurable Variables
// ======================================================================================================================================================================================

if(AllowInSafeZone && count playableUnits >= _MinimumPlayers) then
{
	SafeToALP = true;
}
else
{
	if(!inSafezone && count playableUnits >= _MinimumPlayers) then
	{
		SafeToALP = true;
	}
	else
	{
		SafeToALP = false;	
	};
};

LockPickableItems = [];

if(LockpickLandVehicles) then
{
	LockPickableItems = LockPickableItems + ["LandVehicle"];
};

if(LockpickAir) then
{
	LockPickableItems = LockPickableItems + ["Air"];
};

if(LockpickShip) then
{
	LockPickableItems = LockPickableItems + ["Ship"];
};

if(LockpickEpochDoors) then
{
	LockPickableItems = LockPickableItems + ["CinderWallGarage_EPOCH","WoodLargeWallDoorL_EPOCH","WoodLargeWallDoor_EPOCH"];
};



AutoLockPicker_MatsCheck =
{
	_charge1 = _this select 0;
	_charge2 = _this select 1;
	_unit = _this select 2;
	_hasIt1 = _charge1 in (magazines _unit);
	_hasIt1Count = {_x == _charge1} count magazines player;
	
	
	_hasIt2 = _charge2 in (magazines _unit);	
	_hasIt2Count = {_x == _charge2} count magazines player;
	_hasEnough = false;
	
	if(_hasIt1Count >= MaterialRequired1Count && _hasIt2Count >= MaterialRequired2Count) then
	{
		_hasEnough = true;
	};
	
	_hasEnergy = false;
	if(EnergyRequired == 0 || EPOCH_playerEnergy - EnergyRequired >= 0) then
	{		
		_hasEnergy = true;
	};
	
	_CanPlace = false;
	_nearALP = nearestObjects [_unit,["Land_PortableLongRangeRadio_F"],5];
	if(AllowLockPicksNear || (count _nearALP == 0 && !AllowLockPicksNear)) then
	{
		_CanPlace = true;	
	};
	
	

	_target = cursorTarget;
	_LockPickable = false;
	if ((typeOf cursorTarget) in LockPickableItems) then
	{
		_LockPickable = true;
	}
	else
	{
		
	    if  (_target isKindOf "LandVehicle" && LockpickLandVehicles) then
	    { 
			_LockPickable = true;
		};
	    if  (_target isKindOf "Air" && LockpickAir) then
	    { 
			_LockPickable = true;
		};	
	    if  (_target isKindOf "Ship" && LockpickShip) then
	    { 
			_LockPickable = true;
		};			
	};
	
	//hint format ["Target: %1 Lockpickable: %2 Locked: %3 Distance: %4",(typeOf cursorTarget),_LockPickable,locked cursorTarget,_unit distance cursorTarget];
	_nearVehs = false;
	if (_LockPickable && _unit distance _target < 5 && (locked _target == 2 || locked _target == -1) ) then
	{
		_nearVehs = true;
	};
	
	_return = (_hasEnough && _nearVehs && alive _unit && SafeToALP && _hasEnergy && _CanPlace);
	_return
};

AutoLockPicker_Activate =
{
	_array = _this select 3;
	_unit = _array select 0;
	_lockpicks = _unit getVariable ["lockpicks",[]];
	{
		if(alive _x && SafeToALP) then
		{
			_nearVehicle = (nearestObjects [_x,LockPickableItems,5]) select 0;
			if ((typeOf _nearVehicle) in ["CinderWallGarage_EPOCH","WoodLargeWallDoorL_EPOCH","WoodLargeWallDoor_EPOCH"]) then
			{
				SuccessChance = SuccessChanceEpochDoors;
			}
			else
			{
				SuccessChance = SuccessChanceVehicles;
			};
			
			// Chance to unlock
			_chance = Ceil random 100;			
			if(_chance <= SuccessChance) then
			{			
				// Unlock the door or vehicle							
				deleteVehicle _x;

				ALPUNLOCK = [_nearVehicle];
				uiSleep 3;
				publicVariableServer "ALPUNLOCK";
				uiSleep 1;
				
				if ((typeOf _nearVehicle) in ["CinderWallGarage_EPOCH","WoodLargeWallDoorL_EPOCH","WoodLargeWallDoor_EPOCH"]) then
				{
					hint "The AutoLockPicker worked! Opening door";
					_nearVehicle animate ['open_left', 1];
					_nearVehicle animate ['open_right', 1];
					_nearVehicle animate ['Open_Door', 1];
				}
				else
				{
					hint "The AutoLockPicker worked! Unlocking Vehicle";			
				}
			}
			else
			{
				_chance2 = Ceil random 100;
				if(_chance2 <= ElectrocuteChance) then
				{
					// Chance of electrocution
					_DamagetoInflict = (Ceil random (MaximumDamage - MinimumDamage))/100;					
					_damage = Damage player;
					_damage = _damage + (MinimumDamage/100) + _DamagetoInflict;
					playSound "shocker";
					if(_damage > 1 && InflictDamage) then
					{
						hint "The AutoLockPicker malfunctioned and electrocuted you";

						// Activate ppEffects
						"chromAberration" ppEffectEnable true;
						"radialBlur" ppEffectEnable true;
						enableCamShake true;

						// 5secs of effects
						for "_i" from 0 to 4 do
						{
							"chromAberration" ppEffectAdjust [random 0.25,random 0.25,true];
							"chromAberration" ppEffectCommit 1;   
							"radialBlur" ppEffectAdjust  [random 0.02,random 0.02,0.15,0.15];
							"radialBlur" ppEffectCommit 1;
							addcamShake[random 3, 1, random 3];
							uiSleep 1;
						};

						//Stop effects
						"chromAberration" ppEffectAdjust [0,0,true];
						"chromAberration" ppEffectCommit 5;
						"radialBlur" ppEffectAdjust  [0,0,0,0];
						"radialBlur" ppEffectCommit 5;
						uiSleep 6;

						//Deactivate ppEffects
						"chromAberration" ppEffectEnable false;
						"radialBlur" ppEffectEnable false;
						resetCamShake;
							
						
						player setDamage 1;
					}
					else
					{
						hint "The AutoLockPicker malfunctioned and gave you an electric shock";												
						
						if(InflictDamage) then 
						{
							player setDamage _damage;
						};
												
						player playMove "amovpknlmstpsraswrfldnon";

						// Activate ppEffects
						"chromAberration" ppEffectEnable true;
						"radialBlur" ppEffectEnable true;
						enableCamShake true;

						uiSleep 1;
						
						// Stop the player from moving while shocked
						player enablesimulation false;
						
						// StunTime seconds of effects
						for "_i" from 0 to StunTime do
						{
							"chromAberration" ppEffectAdjust [random 0.25,random 0.25,true];
							"chromAberration" ppEffectCommit 1;   
							"radialBlur" ppEffectAdjust  [random 0.02,random 0.02,0.15,0.15];
							"radialBlur" ppEffectCommit 1;
							addcamShake[random 3, 1, random 3];
							uiSleep 1;
						};

						player enablesimulation true;
						
						//Stop effects
						"chromAberration" ppEffectAdjust [0,0,true];
						"chromAberration" ppEffectCommit 5;
						"radialBlur" ppEffectAdjust  [0,0,0,0];
						"radialBlur" ppEffectCommit 5;
						uiSleep 6;

						//Deactivate ppEffects
						"chromAberration" ppEffectEnable false;
						"radialBlur" ppEffectEnable false;
						resetCamShake;
	
					};					
					deleteVehicle _x;
				}
				else
				{
					hint "The AutoLockPicker failed to unlock the door, try again";
					deleteVehicle _x;
				}
			};
		};
	} forEach _lockpicks;
	_unit setVariable ["lockpicks",[]];
};

AutoLockPicker_UnitCheck =
{
	private "_return";
	_unit = _this select 0;
	_lockpicks = _unit getVariable ["lockpicks",[]]; 
	if(count _lockpicks > 0) then
	{
		_return = true;
	}
	else
	{
		_return = false;
	};
	
	_return
};

AutoLockPicker_AttachALP =
{
	_array = _this select 3;
	_charge = _array select 0;
	_unit = _array select 1;
	private "_class";
	
	for "_i" from 1 to MaterialRequired1Count step 1 do 
	{
		_unit removemagazine MaterialRequired1;
		uiSleep 0.1;
	}; 
	for "_i" from 1 to MaterialRequired2Count step 1 do 
	{
		_unit removemagazine MaterialRequired2;
		uiSleep 0.1;
	}; 	

	EPOCH_playerEnergy = EPOCH_playerEnergy - EnergyRequired;
	_unit playMove "AinvPercMstpSnonWnonDnon_Putdown_AmovPercMstpSnonWnonDnon";
	
	switch _charge do
	{
		case "Land_PortableLongRangeRadio_F":
		{
			_class = "Land_PortableLongRangeRadio_F";
		};
	};
	
	_nearVehicle = (nearestObjects [_unit,LockPickableItems,5]) select 0;
	_autolockpick = _class createVehicle [0,0,0];
	_autolockpick attachTo [_unit,[0,0,0],"leftHand"];
	_random0 = random 180;
	_random1 = random 180;
	[_autolockpick,_random0,_random1] call BIS_fnc_SetPitchBank;
	[_autolockpick,_nearVehicle,_unit,_random0,_random1] spawn
	{		
		_autolockpick = _this select 0;
		_nearVehicle = _this select 1;
		_unit = _this select 2;
		_random0 = _this select 3;
		_random1 = _this select 4;
		
		uiSleep 1.5;
		_autolockpick attachTo [_nearVehicle, [0,0,0.2]];
		[_autolockpick,_random0,_random1] call BIS_fnc_SetPitchBank;
		_unit setVariable ["lockpicks",(_unit getVariable ["lockpicks",[]]) + [_autolockpick]];

	};
};


AutoLockPicker_Actions =
{
	private ["_unit"];
	_unit = _this select 0;
	_unit addAction ["<t color=""#0099FF"">" +"Attach AutoLockPicker", AutoLockPicker_AttachALP, ["Land_PortableLongRangeRadio_F",_unit], 1, true, true, "","[MaterialRequired1,MaterialRequired2,_target] call AutoLockPicker_MatsCheck"];
	_unit addAction ["<t color=""#3D993D"">" +"Activate AutoLockPicker", AutoLockPicker_Activate, [_unit], 1, true, true, "","[_target] call AutoLockPicker_UnitCheck"];
};

//removeAllActions player;
//=======================
[player] call AutoLockPicker_Actions;
