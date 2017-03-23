//defines this object as being able to respawn for the specified side
//the tickets subtracted upon respawn depend on the vehicle class
params ["_object","_side"];

_pos = getPosATL _object;
_dir = getDir _object;
_class = typeOf _object;
_ticket = 0;
_respawnCode = {};

if (_object isKindOf "Ship" ) then {
    _ticket = -10;
};
if (_object isKindOf "Tank" ) then {
    _ticket = -7;
};
if (_object isKindOf "Car" ) then {
    _ticket = -5;
};
if (_object isKindOf "Motorcycle" ) then {
    _ticket = -3;
};
if (_object isKindOf "Plane" ) then {
    _ticket = -10;
};

if (toLower(_class) find "m119" >= 0) then {
    ArtyAlive set [Defender,(ArtyAlive select Defender) + [_object]];  
    _object addEventHandler ["killed", "_object = _this select 0; ArtyAlive set [Defender,(ArtyAlive select Defender) - [_object]];"];
    _ticket = 1;
};
if (toLower(_class) find "anzac" >= 0) then {
    ArtyAlive set [Attacker,(ArtyAlive select Attacker) + [_object]];  
    publicVariable "ArtyAlive";
    _object addEventHandler ["killed", "_object = _this select 0; ArtyAlive set [Attacker,(ArtyAlive select Attacker) - [_object]];"];
    _ticket = 1;
};
if (toLower(_class) find "flak" >= 0) then {
    AAAlive = AAAlive + 1;  
    publicVariable "AAAlive";
    _object addEventHandler ["killed", "AAAlive = AAAlive - 1; publicVariable ""AAAlive"";"];
    [_object, 1000] execVM "scripts\objFlak.sqf";
    _ticket = 1;
};
if (toLower(_class) find "lcvp" >= 0 ) then {
    _object call BeachLand;
    _respawnCode = {_this call BeachLand;};
    _ticket = 0;
};
if (toLower(_class) find "m4a3" >= 0 ) then {
    _objs = [_object] call SandSherm;
    _respawnCode = {{deleteVehicle _x;}forEach _objs; _objs = [_this] call SandSherm;};
};

while { SQU_GameOn && _ticket <= 0 } do 
{
    if ([_side] call BIS_fnc_respawnTickets > _ticket) then {
        waitUntil { 
            sleep 10; 
            !alive _object || (position _object distance _pos > 100 && {alive _x} count crew _object == 0) 
        };
        deleteVehicle _object;
        sleep (-10*_ticket+30);
        _object = createVehicle [_class, _pos, [], 0, "NONE"];
        _object setPos _pos;
        _object setDir _dir;
        [_side, _ticket] call BIS_fnc_respawnTickets;
        _object call _respawnCode;
    };
};