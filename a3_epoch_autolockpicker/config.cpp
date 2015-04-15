class CfgPatches {
	class alp {
		units[] = {};
		weapons[] = {};
		UD_Version = 0.1;
		requiredVersion = 1.36;
		requiredAddons[] = {/*"a3_epoch_server"*/};
	};
};
class CfgFunctions {
	class alp {
		class main {
			file = "a3_epoch_autolockpicker";
			class alpinit {
				postInit = 1;
			};
		};
};
};
