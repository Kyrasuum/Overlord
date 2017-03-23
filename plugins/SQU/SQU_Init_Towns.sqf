private ["_wallcolor","_i","_loc","_name","_pos","_Percent","_posPoint"];
_possibleTOWNS = nearestLocations [(getMarkerPos "center"), ["NameCity"], 10000];

{
	_location = _x;
	_pos = locationPosition _location;
	_n = 0;
	for [{_cb=0}, {_cb<351}, {_cb=_cb+10}] do
	{
		_posPoint = [(_pos select 0) + SQU_HexRadius*sin _cb, (_pos select 1) + SQU_HexRadius*cos _cb, _pos select 2];
		if(surfaceIsWater _posPoint)then{
			_n = _n + 1;
		};
	};
	if(_n > 30)then
	{
		_location setVariable["SQU_HexType", "WATER"];
	};
	if(_n < 6)then
	{
		_location setVariable["SQU_HexType", "LAND"];
	};
	if((_n >= 6)&&(_n <= 30))then
	{
		_location setVariable["SQU_HexType", "COAST"];
		SQU_HexagonCoastalArray = SQU_HexagonCoastalArray + [_location];
	};
}foreach SQU_HexagonLocArray;

if(isServer)then
{
	for [{_iL=0}, {_iL < count _possibleTOWNS}, {_iL=_iL+1}] do
	{
		_loc = locationNull;
		_loc = _possibleTOWNS select _iL;
		_hex = _loc call SQU_Find_Loc;
		_side = _hex getVariable "SQU_HexSide";
		_si = Sides find _side;
		_wallcolor = SQU_HexTownColors select _si;
		_name = _hex getVariable "SQU_HexName";
		_locName = SQU_Names select (random (count SQU_Names - 1));
		
		{
			(format["%1%2",name _hex,_x]) setMarkerColorLocal _wallcolor;
		} forEach [0,1,2,3,4,5];			
		
		SQU_SideOwnedTownsNames set[_si, (SQU_SideOwnedTownsNames select _si) + [_name]];	
		SQU_Names = SQU_Names - [_locName];
		_hex setText format["%1",_locName];
		_hex setType "NameCity";
		SQU_HexagonTownArray = SQU_HexagonTownArray + [_hex];
	};
};

//finish off
SQU_numberOfTowns = count SQU_HexagonTownArray;
_Percent = 0;
while{SQU_numberOfTowns > 0}do
{
	if(_Percent > SQU_TownWin)exitwith{};
	SQU_numberOfTownsWin = SQU_numberOfTownsWin + 1;
	_Percent = round((SQU_numberOfTownsWin/SQU_numberOfTowns)*100);
};
SQU_TownDone = true;

if(isServer)then
{
  publicVariable "SQU_Names";
  publicVariable "SQU_HexagonTownArray";
  publicVariable "SQU_numberOfTowns";
  publicVariable "SQU_numberOfTownsWin";
  publicVariable "SQU_SideOwnedTownsNames";
  publicVariable "SQU_HexagonCoastalArray";
};	