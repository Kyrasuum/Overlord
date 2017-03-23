// v.1.8
// Returns difference in degrees [-180; 180] between arbitrary direction and the direction the unit is facing
calc_diff = {
	private ["_tank", "_face", "_tank_dir", "_diff"];
	_tank = _this select 0;
	_face = _this select 1;
	_tank_dir = getDir _tank;

	//_diff negative -- turn left, _diff positive -- turn right
	_diff = _face - _tank_dir;
	if (_diff > 180) then {
		_diff = _diff - 360;
	};
	if (_diff < -180) then {
		_diff = _diff + 360;
	};
	_diff
};


// Returns direction in degrees [0; 360] from _unit_pos to _position
// Params:
// 0: our position (array)
// 1: another position (array)
calc_direction = {
	private ["_unit_pos", "_position", "_dirVector", "_dir_x", "_dir_y", "_direction"];

	_unit_pos = _this select 0;
	_position = _this select 1;
	_dirVector =  _position vectorDiff _unit_pos;
	_dir_x = _dirVector select 0;
	_dir_y = _dirVector select 1;
	_direction = 1000;
	if (_dir_y == 0 and _dir_x == 0) then {
		// no valid direction, return 1000
	}
	else {
		if (_dir_x >= 0) then {
			_direction = acos(_dir_y / (sqrt(_dir_x ^ 2 + _dir_y ^ 2)));
		}
		else {
			_direction = 360 - acos(_dir_y / (sqrt(_dir_x ^ 2 + _dir_y ^ 2)));
		};
	};
	_direction
};

// Returns target's relative threat
// Threat < 100 is calculated from Subjective value / 1000000 and means regular units, not dangerous to armor.
// Threat > 500 means immediate threat and must be destroyed ASAP. The tank will stop, even if was executing a
// move order, rotate the hull to the target and fire. After destroying the immediate threat the tank will
// resume moving to it's previous destination.
// Input params:
// 0: target array:
//		0: perceived position
//		1: perceived type as recognized
//		2: perceived side
//		3: subjective cost
//		4: object itself
//		5: position accuracy
// 1: our tank object
calc_threat = {
	private ["_threat", "_distance", "_unit_pos", "_known_pos",
	"_type", "_can_fire", "_unit", "_soft", "_target_wep", "_unit_wep",
	"_wep_threat", "_y", "_i", "_j", "_ranges", "_t", "_classes", "_can_dmg", 
	"_softness"];
	
	_threat = 0;
	_can_fire = false;
	// is the target a lightly armored / unarmored target (MRAP, static AT)?
	// if yes, we might want to switch to HEAT round
	// 0: doesn't matter
	// 1: soft target (cars, static weapons)
	// 2: heavily armrored (tanks)
	_soft = 0;

	_unit = _this select 1;
	_unit_pos = getPosATL _unit;
	_known_pos = _this select 0 select 0; // perceived position of the target
	_type = _this select 0 select 1; // perceived type of the target
	_distance = _unit_pos distance _known_pos; // distance to target
	
	_target_wep = [_this select 0 select 4] call list_weapons;
	_unit_wep = [_unit] call list_weapons;
	
	_threat = 0;
	
	// value positions correspond to list_weapons return array
	_wep_threat = [
		// 0: cannons
		[400, 425, 450, 500, 600],
		// 1: autocannons
		[0, 200, 250, 470, 600],
		// 2: light MGs
		[0, 0, 0, 0, 0],
		// 3: AT rockets
		[0, 400, 450, 500, 570],
		// 4: HE rocket
		[0, 300, 350, 400, 470],
		// 5: GMG
		[0, 0, 130, 150, 200],
		// 6: HMG
		[0, 0, 0, 140, 190],
		// 7: autocannon AA
		[0, 0, 0, 130, 180],
		// 8: AA rockets
		[0, 0, 0, 0, 0]
	];
	
	_ranges = [2000, 1500, 1000, 750, 500];
	
	_classes = [
		"CAManBase",
		"Car",
		"Tank",
		"Helicopter",
		"Ship",
		"Plane",
		"StaticWeapon"
	];
	
	_softness = [
		0, // Men
		1, // Car
		2, // Tank
		0, // Heli
		1, // Ship
		0, // Plane
		0  // Static
	];
	// value positions correspond to list_weapons return array
	_can_dmg = [
		//cnn, acnn, lmgs, atrck, herck, gmgs, hmgs, acaa, aarck
		// CAManBase
		[true, true, true, false, true, true, true, true, false],
		// Car
		[true, true, false, true, true, true, true, true, false],
		// Tank
		[true, true, false, true, false, false, false, false, false],
		// Helicopter
		[true, true, false, false, false, false, true, true, true],
		// Ship
		[true, true, false, true, true, true, true, true, false],
		// Plane
		[false, true, false, false, false, false, true, true, true],
		// Static
		[true, true, true, true, true, true, true, true, false]
	];
	
	
	// target's threat base on its weapons
	_i = 0;
	{
		_y = _x;
		if (_y) then {
			_t = 0;
			_j = 0;
			{
				if (_distance < _ranges select _j) then {
					_t = _x - _distance / 100;
				};
				_j = _j + 1;
			} foreach (_wep_threat select _i);

			if (_t > _threat) then {
				_threat = _t;
			};
		};
		_i = _i + 1;
	} foreach _target_wep;
	
	// can we fire at it?
	_i = 0;
	{
		if (_can_fire) exitWith {};
		_y = _x;
		if (_type isKindOf _y) then {
			_soft = _softness select _i;
			_j = 0;
			{
				if (_x AND _unit_wep select _j) exitWith {
					_can_fire = true;
				};
				_j = _j + 1;
			} foreach (_can_dmg select _i);
		};
		_i = _i + 1;
	} foreach _classes;
	
	// Exception for wheeled APCs, that have stronger armor than other 'cars'
	if (_type isKindOf "Wheeled_APC_F") then {
		_soft = 2;
	};
	
	if (_threat == 0) then {
		_threat = (_this select 0 select 3) / 1000000;
		_can_fire = true;
	};
	//hint format ["t: %1\nt: %2\nf: %3\ns: %4\nd: %5",
	//_this select 0 select 4, _threat, _can_fire, _soft, _distance];
	[_threat, _can_fire, _soft, _distance]
};

