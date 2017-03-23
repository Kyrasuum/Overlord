//arg: [side]		player sidechat format["%1",_x];

private ["_locNum","_loc","_side","_si","_return","_allOwnedHexagons"];

_si = _this select 0;
_side = _this select 1;

_baseArray =+ (SQU_Base select _si);
_loc = (_baseArray select 0);
_return = [];
if (!isNil "_loc") then {_return = [_loc];};
_allOwnedHexagons =+ (SQU_SideOwnedResourceNames select _si);


{
  if((((floor(parseNumber _x))+2) mod 2)== 0)then //Even
  {
  	_locNum = (parseNumber _x);
  	{
  		if(!((str _x)in _return)) then
  		{
  			if(((missionNamespace getVariable (str _x)) getVariable "SQU_HexSide") == _side) then { _return set[(count _return),(str _x)]};
  		};
  	}forEach [(_locNum + 0.01), (_locNum + 1.0), (_locNum + 0.99), (_locNum - 0.01), (_locNum - 1.01), (_locNum - 1.0)];	
  }else{//Odd
  	_locNum = (parseNumber _x);
  	{
  		if(!((str _x)in _return)) then
  		{
  			if(((missionNamespace getVariable (str _x)) getVariable "SQU_HexSide") == _side) then { _return set[(count _return),(str _x)]};
  		}
  	}forEach [(_locNum + 0.01), (_locNum + 1.01), (_locNum + 1.0), (_locNum - 0.01), (_locNum - 1.0), (_locNum - 0.99)];			
	};
}foreach _return;
_return = (_allOwnedHexagons - _return);

_return