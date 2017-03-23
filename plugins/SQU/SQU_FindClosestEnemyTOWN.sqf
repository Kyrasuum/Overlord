// arguments: [ _unit,_side]
// returns: land[loc, pos, dis], water[loc, pos, dis], coast[loc, pos, dis]
private ["_minDistanceL","_minDistanceW","_minDistanceC","_closestTown","_pos","_distance","_indexTown","_side","_closestTownpos","_name","_posUnit","_unit","_si","_return"];


_posUnit = _this select 0;
_si = _this select 1;
if (typeName _posUnit == "ARRAY") then
	{
	_posUnit = _posUnit
}else{
	_posUnit = getPos _posUnit
};

_minDistanceL = 1000000000;
_minDistanceW = 1000000000;
_minDistanceC = 1000000000;
_closestTown = locationNull;
_closestTownpos = [];
_indexTown = -1;
_return = [locationNull,locationNull,locationNull];

{
	_pos = _x getVariable "SQU_HexPos";				
	_side = _x getVariable "SQU_HexSide";
	_type = _x getVariable "SQU_HexType";
	_distance = _pos distance _posUnit;
	if(( _side != _si) && ( _distance < _minDistanceL) && (_type == "LAND")) then
	{
		_closestTown = _x;
		_closestTownpos = _pos;
		_minDistanceL = _distance;
		_return set[0,_closestTown];
	};
	if(( _side != _si) && ( _distance < _minDistanceW) && (_type == "WATER")) then
	{
		_closestTown = _x;
		_closestTownpos = _pos;
		_minDistanceW = _distance;
		_return set[1,_closestTown];
	};
	if(( _side != _si) && ( _distance < _minDistanceC) && (_type == "COAST")) then
	{
		_closestTown = _x;
		_closestTownpos = _pos;
		_minDistanceC = _distance;
		_return set[2,_closestTown];
	};		
}forEach SQU_HexagonTownArray;
_return