// Returns True if there is a line of sight between unit and target
// Input params:
// 0: target array:
//		0: perceived position
//		1: perceived type as recognized
//		2: perceived side
//		3: subjective cost
//		4: object itself
//		5: position accuracy
// 1: our tank object
calc_los = {
	private ["_has_los", "_eyePos_tank", "_tlos", "_olos", "_known_pos", "_shift", "_los_pos", "_tank", "_target"];
	
	_has_los = False;

	_target = _this select 0 select 4;
	_tank = _this select 1;
	_eyePos_tank = eyePos _tank;
	_known_pos = ATLtoASL (_this select 0 select 0); // nearTargets gives perceived position ATL
	_actual_pos = getPosASL _target;
	_shift = [(_known_pos select 0) - (getPosASL _target select 0), (_known_pos select 1) - 
	(getPosASL _target select 1), (_known_pos select 2) - (getPosASL _target select 2)];

	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Percevied position can be different from actual one, and calculations using perceived position can result in no LoS when the target 
	// is actually visible. For this purpose if the perceived position is not further away than 10 meters from actual, we calculate LOS 
	// from actual position, because we assume that we still can see the target. We cannot always use actual position for LoS calculation, 
	// because we may know that the target exists, but may not know its exact location. We want to avoid magically learning that we have 
	// a LoS of a target that no one is looking at.
	// Perceived position Z coordinate equals (if zero judgment error) eyePos Z coordinate for all vehicles, air and static weapons. For 
	// soldiers perceived position Z coordinate is lower than eyePos Z coordinate by: 40 cm if standing, 30 cm if kneeling, 20 cm if prone.
	// Perceived position Z coordinate usually has a very small error, so we can use it as Z coordinate of actual position. We need that 
	// because all getPos commands return the point 0 m above the ground.
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	if (((_shift select 0) ^ 2 + (_shift select 1) ^ 2 + (_shift select 2) ^ 2) < 100) then {
		_los_pos = [_actual_pos select 0, _actual_pos select 1, _known_pos select 2];
	}
	else {
		_los_pos = _known_pos;
	};
	_olos = lineIntersects [_los_pos, _eyePos_tank, _target, _tank];
	// Looks like terrainIntersectASL takes the grass into account too.
	// You may have a 'clear' line of sight and 'Ready to fire' report
	// but still have terrainIntersectASL true.
	// Fixed by adding extra 0.2m to Z coordinate.
	_tlos = terrainIntersectASL [[_los_pos select 0, _los_pos select 1,
	(_los_pos select 2) + 0.2], _eyePos_tank];
	if (!_olos and !_tlos) then {
		_has_los = True;
	};
	
	_has_los
};


