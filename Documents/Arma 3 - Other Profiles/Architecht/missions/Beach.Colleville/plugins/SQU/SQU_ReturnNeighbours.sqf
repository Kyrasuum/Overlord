//arg: [loc or loc name]		player sidechat format["%1",_x];

private ["_loc","_location","_nearbyLocations","_pos"];

_location = _this select 0;
_return = [];

_loc = locationNull;
if ((typeName _location) == "STRING") then
{
	_loc = (missionNamespace getVariable _location);
}else{
	_loc = _location;
};



if((((floor(parseNumber(name _loc)))+2) mod 2)== 0)then //Even
{
	_locNum = (parseNumber(name _loc));
	{
		_return = _return + [(str _x)];
	}forEach [(_locNum + 0.01), (_locNum + 1.0), (_locNum + 0.99), (_locNum - 0.01), (_locNum - 1.01), (_locNum - 1.0)];	
}else{//Odd
	_locNum = (parseNumber(name _loc));
	{
		_return = _return + [(str _x)];	
	}forEach [(_locNum + 0.01), (_locNum + 1.01), (_locNum + 1.0), (_locNum - 0.01), (_locNum - 1.0), (_locNum - 0.99)];			
};

_return