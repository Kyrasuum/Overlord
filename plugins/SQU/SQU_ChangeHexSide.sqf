///arg [side,location]
private ["_location","_winside","_loseSide","_loc","_pos","_si","_siL","_numberOfTownsLoser","_plus1","_minus1","_incomeArray","_sideoil","_Oil","_sideval","_val","_sideFood","_Food","_sideIron","_Iron","_name","_valArray","_oilArray","_ironArray","_foodArray"];
_winSide = _this select 0;
_location = _this select 1;
_loseSide = _this select 2;

_loc = locationNull;
if ((typeName _location) == "STRING") then
{
	_loc = (missionNamespace getVariable _location);
}else{
	_loc = _location;
};



_pos =  _loc getVariable "SQU_HexPos";
_name =  _loc getVariable "SQU_HexName";

_loc setVariable["SQU_Dispute", [0,0,0]];

_si = Sides find _winSide;
_siL = Sides find _loseSide;

if(count (SQU_Base select _si) == 0)then
{
	_temp = [_name, _pos];
	SQU_Base set[_si,_temp];
};
	
//*********************************************
//Hex Town change******************************
//*********************************************	
if(_loc in SQU_HexagonTownArray)then
{
	_plus1 = SQU_SideOwnedTownsNames select _si;
	_plus1 = _plus1 + [_name];
	SQU_SideOwnedTownsNames set[_si, _plus1];
	_minus1 = SQU_SideOwnedTownsNames select _siL;
	_minus1 = _minus1 -  [_name];
	SQU_SideOwnedTownsNames set[_siL, _minus1];
};
SQU_pvChangeHexSidePacket = SQU_pvChangeHexSidePacket + [[_winSide,_name,_loseSide]];