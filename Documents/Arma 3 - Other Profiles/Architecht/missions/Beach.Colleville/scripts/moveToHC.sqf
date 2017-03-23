if(!isServer) exitWith{};      //only execute on the server
if(!isMultiplayer) exitWith{}; //only execute in a MP environment

waitUntil{time > 2};

_unit = _this select 0;        //get the unit or group to transfer
_HC   = _this select 1;        //name of the headless client to transfer to

if(isNull _HC) exitWith{ //if no HC present, skip the transfer
	diag_log format["HC: Headless client NOT present, keeping %1 on the server.",_unit];
};  
_HCid      = owner _HC;        //get the ID of the HC
_nMoved    = 0;
{
	if(_x setOwnerGroup _HCid) then{
		_nMoved = _nMoved + 1;
	};
}forEach allGroups;
diag_log format["HC: Successfully transfered %1/%2 units to %3 (id:%4)",
				_nMoved,count allGroups,_HC,_HCid];