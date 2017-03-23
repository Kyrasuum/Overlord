//arg: [obj, side, dist to check] or [_pos,side, dist to check]
//returns if enemy hex (east or west) is close.
private ["_dist", "_locSide", "_side","_obj","_nearbyLocations","_return","_pos"];

_obj = _this select 0;
_side = _this select 1;
_dist = _this select 2;
_return = [];
_pos = [];

if (typeName _obj == "ARRAY") then
	{
	_pos = _obj
}else{
	_pos = getPos _obj
};	

_nearbyLocations = nearestLocations [_pos, ["NameVillage"/*,"VegetationFir"*/], _dist];
{
	if(_x in SQU_HexagonLocArray)then
	{
		_locSide = _x getVariable "SQU_HexSide";
		if((_locSide != _side)) then
		{
			_return = _return + [_x];
		};
	};
}forEach _nearbyLocations;

_return
