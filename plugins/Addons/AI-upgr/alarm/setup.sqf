// v.1.8
////////////////////////////////////////////////////////////////////////////////
// This script checks the targets known to the tank, assesses their threat 
// values and selects the most dangerous one.
// If the tank is not moving, it will rotate the hull to face the threat and 
// fire at the target. If the tank encounters an immediate threat (threat value
// > 500) while executing a move order, it will stop, rotate the hull and fire 
// at the target. After the target is gone, the tank will resume moving to its
// previous destination.
//
// 
// This behaviour is enabled if:
// 0. Tank is controlled by AI (player not in crew)
// 1. Tank has a commander
// 2. Commander's behaviour is AWARE, COMBAT or STEALTH
// 3. Tank's current command is either READY, WAITING or MOVE.
// 
// If commander's combat mode is STEALTH, the tank will not interrupt a move 
// order even if a high threat is encountered.
// It will continue moving as ordered, but will still fire at priority targets.
//
// The CARELESS combat mode will disable "smart" behaviour completely.
// 
// If the combat mode is other that CARELESS and you want to prevent a standing 
// tank from rotating its hull (for example you want the tank to face some 
// particular direction), issue a "Stop" command (1-6). Tank will pick priority 
// targets but will not move the hull. To resume rotating, issue a "Move" order 
// at the tank's current position. It won't move but "Stop" order will be 
// effectively cancelled.
//
// 
////////////////////////////////////////////////////////////////////////////////

// our tank
_unit = _this select 0;

// array containing all known hostile targets in 2000m radius
_neartargets = [];

// type of the target, as recognized
_type = "";

// perceived position of the target
_known_pos = [];

// do we have line of sight of the target
_has_los = false;

// threat value of the target
_threat = 0;
_value = 0;
_value_aimed = 0;

_had_target = false;
_was_moving = false;
_can_fire = false;

// Whether our unit has tracks (and armor). Since all units that have tracks
// also have stronger frontal armor, we don't need a separate variable
// _has_armor. If unit has armor, it does make sense to turn the front side to 
// the enemy. Otherwise not.
_has_tracks = false;

// Do we have different cannon rounds?
_has_cannon = false;
_cannon_name = "";
_mg_name = "";
_ap_round = "";
_heat_round = "";
_he_round = "";
_has_he = false;
_has_ap = false;
_has_heat = false;

_handle_rotate = [] spawn {};
_handle_scan = [] spawn {};

// What are we aiming at variables
_aimed_c = 0;
_aimed_m = 0;
_max_aimed = 0;
_target_act = objNull;
_target_before = objNull;
_hidden = false;

// Last time when was aiming at target
_last_aim = 0;
_last_hvinf = 0;

_max_threat = 0;
_max_thr_fire = 0;
_target = objNull;

// Target manually assigned by player
_user_target = objNull;
_u_target_present = false;
_maybe_cancelled = false;

// Infantry groups
_man = objNull;
_men = [];
_men_known = 0;

// Distance to target
_distance = 0;
_dist_aimed = 0;

// most dangerous target we can fire at
_fire_at = objNull;
_fire_before = objNull;

// Target's armor class: 0 - infantry, 1 - cars, 2 - armor.
_armor_aimed = 0;
_armor = 0;

// Supposedly currently loaded round, if wasn't changed by manual order
_current_mag = "";

// Default round: either game default or manually reloaded by player
_default_mag = "";

// WeaponTurret paths
_wtp = [[0], [0, 0], [-1]];

// Time when _fire_at receives a new value
_time_assigned = 0;

// if was moving and need to stop, saving destination here
_destination = [];

 _tracked_veh = ["Tank"];

diag_log format ["alarm\setup.sqf: started for %1, isServer: %2", _unit, 
str isServer];

// Do we have tracks?
{
  if (_unit isKindOf _x) exitWith {
    _has_tracks = true;
  };
} foreach _tracked_veh;

// Find the name of main cannon and MG
{
  if ((["cannon", _x] call substr) == 0) then {
    _has_cannon = true;
    _cannon_name = _x;
  };
  if ((["MG", _x] call substr) != -1) then {
    _mg_name = _x;
  };
} foreach (weapons _unit);

