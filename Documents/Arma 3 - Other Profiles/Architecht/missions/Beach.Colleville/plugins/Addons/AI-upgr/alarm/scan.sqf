// v.1.8
// Emulates 'Scan the horizon' command by creating an invisible target,
// revealing it to our vehicle, ordering commander to target it and then
// moving it away to the edge of viewDistance. The target is moving with the
// unit and circles around it in case (extremely unlikely) the unit will
// actually see it. Not being able to see the target makes the commander to
// 'scan the horizon' in search of it. Note: moving the target further than
// viewDistance makes the unit to forget about the target.

_unit = _this select 0;
_ec = effectiveCommander _unit;
_angle = getDir _unit;
_sign = 0;
if (random 1 >= 0.5) then {
  _sign = 1;
}
else {
  _sign = -1;
};

_target = "Land_Can_V3_F" createVehicle getPosATL _unit;
hideObjectGlobal _target;
_target setPosASL [(eyePos _unit select 0) + 10 * sin _angle, (eyePos _unit select
 1) + 10 * cos _angle, eyePos _unit select 2];
_unit reveal [_target, 4];
_ec doWatch _target;
if (_ec != gunner _unit) then {
  gunner _unit doWatch _unit;
};

while {isNull assignedTarget _unit and (behaviour (effectiveCommander _unit) == 
"COMBAT" or behaviour (effectiveCommander _unit) == "AWARE" or behaviour 
(effectiveCommander _unit) == "STEALTH") and _ec == effectiveCommander _unit}
 do {
  _pos = getPosATL _unit;
  _unit_x = _pos select 0;
  _unit_y = _pos select 1;
  _x = viewDistance * 0.9 * sin _angle;
  _y = viewDistance * 0.9 * cos _angle;
  
  _watch = [_unit_x + _x, _unit_y + _y];
  _target setPos _watch;
  
  _angle = _angle + 30 * _sign;
  if (abs _angle > 360) then {
    _angle = _angle % 360;
  };
  sleep 5;
};

deleteVehicle _target;