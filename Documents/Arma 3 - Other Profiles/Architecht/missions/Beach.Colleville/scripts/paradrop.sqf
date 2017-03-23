//This script was a script snippet taken from an unknown author
if (!isServer) exitWith {};
private ["_paras","_vehicle","_chuteHeight","_dir"];
_vehicle = _this select 0;
_paras = _this select 1;
_chuteheight = if ( count _this > 1 ) then { _this select 1 } else { 100 };
_vehicle allowDamage false;
_dir = direction _vehicle;    

ParaLandSafe =
{
    private ["_unit"];
    _unit = _this select 0;
    _chuteheight = _this select 1;
    (vehicle _unit) allowDamage false;
    if (isPlayer _unit) then {[_unit,_chuteheight] spawn OpenPlayerchute};//Set AutoOpen Chute if unit is a player
    waitUntil { isTouchingGround _unit || (position _unit select 2) < 1 };
    _unit action ["eject", vehicle _unit];
    sleep 1;
    _inv = name _unit;
    [_unit, [missionNamespace, format["%1%2", "Inventory",_inv]]] call BIS_fnc_loadInventory;// Reload Loadout.
    _unit allowdamage true;// Now you can take damage.
};

OpenPlayerChute =
{
    private ["_paraPlayer"];
    _paraPlayer = _this select 0;
    _chuteheight = _this select 1;
    waitUntil {(position _paraPlayer select 2) <= _chuteheight};
    If (vehicle _paraPlayer IsEqualto _paraPlayer ) then {_paraPlayer action ["openParachute", _paraPlayer]};//Check if players chute is open, if not open it.
};

{
    _inv = name _x;// Get Unique name for Unit's loadout.
    [_x, [missionNamespace, format["%1%2", "Inventory",_inv]]] call BIS_fnc_saveInventory;// Save Loadout
    removeBackpack _x;
    _x disableCollisionWith _vehicle;// Sometimes units take damage when being ejected.
    _x allowdamage false;// Good Old Arma, they still can take damage on Vehcile exit.
    unassignvehicle _x;
    moveout _x;
    _x setDir (_dir + 90);// Exit the chopper at right angles.
    sleep 0.3;//space the Para's out a bit so they're not all bunched up.
    _x addBackPack "B_parachute";
} forEach _paras;

_vehicle allowDamage true;

{
    [_x,_chuteheight] spawn ParaLandSafe;
} forEach _paras;