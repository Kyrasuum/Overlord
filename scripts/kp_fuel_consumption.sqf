/*
kp_fuel_consumption.sqf
Author: Wyqer
Website: www.killahpotatoes.de
Date: 2017-02-02

Description:
This script handles the fuel consumption of vehicles, so that refueling will be necessary more often.

Parameters:
_this select 0 - OBJECT - Player
_this select 1 - OBJECT - Vehicle
_this select 2 - NUMBER - Minutes till fuel empty when driving
_this select 3 - NUMBER - Minutes till fuel empty in neutral

Method:
execVM

Example for init.sqf:
if (!isDedicated) then {
	player addEventHandler ["GetInMan", {[_this select 0, _this select 2, 60, 180] execVM "scripts\kp_fuel_consumption.sqf";}];
};
*/
KP_Fuel =  {
	_this spawn {
		if (isNil "kp_fuel_consumption_vehicles") then {
			kp_fuel_consumption_vehicles = [];
		};

		if (!((_this select 1) in kp_fuel_consumption_vehicles)) then {
			kp_fuel_consumption_vehicles pushBack (_this select 1);
			while {local (_this select 1)} do {
				if (isEngineOn (_this select 1)) then {
					if (speed (_this select 1) > 5) then {
						(_this select 1) setFuel (fuel (_this select 1) - (1 / ((_this select 2) * 60)));
					} else {
						(_this select 1) setFuel (fuel (_this select 1) - (1 / ((_this select 3) * 60)));
					};
				};
				sleep 1;
			};
			kp_fuel_consumption_vehicles deleteAt (kp_fuel_consumption_vehicles find (_this select 1));
		};
	};
};