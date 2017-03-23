private ["_playerObject","_clientId","_cycles","_name","_uid"];
_name = _this select 0;
_uid = _this select 1;
_id = _this select 2;

if(_name == "__SERVER__")exitWith{};

_clientId = -1;
_cycles = 0;
_playerObject = objNull;

while{true}do
{
	if(_clientId != -1)exitwith{};
  {
     if (getPlayerUID _x == _uid) exitWith
     {
        _clientId = owner _x;
        _playerObject = _x;
        
     };
  } forEach playableUnits;  
  _cycles = _cycles + 1;
  sleep .02;
  if(_cycles > 1000)exitwith{};
};
_playerObject setVariable["SQU_UID",(getPlayerUID _playerObject)];	
diag_log format["JIP: _cycles =  %1  %2",_cycles,vehicleVarName _playerObject];	

SQU_didJIP = true;
_clientId publicVariableClient  "SQU_didJIP";
SQU_didJIP = false;

SQU_id = [_uid];
_clientId publicVariableClient  "SQU_id";
SQU_id = [];
waitUntil{(SQU_id select 0) == _uid};

SQU_id = [SQU_Base, SQU_SideOwnedResourceNames, SQU_SideOwnedHex, SQU_SideOwnedTownsNames];
_clientId publicVariableClient  "SQU_id";