// Due to the lack of substr function in ARMA here is the custom one
// Params:
// 0: string to find
// 1: string to look in
substr = {
	private ["_find", "_string", "_find_len", "_str", "_found", "_pos"];
	_find = _this select 0;
	_string = toArray (_this select 1);
	_find_len = count toArray _find;
	_str = [] + _string;
	_str resize _find_len;
	_found = false;
	_pos = 0;
	for "_i" from _find_len to count _string do {
		if (toString _str == _find) exitWith {_found = true};
		_str set [_find_len, _string select _i];
		_str set [0, "x"];
		_str = _str - ["x"];
		_pos = _pos + 1;
	};
	if (!_found) then {
		_pos = -1;
	};
	_pos
};

// How much ammo a magazine has
// Params:
// 0: our tank object
// 1: magazine name
has_ammo = {
	private ["_ammo", "_mag", "_unit"];
	_unit = _this select 0;
	_mag = _this select 1;
	_ammo = 0;
	{
		if (_mag == _x select 0) exitWith {_ammo = _x select 1};
	} foreach (magazinesAmmo _unit);
	_ammo
};

// Loads a round into cannon
// Params:
// 0: our tank object
// 1: magazine name to load
load_mag = {
	private ["_unit", "_mag", "_mag_ammo", "_all_mags"];
	_unit = _this select 0;
	_mag = _this select 1;
	_all_mags = magazinesAmmo _unit;
	_mag_ammo = [_unit, _mag] call has_ammo;
	{
		_unit removeMagazine (_x select 0);
	} foreach _all_mags;
	_unit addMagazine [_mag, _mag_ammo];
	_all_mags = _all_mags - [[_mag, _mag_ammo]];
	{
		_unit addMagazine _x;
	} foreach _all_mags;
};

logtxt = {
	private ["_unit", "_txt"];
	_unit = _this select 0;
	_txt = _this select 1;
	if (!isNull player) then {
		if ((side _unit) == (side player)) then {
			if (isServer and isMultiplayer) then {
			  missionNamespace setVariable ["msg", _txt];
			  publicVariable "msg";
			}
			else {
			  _unit commandChat _txt;
			};
		};
	};
};

