//makes the calling object into a center for flak fire
//this flak fire has a global maximum range specified below with a predefined spread
//flak fire cannot target objects below their floor of 100 meters off surface
//multiple flak objects will work together to attack targets creating an effective screen
_self = _this select 0;
_maxSearchUnitDistance	= _this select 1;//how far we can shoot
_spread = 60;//the flak fire spread
_res = 10; //our resolution... for performance reasons
while {alive _self} do {
	{
		for "_i" from 0 to _res do {
			if (alive _x and side _x != side _self) then {
				_height = if ((getPosATL _x) select 2 < (getPosASL _x) select 2) then {(getPosATL _x) select 2} else {(getPosASL _x) select 2};
				if (_height > 100) then {
					_prjctl = "SmallSecondary";
					_origin = (position _x) vectorAdd (velocity _x) vectorAdd [
						(random _spread) - _spread/2, 
						(random _spread) - _spread/2,
						(random _spread/2) - _spread/4];

					_bullet = _prjctl createVehicle _origin;
				};
				[[[getPosATL _self],"plugins\ambient\alias_flaks.sqf"],"BIS_fnc_execVM",false,false] spawn BIS_fnc_MP;
				[[[getPosATL _self],"plugins\ambient\alias_tracers.sqf"],"BIS_fnc_execVM",false,false] spawn BIS_fnc_MP;
			};
		};
	}forEach ((position _self) nearEntities [["Air"], _maxSearchUnitDistance]);
	sleep _res*2;
};