//This file contains all flag actions for recruiting
RecRifle = { 
	if (side (_this select 1) == (Sides select 0)) then{
		if ([(Sides select 0)] call BIS_fnc_respawnTickets >= 1) then{
			_unit = group (_this select 1) createUnit [(SidesAgents select 0)select 0, position (_this select 1), [], 10, "FORM"]; 
			[_unit] join  group (_this select 1); 
			[(Sides select 0),-1] call BIS_fnc_respawnTickets;
		}else{
			hint "Not enough tickets to spawn more troops";
		};
	}else{
		if ([(Sides select 1)] call BIS_fnc_respawnTickets >= 1) then{
			_unit = group (_this select 1) createUnit [(SidesAgents select 1)select 0, position (_this select 1), [], 10, "FORM"]; 
			[_unit] join  group (_this select 1); 
			[(Sides select 1),-1] call BIS_fnc_respawnTickets;
		}else{
			hint "Not enough tickets to spawn more troops";
		};
	};
};
RecMedic = {
	if (side (_this select 1) == (Sides select 0)) then{
		if ([(Sides select 0)] call BIS_fnc_respawnTickets >= 1) then{
			_unit = group (_this select 1) createUnit [(SidesAgents select 0)select 1, position (_this select 1), [], 10, "FORM"]; 
			[_unit] join  group (_this select 1); 
			[(Sides select 0),-1] call BIS_fnc_respawnTickets;
		}else{
			hint "Not enough tickets to spawn more troops";
		};
	}else{
		if ([(Sides select 1)] call BIS_fnc_respawnTickets >= 1) then{
			_unit = group (_this select 1) createUnit [(SidesAgents select 1)select 1, position (_this select 1), [], 10, "FORM"]; 
			[_unit] join  group (_this select 1); 
			[(Sides select 1),-1] call BIS_fnc_respawnTickets;
		}else{
			hint "Not enough tickets to spawn more troops";
		};
	};
};
RecSmGun = {
	if (side (_this select 1) == (Sides select 0)) then{
		if ([(Sides select 0)] call BIS_fnc_respawnTickets >= 1) then{
			_unit = group (_this select 1) createUnit [(SidesAgents select 0)select 2, position (_this select 1), [], 10, "FORM"]; 
			[_unit] join  group (_this select 1); 
			[(Sides select 0),-1] call BIS_fnc_respawnTickets;
		}else{
			hint "Not enough tickets to spawn more troops";
		};
	}else{
		if ([(Sides select 1)] call BIS_fnc_respawnTickets >= 1) then{
			_unit = group (_this select 1) createUnit [(SidesAgents select 1)select 2, position (_this select 1), [], 10, "FORM"]; 
			[_unit] join  group (_this select 1); 
			[(Sides select 1),-1] call BIS_fnc_respawnTickets;
		}else{
			hint "Not enough tickets to spawn more troops";
		};
	};
};
RecMGun = {
	if (side (_this select 1) == (Sides select 0)) then{
		if ([(Sides select 0)] call BIS_fnc_respawnTickets >= 1) then{
			_unit = group (_this select 1) createUnit [(SidesAgents select 0)select 3, position (_this select 1), [], 10, "FORM"]; 
			[_unit] join  group (_this select 1); 
			[(Sides select 0),-1] call BIS_fnc_respawnTickets;
		}else{
			hint "Not enough tickets to spawn more troops";
		};
	}else{
		if ([(Sides select 1)] call BIS_fnc_respawnTickets >= 1) then{
			_unit = group (_this select 1) createUnit [(SidesAgents select 1)select 3, position (_this select 1), [], 10, "FORM"]; 
			[_unit] join  group (_this select 1); 
			[(Sides select 1),-1] call BIS_fnc_respawnTickets;
		}else{
			hint "Not enough tickets to spawn more troops";
		};
	};
};
RecAT = {
	if (side (_this select 1) == (Sides select 0)) then{
		if ([(Sides select 0)] call BIS_fnc_respawnTickets >= 1) then{
			_unit = group (_this select 1) createUnit [(SidesAgents select 0)select 4, position (_this select 1), [], 10, "FORM"]; 
			[_unit] join  group (_this select 1); 
			[(Sides select 0),-1] call BIS_fnc_respawnTickets;
		}else{
			hint "Not enough tickets to spawn more troops";
		};
	}else{
		if ([(Sides select 1)] call BIS_fnc_respawnTickets >= 1) then{
			_unit = group (_this select 1) createUnit [(SidesAgents select 1)select 4, position (_this select 1), [], 10, "FORM"]; 
			[_unit] join  group (_this select 1); 
			[(Sides select 1),-1] call BIS_fnc_respawnTickets;
		}else{
			hint "Not enough tickets to spawn more troops";
		};
	};
};
RecOfficer = {
	if (side (_this select 1) == (Sides select 0)) then{
		if ([(Sides select 0)] call BIS_fnc_respawnTickets >= 1) then{
			_unit = group (_this select 1) createUnit [(SidesAgents select 0)select 5, position (_this select 1), [], 10, "FORM"]; 
			[_unit] join  group (_this select 1); 
			[(Sides select 0),-1] call BIS_fnc_respawnTickets;
		}else{
			hint "Not enough tickets to spawn more troops";
		};
	}else{
		if ([(Sides select 1)] call BIS_fnc_respawnTickets >= 1) then{
			_unit = group (_this select 1) createUnit [(SidesAgents select 1)select 5, position (_this select 1), [], 10, "FORM"]; 
			[_unit] join  group (_this select 1); 
			[(Sides select 1),-1] call BIS_fnc_respawnTickets;
		}else{
			hint "Not enough tickets to spawn more troops";
		};
	};
};
RecEmptyLander = {
	_boat = "LIB_LCVP" createVehicle getMarkerPos "boatSpwn";  
	_boat setDir 313;  
	_boat setVehicleLock "UNLOCKED";
	_boat call BeachLand;
};
//note: the boat in lander has not been localized to each side
RecLander = { 
	if (side (_this select 1) == (Sides select 0)) then{
		_group = createGroup (Sides select 0);  

		_boat = "LIB_LCVP" createVehicle getMarkerPos "boatSpwn";  
		_boat setDir 313;  
		_boat setVehicleLock "UNLOCKED";

		if ([(Sides select 0)] call BIS_fnc_respawnTickets >= 1) then{
			createVehicleCrew _boat; 
			[(Sides select 0),-1] call BIS_fnc_respawnTickets;
		}else{
			hint "Not enough tickets to spawn more troops";
		};

		for [{_i=0;}, {_i<30;}, {_i=_i+1;}] do  
		{  
			if ([(Sides select 0)] call BIS_fnc_respawnTickets >= 1) then{
				_num = floor random 10; 
				if (_num <= 5) then { 
					_unit = _group createUnit [(SidesAgents select 0)select 0, getMarkerPos "boatSpwn", [], 10, "FORM"];
					_unit assignAsCargoIndex [_boat, i];  
					_unit moveInCargo _boat;
				}; 
				if (_num == 6) then { 
					_unit = _group createUnit [(SidesAgents select 0)select 1, getMarkerPos "boatSpwn", [], 10, "FORM"];
					_unit assignAsCargoIndex [_boat, i];  
					_unit moveInCargo _boat;
					[_unit, true] execVM "automedic.sqf";
				}; 
				if (_num == 7) then { 
					_unit = _group createUnit [(SidesAgents select 0)select 2, getMarkerPos "boatSpwn", [], 10, "FORM"];
					_unit assignAsCargoIndex [_boat, i];  
					_unit moveInCargo _boat;
				}; 
				if (_num == 8) then { 
					_unit = _group createUnit [(SidesAgents select 0)select 3, getMarkerPos "boatSpwn", [], 10, "FORM"];
					_unit assignAsCargoIndex [_boat, i];  
					_unit moveInCargo _boat;
				}; 
				if (_num == 9) then { 
					_unit = _group createUnit [(SidesAgents select 0)select 4, getMarkerPos "boatSpwn", [], 10, "FORM"]; 
					_unit assignAsCargoIndex [_boat, i];  
					_unit moveInCargo _boat;
				}; 
				if (_num == 10) then { 
					_unit = _group createUnit [(SidesAgents select 0)select 5, getMarkerPos "boatSpwn", [], 10, "FORM"];
					_unit assignAsCargoIndex [_boat, i];  
					_unit moveInCargo _boat;
				}; 
				[(Sides select 0),-1] call BIS_fnc_respawnTickets;
			}else{
				hint "Not enough tickets to spawn more troops";
			};   
		};  
		crew _boat join _group;  
		_this select 1 hcSetGroup [_group];

		_boat call BeachLand;
	};
	}else{
		_group = createGroup (Sides select 1);  

		_boat = "LIB_LCVP" createVehicle getMarkerPos "boatSpwn";  
		_boat setDir 313;  
		_boat setVehicleLock "UNLOCKED";

		if ([(Sides select 1)] call BIS_fnc_respawnTickets >= 1) then{
			createVehicleCrew _boat; 
			[(Sides select 1),-1] call BIS_fnc_respawnTickets;
		}else{
			hint "Not enough tickets to spawn more troops";
		};

		for [{_i=0;}, {_i<30;}, {_i=_i+1;}] do  
		{  
			if ([(Sides select 1)] call BIS_fnc_respawnTickets >= 1) then{
				_num = floor random 10; 
				if (_num <= 5) then { 
					_unit = _group createUnit [(SidesAgents select 1)select 0, getMarkerPos "boatSpwn", [], 10, "FORM"];
					_unit assignAsCargoIndex [_boat, i];  
					_unit moveInCargo _boat;
				}; 
				if (_num == 6) then { 
					_unit = _group createUnit [(SidesAgents select 1)select 1, getMarkerPos "boatSpwn", [], 10, "FORM"];
					_unit assignAsCargoIndex [_boat, i];  
					_unit moveInCargo _boat;
					[_unit, true] execVM "automedic.sqf";
				}; 
				if (_num == 7) then { 
					_unit = _group createUnit [(SidesAgents select 1)select 2, getMarkerPos "boatSpwn", [], 10, "FORM"];
					_unit assignAsCargoIndex [_boat, i];  
					_unit moveInCargo _boat;
				}; 
				if (_num == 8) then { 
					_unit = _group createUnit [(SidesAgents select 1)select 3, getMarkerPos "boatSpwn", [], 10, "FORM"];
					_unit assignAsCargoIndex [_boat, i];  
					_unit moveInCargo _boat;
				}; 
				if (_num == 9) then { 
					_unit = _group createUnit [(SidesAgents select 1)select 4, getMarkerPos "boatSpwn", [], 10, "FORM"]; 
					_unit assignAsCargoIndex [_boat, i];  
					_unit moveInCargo _boat;
				}; 
				if (_num == 10) then { 
					_unit = _group createUnit [(SidesAgents select 1)select 5, getMarkerPos "boatSpwn", [], 10, "FORM"];
					_unit assignAsCargoIndex [_boat, i];  
					_unit moveInCargo _boat;
				}; 
				[(Sides select 1),-1] call BIS_fnc_respawnTickets;
			}else{
				hint "Not enough tickets to spawn more troops";
			};   
		};  
		crew _boat join _group;  
		_this select 1 hcSetGroup [_group];

		_boat call BeachLand;
	};  
};