// Returns an array of weapons classes present on unit:
// [0: has_cannon, 1: has_autocannon, 2: has_mg, 3: has_at_rocket,
// 4: has_he_rocket, 5: has_gmg, 6: has_hmg, 7: has_autocannon_aa,
// 8: has_aa_rocket]
// Params:
// 0: unit
list_weapons = {
  private["_unit", "_cannon", "_autocannon", "_mg", "_at_rocket", "_he_rocket",
  "_gmg", "_hmg", "_autocannon_aa", "_titan_rocket", "_aa_rocket_mag",
  "_at_rocket_mag", "_aa_rocket", "_has_weapons", "_all_weapons", "_i", "_wep",
  "_y"];
  
  _unit = _this select 0;
  _has_weapons = [false, false, false, false, false, false, false, false, false];
  _i = 0;
  _wep = [];
  
  // Slammer, Slammer UP, Varsuk, Kuma
  _cannon = ["cannon_120mm", "cannon_105mm", "cannon_125mm", "cannon_120mm_long"];
  
  // Marshall, Kamysh, Mora, Gorgon, Wipeout
  _autocannon = ["autocannon_40mm_CTWS", "autocannon_30mm_CTWS",
  "autocannon_30mm"];
  
  // present on tanks, APCs
  _mg = ["LMG_M200", "LMG_coax"];
  
  // Blackfoot, Kajman, Orca, PCML, Alamut, Titan compact, Wipeout, Buzzard
  _at_rocket = ["missiles_DAGR", "missiles_SCALPEL", "launch_NLAW_F",
  "launch_RPG32_F", "launch_Titan_short_F", "launch_B_Titan_short_F",
  "launch_O_Titan_short_F", "launch_I_Titan_short_F", 
  "Missile_AGM_02_Plane_CAS_01_F", "Rocket_04_AP_Plane_CAS_01_F", 
  "Missile_AGM_01_Plane_CAS_02_F", "Rocket_03_AP_Plane_CAS_02_F"];
  
  // Kajman, Hellcat, Pawnee
  _he_rocket = ["rockets_Skyfire", "missiles_DAR", "Rocket_03_HE_Plane_CAS_02_F",
  "Rocket_04_HE_Plane_CAS_01_F"];
  
  // Panther, Marid, Hunter GMG, Ifrit GMG, Strider GMG, Static GMG, Blackfoot,
  // Wipeout, Kajman, Buzzard, Neophrone
  // gatling cannons added because of similar damage
  _gmg = ["GMG_40mm", "GMG_20mm", "gatling_20mm", "Gatling_30mm_Plane_CAS_01_F",
  "gatling_30mm", "Twin_Cannon_20mm", "Cannon_30mm_Plane_CAS_02_F"];
  
  // Panther, Marid, Hunter HMG, Ifrit HMG, Strider HMG, Offroad armed
  // Static HMG, Varsuk
  _hmg = ["HMG_127_APC", "HMG_127", "HMG_M2", "HMG_01", "HMG_NSVT"];
  
  // Cheetah, Tigris
  _autocannon_aa = ["autocannon_35mm"];
  
  // Cheetah, Tigris, Kamysh, Gorgon, Static AT, Static AA
  // can be loaded with either AT or AA missiles, need to check available mag
  _titan_rocket = ["missiles_titan", "missiles_titan_static"];
  _aa_rocket_mag = ["1Rnd_GAA_missiles", "4Rnd_Titan_long_missiles"];
  _at_rocket_mag = ["2Rnd_GAT_missiles", "1Rnd_GAT_missiles"];
  
  // Titan MPRL, Buzzard
  _aa_rocket = ["launch_Titan_F", "launch_B_Titan_F", "launch_O_Titan_F",
  "launch_I_Titan_F", "Missile_AA_04_Plane_CAS_01_F", "missiles_ASRAAM", 
  "missiles_Zephyr", "Missile_AA_03_Plane_CAS_02_F"];
  
  _all_weapons = [_cannon, _autocannon, _mg, _at_rocket, _he_rocket, _gmg, _hmg,
  _autocannon_aa, _aa_rocket];
  
  _wep = _wep + (weapons _unit) + (_unit weaponsTurret [0,0]) +
  (_unit weaponsTurret [-1]);
  
  {
	_y = _x;
	{
		if (_x in _y) then {
		  _has_weapons set [_i, true];
		};
	} foreach _wep;
	_i = _i + 1;
  } foreach _all_weapons;
  
  {
	_y = _x;
	if (_y in _titan_rocket) then {
		{
			if (_x in _aa_rocket_mag) then {
				_has_weapons set [8, true];
			};
			if (_x in _at_rocket_mag) then {
				_has_weapons set [3, true];
			};
		} foreach (magazines _unit);
	};
  } foreach _wep;
  
  _has_weapons
};