private ["_names","_clientId","_cycles","_name","_uid"];
_name = _this select 0;
_uid = _this select 1;
_id = _this select 2;

diag_log format["_this Disconnect =  %1",_this];	
_names = (SQU_Groups select 0) + (SQU_Groups select 1);

if(_name == "__SERVER__")exitWith{};
_timer = time;

_playerObject = objNull;

{
	
   if ((leader _x)getVariable "SQU_UID" == _uid) exitWith
   {
      _playerObject = (leader _x);
   };
   diag_log format["getPlayerUID =  %1",(leader _x)getVariable "SQU_UID"];
   diag_log format["leader =  %1",(leader _x)];   
} forEach _names;

_side = side _playerObject;
_si = -1;
_grp = group _playerObject;

_si = Sides find (side _unit);

_bool = (leader _grp) setOwner SQU_HEADLESS;

if((isNull _grp) && (!isServer)) exitwith
{
	_temp = SQU_Groups select _si;
	{_temp = _temp - [grpNull]}foreach _temp;
	SQU_Groups set[_si,_temp];
};
_playerObject setVariable["SQU_UID",nil];