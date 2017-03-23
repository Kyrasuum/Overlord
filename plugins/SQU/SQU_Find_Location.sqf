//arg: obj or [_pos,_pos,0] or location
//returns which hexagon, pos or obj is in.
private ["_obj","_NearestLocation","_nearbyLocations","_pos"];

_obj = _this;
_NearestLocation = nil;
_pos = [];

if (typeName _obj == "ARRAY") then
	{
	_pos = _obj
}else{
	_pos = getPos _obj
};	

_nearbyLocations = nearestLocations [_pos, ["NameVillage"], (SQU_HexRadius+100)];
if(!isNil{_nearbyLocations select 0})then
{
  {
  	if(_x in SQU_HexagonLocArray)exitwith
  	{
  		_NearestLocation = _x
  	};
  }forEach _nearbyLocations;
};

if(isNil {_nearbyLocations select 0})then //off map
{
	_nearbyLocations = nearestLocations [_pos, ["NameVillage"], (SQU_HexRadius*50)];
	{
		if(_x in SQU_HexagonLocArray)exitwith
		{
			_NearestLocation = _x
		};
	}forEach _nearbyLocations;
};
_NearestLocation
