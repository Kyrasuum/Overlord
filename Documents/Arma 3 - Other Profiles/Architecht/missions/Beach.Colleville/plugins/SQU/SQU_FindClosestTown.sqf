// arguments: [ _unit,_side, special]
// returns: [townDesc, pos , distance]

private ["_minDistance","_minDistanceW","_minDistanceC","_closestTown","_pos","_distance","_indexTown","_side","_closestTownpos","_name","_posUnit","_unit","_si","_return"];


_unit = _this select 0;
_si = _this select 1;
_special = _this select 2;
_posUnit = getPos _unit;
_minDistance = 1000000000;

_closestTown = objnull;
_closestTownpos = [];

_return = [];

{
	_name =_x getVariable "SQU_HexName";
	_pos = _x getVariable "SQU_HexPos";				
	_side = _x getVariable "SQU_HexSide";
	_distance = _pos distance _posUnit;
	if(( _side == _si) && ( _distance < _minDistance)&& (!(_x in _special))) then
	{
		_closestTown = _x;
		_closestTownpos = _pos;
		_minDistance = _distance;
		_return = [_closestTown, _closestTownpos, _minDistance];
	};
	
}forEach SQU_HexagonTownArray;

_return