[] ExecVM "\a3_epoch_autolockpicker\fn_vehicleunlock.sqf";
diag_log "ALP# AutoLockPicker function ready";

if !(isNil "ALP") exitWith { false };
ALP = true;
diag_log 'ALP: Checking for mission file';
if (isClass (missionConfigFile >> 'Cfgmod')) then {
	if (getNumber (missionConfigFile >> 'Cfgmod' >> 'override') == 1) then {
		call compile preProcessFileLineNumbers (getText(missionConfigFile >> 'Cfgmod' >> 'file'));
	};
};
diag_log 'Continuing to load Epoch';
call compile preprocessFileLineNumbers '\x\addons\a3_epoch_code\init\fn_init.sqf';