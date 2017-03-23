//////////////////////////////////////////////
// Author : Bruce Worrall
////////////////////////////////////////////////
//[ POSITION or OBJECT or MARKER name]
//returns the elevation at the position
// < 0 = water depth // > 0 is elevation
////////////////////////////////////////////////

private ["_option","_hpad","_poszBSL","_pos"];
_pos = [0,0,0];

_option = [_this,0,[0,0,0],[[],objNull,""],[3]] call bis_fnc_param;

switch (typename _option) do {
	
	case ("ARRAY"): {
		_pos = _option;
	};
	case ("OBJECT"): {
		_pos = getPosATL _option;
	};
	case ("STRING"): {
		_pos = getMarkerPos _option;
	};
};

_pos set [2,0];
_hpad = "Land_HelipadEmpty_F" createVehicleLocal [0,0,0];
_hpad setPosATL _pos;
_poszBSL = ((getPosASLW _hpad) select 2);

deleteVehicle _hpad;
_poszBSL

