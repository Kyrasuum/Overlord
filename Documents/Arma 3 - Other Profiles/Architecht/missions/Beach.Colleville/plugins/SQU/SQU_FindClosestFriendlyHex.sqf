//arg: [obj,side] or [_pos,side] or location
//returns which hexagon, pos or obj is in.
private ["_side","_obj","_return","_nearbyLocations","_pos","_locSide","_locPos"];

_obj = _this select 0;
_side = _this select 1;
_return = objNull;
_pos = [];
_exitnow = false;

if (typeName _obj == "ARRAY") then
	{
	_pos = _obj
}else{
	_pos = getPos _obj
};	

_nearbyLocations = nearestLocations [_pos, ["NameVillage"/*,"VegetationFir"*/], (SQU_capRad*100)];
if(!isNil{_nearbyLocations select 0})then
{
  {
  	if(_x in SQU_HexagonLocArray)then
  	{
  		_locSide = _x getVariable "SQU_HexSide";
  		_locPos = _x getVariable "SQU_HexPos";  		
  		if(_side == _locSide)then
  		{
  			_return = _x;
  			_exitnow = true;
  		};
  	};
  	if(_exitnow)exitwith{};
  }forEach _nearbyLocations;
};

_return