if(isServer) then 
{
	"UDUNLOCK" addPublicVariableEventHandler {_this select 1 call unlock_vehicle};

	unlock_vehicle = {	private["_veh"];
		_veh = _this select 0;
		_veh setVehicleLock "UNLOCKED";
		_veh call EPOCH_server_save_vehicle;
	};
};