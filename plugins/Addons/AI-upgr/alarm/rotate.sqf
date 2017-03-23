// v.1.8
// Since we cannot use sendSimpleCommand from outside the tank we have to use a 
// workaround by issuing a move order to a nearby position left or right of the 
// tank. To issue a move order we look for an empty position around the tank 
// _dist meters away and _angle degrees clockwise (if turning right) or
// conterclockwise (if turning left). _angle can be from _max_angle to 
// _min_angle. After receiving the order the crew will start rotating the tank 
// in the (hopefully) appropriate direction. When we face the right direction 
// +/- _err, we give a stop order.

private ["_tank", "_face", "_tank_pos", "_pos_x", "_pos_y", "_tank_dir",
 "_angle", "_max_angle", "_min_angle", "_step", "_dist", "_err", "_max_tries", 
 "_diff", "_tries", "_position", "_pos_x_new", "_pos_y_new", "_face_angle", 
"_diff_angle"];

_max_angle = 140;
_min_angle = 20;
_step = 20; // step to iterate from maximum angle to minimum
_dist = 10; // Minimal move distance the tank will react to is 10 meters.
_th = 20; // Threshold. If current diff is less that _th, don't bother to turn
_err = 5; // accuracy -- how precisely we should turn
_max_tries = 10; // how many iterations to rotate the tank we have

_tank = _this select 0; // tank we need to rotate
_face = _this select 1; // direction to face

_tank_pos = [];
_pos_x = 0;
_pos_y = 0;
_tank_dir = getDir _tank;
_angle = 0;

// Need this if we loop setup.sqf more frequently (1 second instead of 5).
// Emulate lag between spotting and rotating.
sleep 2.5;

_diff = [_tank, _face] call calc_diff;
if ( abs _diff > _th and currentCommand _tank != "MOVE" and speed _tank < 1) 
then {
	_tries = 0;
	while { (abs _diff > _err) and (_tries <= _max_tries) and 
	currentCommand _tank != "MOVE"} do {
		if (_tries > 0) then {
			_position = [];
			while {(count _position == 0) and (abs _angle >= _min_angle)} do {
				// _angle and _dist are translated into X and Y
				_pos_x_new = _pos_x + _dist * sin (_tank_dir + _angle);
				_pos_y_new = _pos_y + _dist * cos (_tank_dir + _angle);
				_position = [_pos_x_new, _pos_y_new] findEmptyPosition 
				[0,1, typeOf _tank]; //is position for move order free?
				_angle = _angle - _step; //if not, try next
			};

			if (count _position == 0) then {
				_tries = _max_tries + 1; //exit loop
			}
			else {
				if (speed _tank < 1) then {
					_tank doMove _position;
					_countDown = 5;
					_diff_angle = _angle + _step;
					_face_angle = [getPosASL _tank, _position] call 
					calc_direction; //direction of move order
					while { (_countDown > 0) and (abs _diff > _err) and 
					(abs _diff_angle > 10) } do {
						_diff = [_tank, _face] call calc_diff;
						_diff_angle = [_tank, _face_angle] call calc_diff;
						_countDown = _countDown - 0.05;
						sleep 0.05;
					};
					doStop _tank; // stop
				}
				else {
					sleep 1;
				};
			};
		};

		_angle = _max_angle;
		_tank_pos = getPosASL _tank;
		_pos_x = _tank_pos select 0;
		_pos_y = _tank_pos select 1;
		_tank_dir = getDir _tank;

		 // difference between current direction and what we need to face
		_diff = [_tank, _face] call calc_diff;

		//if we turn left, relative angle is negative
		if (_diff < 0) then {
			_angle = 0 - _angle;
			_step = 0 - _step;
		};
		_tries = _tries + 1;
	};

	// The following lines are required for compatibility with High Command.
	// After issuing doStop on the vehicle, it stops following HC waypoints and 
	// cannot be moved. By issuing a move order at the vehicle's exact current 
	// location we're switching it from "Waiting" state to "Ready".
	if (!(isPlayer (leader _tank))) then {
		sleep 0.5;
		effectiveCommander _tank doMove getPosASL _tank;
	};
};