BeachLand = {
	while {alive _this} do {
		if (((getPosATL _this) select 2) - ((getPosASL _this) select 2) < 5) then {    
			vehicle _this animate ["ramp_rotate", 1];
			// if (alive _this) then      
			// {      
			// 	{   
			// 		moveOut _x;  
			// 	} forEach crew vehicle _x;
			// 	deleteVehicle vehicle _x
			// };    
		}else{
			vehicle _this animate ["ramp_rotate", 0]; 
		};
		sleep 10
	};
};



SandSherm = {
	_tnk = _this select 0;
	
	_bag = "Land_BagFence_Short_F" createVehicle (position _tnk); 
	_bag attachTo [_tnk,[0.2,2.6,-1.5]]; _bag setVectorUp [0,-1,1]; 

	_bag1 = "Land_BagFence_End_F" createVehicle (position _tnk); 
	_bag1 attachTo [_tnk,[0.1,2.0,-1.1]]; _bag1 setDir 270;
	_bag2 = "Land_BagFence_End_F" createVehicle (position _tnk); 
	_bag2 attachTo [_tnk,[0.1,1.5,-1.0]]; _bag2 setDir 270; 

	_bag3 = "Land_BagFence_End_F" createVehicle (position _tnk); 
	_bag3 attachTo [_tnk,[-0.9,1.7,-1.1]]; _bag3 setDir 270; 
	_bag4 = "Land_BagFence_End_F" createVehicle (position _tnk); 
	_bag4 attachTo [_tnk,[-0.9,2.0,-1.3]]; _bag4 setDir 270; 

	_bag5 = "Land_BagFence_End_F" createVehicle (position _tnk); 
	_bag5 attachTo [_tnk,[1.1,1.7,-1.1]]; _bag5 setDir 270; 
	_bag6 = "Land_BagFence_End_F" createVehicle (position _tnk); 
	_bag6 attachTo [_tnk,[1.1,2.0,-1.3]]; _bag6 setDir 270; 

	_bag7 = "Land_BagFence_Short_F" createVehicle (position _tnk); 
	_bag7 attachTo [_tnk,[1.4,0.33,-1.1]]; _bag7 setDir 90; 
	_bag8 = "Land_BagFence_End_F" createVehicle (position _tnk); 
	_bag8 attachTo [_tnk,[1.4,1.6,-1.1]]; _bag8 setDir 270; 
	_bag9 = "Land_BagFence_End_F" createVehicle (position _tnk); 
	_bag9 attachTo [_tnk,[1.4,-0.97,-1.1]]; _bag9 setDir 90; 
	_bag10 = "Land_BagFence_End_F" createVehicle (position _tnk); 
	_bag10 attachTo [_tnk,[1.4,-1.6,-1.1]]; _bag10 setDir 90;
	_bag11 = "Land_BagFence_End_F" createVehicle (position _tnk); 
	_bag11 attachTo [_tnk,[1.4,-2.3,-1.1]]; _bag11 setDir 90;

	_bag12 = "Land_BagFence_Short_F" createVehicle (position _tnk); 
	_bag12 attachTo [_tnk,[-1.2,0.33,-1.1]]; _bag12 setDir 90; 
	_bag13 = "Land_BagFence_End_F" createVehicle (position _tnk); 
	_bag13 attachTo [_tnk,[-1.2,1.6,-1.1]]; _bag13 setDir 270; 
	_bag14 = "Land_BagFence_End_F" createVehicle (position _tnk); 
	_bag14 attachTo [_tnk,[-1.2,-0.97,-1.1]]; _bag14 setDir 90;
	_bag15 = "Land_BagFence_End_F" createVehicle (position _tnk); 
	_bag15 attachTo [_tnk,[-1.2,-1.6,-1.1]]; _bag15 setDir 90;
	_bag16 = "Land_BagFence_End_F" createVehicle (position _tnk); 
	_bag16 attachTo [_tnk,[-1.2,-2.3,-1.1]]; _bag16 setDir 90;

	_bag17 = "Land_BagFence_Short_F" createVehicle (position _tnk); 
	_bag17 attachTo [_tnk,[0.1,-2.2,-0.9]]; _bag17 setVectorUp [0,-1,-0.2]; 

	_bag18 = "Land_BagFence_End_F" createVehicle (position _tnk); 
	_bag18 attachTo [_tnk,[-0.9,-1.6,-1.1]]; _bag18 setDir 90;
	_bag19 = "Land_BagFence_End_F" createVehicle (position _tnk); 
	_bag19 attachTo [_tnk,[-0.9,-2.3,-1.1]]; _bag19 setDir 90;

	_bag20 = "Land_BagFence_End_F" createVehicle (position _tnk); 
	_bag20 attachTo [_tnk,[1.1,-1.6,-1.1]]; _bag20 setDir 90;
	_bag21 = "Land_BagFence_End_F" createVehicle (position _tnk); 
	_bag21 attachTo [_tnk,[1.1,-2.3,-1.1]]; _bag21 setDir 90;

// "FoliagePMugo"
// "FoliageSambucus"
// "FoliageGrassDryLongBunch"
// "FoliageArticum"
// "Land_Pneu"
// "Paleta1"


	_brwnMg = "LIB_MG42_Lafette_low" createVehicle (position player); 
	_brwnMg attachTo [_tnk ,[0.1,0.3,-0.7]]; _brwnMg setdir 0;

	_objs = [_bag,_bag1,_bag2,_bag3,_bag4,_bag5,_bag6,_bag7,_bag8,_bag9,_bag10,_bag11,_bag12,_bag13,_bag14,_bag15,_bag16,_bag17,_bag18,_bag19,_bag20,_bag21,_brwnMg];
	_objs 
};
	
/*
//Adding spawn scripts to objects
this addAction ["Recruit Landing Group", {_this call RecLander}];
this addAction ["Recruit Rifleman", {_this call RecRifle}]; 
this addAction ["Recruit Medic", {_this call RecMedic}]; 
this addAction ["Recruit Submachinegunner", {_this call RecSmGun}]; 
this addAction ["Recruit Machinegunner", {_this call RecMGun}]; 
this addAction ["Recruit AT Soldier", {_this call RecAT}]; 
this addAction ["Recruit Officer", {_this call RecOfficer}];
*/