// Find the names of rounds
{
  if ((["AP", _x] call substr) >= 0) then {_ap_round = _x};
  if ((["HEAT", _x] call substr) >= 0) then {_heat_round = _x};
  if ((["HE_", _x] call substr) >= 0) then {_he_round = _x};
} foreach (magazines _unit);

// Make AP rounds the default
if (_ap_round != "" and _has_cannon) then {
  _default_mag = _ap_round;
  _current_mag = _ap_round;
  [_unit, _ap_round] call load_mag;
};

// [_unit, "Start"] call logtxt;

// Main loop start
while { alive _unit and local _unit} do {
  
  if ((!isPlayer commander _unit) and (!isPlayer gunner _unit)
  and (!isPlayer driver _unit) and (!isNull commander _unit or !isNull gunner 
  _unit) and (behaviour (effectiveCommander _unit) == "COMBAT" or behaviour 
  (effectiveCommander _unit) == "AWARE" or behaviour (effectiveCommander _unit)
  == "STEALTH") and (currentCommand _unit == "" or currentCommand _unit == 
  "STOP" or currentCommand _unit == "MOVE")) then {
    
	// A workaround for the bug when the commander is not effective commander
	// Occurs for Panther, Marshal etc
	if (!isNull commander _unit and (commander _unit != effectiveCommander
	_unit)) then {
	  _com = commander _unit;
	  _com setpos [0,0];
	  _com moveInCommander _unit;
	};
	
	_neartargets = _unit nearTargets 2000;
	
    if (count _neartargets > 0) then {
      _max_threat = 0;
      _max_thr_fire = 0;
      _target = objNull;
	  _fire_before = _fire_at;
      _fire_at = objNull;
      _max_aimed = 0;
	  _target_before = _target_act;
      _target_act = objNull;
	  _maybe_cancelled = false;
	  _u_target_present = false;
      
      if (_has_cannon) then {
        if (_he_round != "" and ([_unit, _he_round] call has_ammo > 0)) then {
		  _has_he = true;
		}
		else {
		  _has_he = false;
		};
        if (_heat_round != "" and ([_unit, _heat_round] call has_ammo > 0))
		then {
		  _has_heat = true;
		}
		else {
		  _has_heat = false;
		};
        if (_ap_round != "" and ([_unit, _ap_round] call has_ammo > 0)) then {
		  _has_ap = true;
		}
		else {
		  has_ap = false;
		};
      };
	  
////////////////////////////////////////////////////////////////////////////////
// Target identification
      // Did the player assign target manually?
      // If target gone (killed, forgotten) between loops, assignedTarget
      // will be null. If the player gave a 'no target' order,
      // assignedTarget will be null.If the player assigned target 
      // manually, assignedTarget will be some object.
      
	  if (assignedTarget _unit != _fire_before) then {
	    if (!isNull assignedTarget _unit) then {
		  // user assigned target
		  _user_target = assignedTarget _unit;
		}
		else {
		  // target destroyed or forgotten or cancelled (but still exists in the
		  // world (not alive, far away etc)
		  if (side _fire_before == civilian) then {
		    // target destroyed
		  }
		  else {
		    // target forgotten or cancelled (no way to tell yet)
			_maybe_cancelled = true;
		  };
		};
	  }
	  else {
	    if (!isNull assignedTarget _unit) then {
		  // previous target remains
		}
		else {
		  // no targets or current target is removed from world
		};
	  };
	  
      {
        // if subjective value is very positive, i.e. target is hostile
		if ((_x select 3) > 100) 
        then {
          _threat_array = [_x, _unit] call calc_threat;
          _threat = _threat_array select 0;
          _can_fire = _threat_array select 1;
          _armor = _threat_array select 2;
          _distance = _threat_array select 3;
          _los = [_x, _unit] call calc_los;
		  
		  
          // Find most dangerous target
          if ((_threat > _max_threat) and (_threat > 100) and _los) 
          then {
            _max_threat = _threat;
            _target = _x select 4;
            _type = _x select 1;
            _known_pos = _x select 0;
          };
          // Did the player assign target? If yes, make it a priority.
          if (_x select 4 == _user_target) then {
            if (_maybe_cancelled) then {
			  // not destroyed (since still present in enemy faction)
			  // but cancelled by 'no target' order
			  _user_target = objNull;
			  _value = _threat;
			}
			else {
			  _u_target_present = true;
			  _value = 999;
			};
          }
          else {
	        _value = _threat;
		  };
          // Find most dangerous target we can fire at
          // Algorithm for tanks
          if (_has_cannon and _los and _can_fire)  then {
            // Identify group of infantry, 3+ in 15m radius
            if (_armor == 0) then {
              _men = (_x select 4) nearEntities ["CAManBase", 15];
              if (count _men > 1) then {
                _men_known = 0;
                _men = _men - [_x select 4];
                // We must _know_ about them, no cheating
                {
                  _man = _x;
                  {
                    if (_x select 4 == _man) then {
                      _men_known = _men_known + 1;
                    };
                  } foreach _neartargets;
                } foreach _men;
                if (_men_known >= 2) then {
                  _value = 110 - _distance / 1000;
                };
              };
            };
            if (_value > 100) then {
              switch (_armor) do {
                case 0: {
                  if (_has_he) then {
                    // Pretty far, takes a while to aim.
                    // Still more than 100, but low value.
                    if (_distance > 400) exitWith {
                      _value = 100 + _value / 100;
                    };
                  }
                  else {
                    // If no HE round and distance > 300
                    // (hard to hit with MG too), then set
                    // low value (subjective cost, less than
                    // 100)
                    if (_distance > 300) exitWith {
                      _value = (_x select 3)/1000000;
                    };
                  };
                };
                case 1: {
                  // Neither HEAT nor AP
                  if (!_has_heat and !_has_ap) exitWith {
                    _value = (_x select 3)/1000000;
                  };
                  // AP is less effective against light armor
                  if (_has_ap) exitWith {
                    _value = (_value - 100) / 1.5 + 100;
                  };
                };
                case 2: {
                  if (!_has_ap) exitWith {
                    _value = (_x select 3)/1000000;
                  };
                };
              };
              if ((_value > _max_thr_fire) and (_value > 100)) 
              then {
                _max_thr_fire = _value;
                _fire_at = _x select 4;
              };
            };
          }
          // Simple algorithm for everyone else
          else {
            if ((_value > _max_thr_fire) and (_value > 100)
            and _los and _can_fire) then {
              _max_thr_fire = _value;
              _fire_at = _x select 4;
            };
          };
          // Are we aimed at it?
          if (_has_cannon) then {
            _aimed_c = _unit aimedAtTarget [_x select 4, 
            _cannon_name];
            _aimed_m = _unit aimedAtTarget [_x select 4, _mg_name];
            if (_aimed_c > _max_aimed) then {
              _max_aimed = _aimed_c;
              _target_act = _x select 4;
              _armor_aimed = _armor;
              _dist_aimed = _distance;
              _value_aimed = _value;
            };
            if (_aimed_m > _max_aimed) then {
              _max_aimed = _aimed_m;
              _target_act = _x select 4;
              _armor_aimed = _armor;
              _dist_aimed = _distance;
              _value_aimed = _value;
            };
          };
        };
      } foreach _neartargets;
	  if (!_u_target_present) then {
	    // in case we had user-assigned target but it's not in _neartargets
		// anymore
		_user_target = objNull;
	  };

////////////////////////////////////////////////////////////////////////////////
// Actions.
      // Selecting rounds
      if (_has_cannon) then {
        // Did the player reload round? Make the new one default.
        if (currentWeapon _unit == _cannon_name) then {
          if (_current_mag != currentMagazine _unit) then {
            _default_mag = currentMagazine _unit;
            _current_mag = currentMagazine _unit;
			// [_unit, "Changed default round to " + _current_mag] call logtxt;
          };
        };
        if (!isNull _target_act) then {
          if (_target_act != _target_before) then {
		    // [_unit, format["Target: %1", _target_act]] call logtxt;
		  };
		  _last_aim = time;
          switch (_armor_aimed) do {
            case 0: {
              // Priority target, load HE
              if (_value_aimed > 100) then {
                // last time we were aiming at high-value infantry
				// this is to prevent frequent switching from HE to AP
				// when aiming at a far away group of infantry
				_last_hvinf = time;
				if (_dist_aimed > 300) then {
				  if (_has_he) then {
				    if (_current_mag != _he_round) then {
					  // [_unit, "Loading " + _he_round] call logtxt;
					  [_unit, _he_round] call load_mag;
					  _current_mag = _he_round;
					};
					if (currentWeapon _unit != _cannon_name) then {
					  // [_unit, "Switching to cannon"] call logtxt;
					  _unit selectWeapon _cannon_name;
					};
				  };
                }
                else {
                  if (currentWeapon _unit != _mg_name) then {
				  // [_unit, "Switching to MG"] call logtxt;
				  _unit selectWeapon _mg_name;
				  };
                };
              }
              // Regular (low priority) infantry target. Load
              // default round.
              else {
                if (_current_mag != _default_mag) then {
                  if (time - _last_hvinf > 2) then {
				    // [_unit, "Loading default: " + _default_mag] call logtxt;
				    [_unit, _default_mag] call load_mag;
                    _current_mag = _default_mag;
				  };
                };
                // If default is HE, then we mean to fire
                // cannon at every single infantry
                if (_default_mag == _he_round and _has_he and _dist_aimed > 300)
                then {
                  if (currentWeapon _unit != _cannon_name) then {
				    // [_unit, "Switching to cannon"] call logtxt;
					_unit selectWeapon _cannon_name;
				  };
                }
                // Otherwise use MG against low priority inf.
                else {
                  if (currentWeapon _unit != _mg_name) then {
				    // [_unit, "Switching to MG"] call logtxt;
					_unit selectWeapon _mg_name;
				  };
                };
              };
            };
            case 1: {
              if (_has_heat and _current_mag != _heat_round) 
              exitWith {
                // [_unit, "Loading " + _heat_round] call logtxt;
				[_unit, _heat_round] call load_mag;
                _current_mag = _heat_round;
				if (currentWeapon _unit != _cannon_name) then {
                  // [_unit, "Switching to cannon"] call logtxt;
				  _unit selectWeapon _cannon_name;
				};
              };
              if (_current_mag == _heat_round) exitWith {
                if (currentWeapon _unit != _cannon_name) then {
				  // [_unit, "Switching to cannon"] call logtxt;
				  _unit selectWeapon _cannon_name;
				};
              };
              if (_has_ap and _current_mag != _ap_round) 
              exitWith {
                // [_unit, "Loading " + _ap_round] call logtxt;
				[_unit, _ap_round] call load_mag;
                _current_mag = _ap_round;
				if (currentWeapon _unit != _cannon_name) then {
                  // [_unit, "Switching to cannon"] call logtxt;
				  _unit selectWeapon _cannon_name;
				};
              };
              if (_current_mag == _ap_round) exitWith {
                if (currentWeapon _unit != _cannon_name) then {
				  // [_unit, "Switching to cannon"] call logtxt;
				  _unit selectWeapon _cannon_name;
				};
              };
            };
            case 2: {
              if (_has_ap) then {
			    if (_current_mag != _ap_round) then {
                  // [_unit, "Loading " + _ap_round] call logtxt;
				  [_unit, _ap_round] call load_mag;
                  _current_mag = _ap_round;
                };
				if (currentWeapon _unit != _cannon_name) then {
				  // [_unit, "Switching to cannon"] call logtxt;
				  _unit selectWeapon _cannon_name;
				};
              };
            };
          };
        };
      };

	  
      // Firing
      if (!isNull _fire_at) then {
        // Is it the same target? If yes, don't issue target and fire
        // over and over again.
        if (_fire_at != _fire_before) then {
          _had_target = true;
          
		  // Fire at priority target
		  // Remove all weapons to force stop fire if already firing.
		  // This seems to be the only way :(
		  _wt_all = [];
		  _i = 0;
		  {
			_wt = [];
			_cp = _x;
			{
			  _wt = _wt + [_x];
			  _unit removeWeaponTurret [_x, _cp];
			} foreach (_unit weaponsTurret _cp);
			_wt_all set [_i, _wt];
			_i = _i + 1;
		  } foreach _wtp;
		  sleep 0.1;
		  // Prevent assigning targets automatically
		  effectiveCommander _unit disableAI "AUTOTARGET";
		  gunner _unit disableAI "AUTOTARGET";
		  sleep 0.1;
		  // Add back the weapons
		  _i = 0;
		  {
			_cp = _x;
			{
			  _unit addWeaponTurret [_x, _cp];
			} forEach (_wt_all select _i);
			_i = _i + 1;
		  } forEach _wtp;
		  
		  // If commander doesn't doTarget he tends to reassign targets for
		  // gunner, which makes targeting much less predictable
		  effectiveCommander _unit doWatch _fire_at;
          effectiveCommander _unit doTarget _fire_at;
		  // Gunner's commands are needed to aim in 'hold fire' mode.
          gunner _unit doWatch _fire_at;
          gunner _unit doTarget _fire_at;
          gunner _unit doFire _fire_at;
		  _time_assigned = time;
        };
		// If we have the same target for more than 30 seconds, re-enable
		// autotarget to prevent being stuck in case of LoS but cannot fire etc
		if (time - _time_assigned > 30) then {
		  effectiveCommander _unit enableAI "AUTOTARGET";
		  gunner _unit enableAI "AUTOTARGET";
		};
      }
      else {
        if (_had_target) then {
          // Cancel targeting if no more targets
          _had_target = false;
		  
		  // Cancel doTarget and doFire
          gunner _unit doFire objNull;
		  // Cancel doWatch
          gunner _unit doWatch _unit;
		  gunner _unit enableAI "AUTOTARGET";
		  // Cancelling for commander requires two steps
          effectiveCommander _unit doWatch objNull;
		  // A hack against commander stuck watching the same direction forever
		  effectiveCommander _unit disableAI "AUTOTARGET";
		  sleep 0.5;
		  effectiveCommander _unit enableAI "AUTOTARGET";
        };
        // If no more dangerous targets and we were aiming at something
        // more than 30 seconds ago, then load default round.
        if (_has_cannon and (time - _last_aim) > 30) then {
          if (_current_mag != _default_mag) then {
	        // [_unit, "No targets, loading " + _default_mag] call logtxt;
			[_unit, _default_mag] call load_mag;
            _current_mag = _default_mag;
		  };
		  if (currentWeapon _unit != _cannon_name) then {
            // [_unit, "No targets, switching to cannon"] call logtxt;
			_unit selectWeapon _cannon_name;
		  };
        };
		if (scriptDone _handle_scan) then {
		   _handle_scan = [_unit] spawn scan;
        };
      };


      // Moving
      if (!isNull _target) then {
        // direction to target
        _direction = [getPosASL _unit, _known_pos] call calc_direction;

        if (currentCommand _unit == "MOVE" and behaviour 
        (effectiveCommander _unit) != "STEALTH" and _max_threat > 500 and 
		_has_tracks and scriptDone _handle_rotate)
		then {
          _was_moving = true;
          // save the current move destination
          _destination = (expectedDestination _unit) select 0;
          while { speed _unit > 5 } do {
            // moveTo works only when executing doMove command
            // override move order issued by player and stop
			effectiveCommander _unit moveTo getPosASL _unit;
            sleep 1;
          };
        };
		
		
		if (_has_tracks and !isNull driver _unit) then {
          if (_direction != 1000 and currentCommand _unit != "MOVE"
          and _max_threat > 110 and speed _unit < 1) then {
			// rotate hull to target
			if (scriptDone _handle_rotate) then {
			  _handle_rotate = [_unit, _direction] spawn rotate;
            };
          };
        };
      }
      else {
        if (_was_moving and scriptDone _handle_rotate) then {
          // resume moving
		  // if we already have another move order, do not resume previous
		  if (currentCommand _unit != "MOVE") then {
		    _unit doMove _destination;
		  };
          _was_moving = false;
        };
      };
    }
    else {
      //no targets around, doing nothing
    };
  }
  else {
    if (_had_target) then {
      // Cancel targeting if switched from AWARE, or COMBAT, or STEALTH
      // to other mode
      _had_target = false;
      gunner _unit doFire objNull;
      gunner _unit doWatch _unit;
	  gunner _unit enableAI "AUTOTARGET";
      effectiveCommander _unit doWatch objNull;
	  effectiveCommander _unit disableAI "AUTOTARGET";
	  sleep 0.5;
	  effectiveCommander _unit enableAI "AUTOTARGET";
      _fire_before = objNull;
	  _user_target = objNull;
	  _target_before = objNull;
    };
    if (_was_moving and scriptDone _handle_rotate) then {
      // resume moving
	  // if we already have another move order, do not resume previous
	  if (currentCommand _unit != "MOVE") then {
	    _unit doMove _destination;
	  };
      _was_moving = false;
    };
  };
  sleep 0.5;
};
// [_unit, "End"] call logtxt;