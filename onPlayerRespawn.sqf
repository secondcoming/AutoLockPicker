if (!isDedicated and hasInterface) then 
{
	waitUntil {alive vehicle player};	
	waitUntil {typeOF player != "VirtualMan_EPOCH"};			
	
	// Activate AutoLockPicker
	[] execVM "custom\AutoLockPicker.sqf";	
	systemchat("AutoLockPicker activated...");

};