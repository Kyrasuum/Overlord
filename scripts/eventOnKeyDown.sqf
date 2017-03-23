private["_stopPropagation","_caller","_keyCode","_shiftState","_controlState","_altState"];

_stopPropagation = false;
_caller = _this select 0;
_keyCode = _this select 1;
_shiftState = _this select 2;
_controlState = _this select 3;
_altState = _this select 4; 

switch (_keyCode) do  
{ 
	// M
	// remove map
	case 0x32:
	{
		if (SQU_NoMap) then {
			//removing map upon use
			player unassignItem "ItemMap";
			player removeItem "ItemMap";
		};
	};
	// F1
	// Show server menu
	case 0x3B: 	
	{ 
		createDialog'RscDisplayServerInfoMenu';
		_stopPropagation = true; 
	};
	// F2
	// Throw a magazine
	case 0x3C: 	
	{ 
		DE_var_throwPressed = true;
		_magName = "";
		_magName = {
			_find = (getArray (configFile >> "cfgWeapons" >> currentWeapon player >> "magazines")) find _x;
			if (_find > -1) exitWith {_x};
		} count ((backpackItems player) + (vestItems player) + (uniformItems player));

		if (typeName _magName == "STRING" && {_magName != ""}) then
		{
			DE_var_throwMag = _magName;
			(vehicle player) setWeaponReloadingTime [player, "HandGrenade_Stone", 0];
			waitUntil {needReload player == 0};
			player addMagazine "HandGrenade_Stone";
			player forceWeaponFire ["HandGrenade_Stone","HandGrenade_Stone"];
		} else {
			hint "You do not have an extra magazine for this weapon";
		};
		_stopPropagation = true; 
	};
	// F3
	// Context Sensitive healing action
	case 0x3D:	
	{
		_target = cursorTarget;
		if (!isNil "_target") then {
			[ player, _target ] remoteExec [ "Lar_fnc_wake", 2 ];
		}else{
			[ player, player ] remoteExec [ "Lar_fnc_wake", 2 ];
		};
		_stopPropagation = true; 
	};
	// F4
	// Earplugs
	case 0x3E:	
	{ 
		if (isNil "earPlugs") then
		{
			earPlugs = false;
		};
		if !(earPlugs) then
		{
			0 fadeSound 0.2;
			earPlugs = true;
			titleText ["Ear plugs ENABLED","PLAIN DOWN",0.2];
		}
		else
		{
			0 fadeSound 1;
			earPlugs = false;
			titleText ["Ear plugs DISABLED","PLAIN DOWN",0.2];
		};	

		_stopPropagation = true; 
	};
	// F5
	// Relax action
	case 0x3F:	
	{ 
		player action ["sitDown", player];
		_stopPropagation = true; 
	};
	// F6
	case 0x40: 	
	{
		; 
	};
	// F7
	case 0x41: 	
	{ 
		;
	};
	case 0x42:	
	{ 
		; 
	};
	// F9
	case 0x43: 	
	{ 
		;	
	};
	// F10
	case 0x44:	
	{ 
		;
	};
};
_stopPropagation