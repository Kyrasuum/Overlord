/*
	Author: Demon Cleaner
	
	Description:
	Creates a number of aircraft autonomously patrolling a specified area
	
	Parameter(s):
	
	Returns:
	Multidimensional array e.g: [[vehicle,[crew],group]]
	
	Examples:
	readme.txt
	
	Changelog:
	
	v1.41
	Removed automatic reading of "map center" from map config files as this often 
	leads to undesired results. Instead I've added a user placeable marker that 
	represents the area of operations center for the air patrol.
	
	v1.4
	Fixed an error in waypoint generation
	Added code to remove Air Patrol specific markers when not in debug
	Refined waypoint generation and added debug markers
	Added OPFOR air vehicle class names
	Removed functions folder for simplicity
	Fixed cfgFunctions.hpp
	
	v1.3
	Reworked waypoint randomization
	Added DMC_spawnAirPatrol function to autoinit (auto compilation)
	Removed uneccessary check for BIS fnc init (functions are preloaded)
	Added debug markers for mission designers (check variables in init)
	Larger waypoint completion radius
	Default patrol time (vehicle respawn) changed to 60 minutes
	Changed combat behaviour to make air patrols more agressive
	Changed air patrol vehicle crew default skills
	Changed air patrol vehicle default flight altitude
	Changed air patrol vehicle default speed to FULL
	Added a readme.txt explaining how to implement this script
	
	v1.2
	Added automatic world recognition
	Removed parameter to specify the name of the current game world
	Reduced the search radius for locations on Altis
	Default patrol time changed to 5 minutes
	
	v1.1
	Added parameter to specify the amount of air patrols to spawn
	Added parameter to specify the minimum patrol time
	Converted script to a function that can be precompiled at init and called when needed
	Added recursive function call in order to respawn destroyed patrols automatically
	
	v1.0
	Initial release ported over from ArmA 2
*/

// Easy script identifier
scriptName "DMC_SPAWN_AIR_PATROL";

private [
	"_locSRD","_locPST","_patVHT","_patSID","_patALT","_patROE","_patBEH",
	"_patSPE","_patWPT","_patSKL","_patNUM","_patMPT","_patRND","_locPST_keep",
	"_locSSP","_nLocs","_posArr","_angArr","_a","_idx","_mpos","_angle",
	"_radius","_fpos","_b","_spwArr","_spwVeh","_c","_nPat","_mkr"
];

// Fetch arguments - try to compensate for user input errors
_locSRD = [_this,0,5000,[0]] call BIS_fnc_param;
_locRmc = [_this,1,"mkr_aoe_center",[""]] call BIS_fnc_param;
_patVHT = [_this,2,"O_Heli_Attack_02_F",[""]] call BIS_fnc_param;
_patSID = [_this,3,EAST] call BIS_fnc_param;
_patALT = [_this,4,100,[0]] call BIS_fnc_param;
_patROE = [_this,5,"YELLOW",["","BLUE","GREEN","WHITE","YELLOW","RED"]] call BIS_fnc_param;
_patBEH = [_this,6,"SAFE",["","SAFE","AWARE","COMBAT","STEALTH"]] call BIS_fnc_param;
_patSPE = [_this,7,"NORMAL",["","LIMITED","NORMAL","FULL"]] call BIS_fnc_param;
_patWPT = [_this,8,"MOVE",["",["MOVE","SAD","DESTROY"]]] call BIS_fnc_param;
_patSKL = [_this,9,0.95,[0,[0,1]]] call BIS_fnc_param;
_patNUM = [_this,10,1,[0,[1,100]]] call BIS_fnc_param;
_patMPT = [_this,11,300,[0]] call BIS_fnc_param;
_patRND = [_this,12,TRUE] call BIS_fnc_param;

// Find cities, villages and other locations within a specified radius
// locSSP = getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition");
_locSSP = getMarkerPos _locRmc; // Not using predefined map center from config

// Debug map center position
if (DMC_DEBUG_MAPCENTER) then {
	_mkr = createMarker [format ["Marker_%1",random 100],_locSSP];
	_mkr setMarkerColor "colorWhite";
	_mkr setMarkerType "mil_circle";
	_mkr setMarkerText format [" AOE Center Position: %1",str _locSSP];
} else {
	deleteMarker _locRmc;
};

// Nearest locations
allLocationTypes = [];
"allLocationTypes pushBack configName _x" configClasses (
	configFile >> "CfgLocationTypes"
);
_nLocs = nearestLocations [_locSSP,allLocationTypes,_locSRD];

// Randomize waypoints if selected
if (_patRND) then {_nLocs = _nLocs call BIS_fnc_arrayShuffle};

// Debug nearestLocations
if (DMC_DEBUG_NEARESTLOCATIONS) then {
	{
		_mkr = createMarker [format ["Marker_%1",random 100],getPos _x];
		_mkr setMarkerColor "colorOrange";
		_mkr setMarkerType "mil_dot";
		_mkr setMarkerText format [" %1",str _x];
	} forEach _nLocs;
};

// Select the air patrol spawn position(s) based on the results of the above query
_angArr = [];
_posArr = [];
for [{_a = 0},{_a < _patNUM},{_a = _a + 1}] do {
	_idx = round (random ((count _nLocs) - 1));
	_mpos = getPos (_nLocs select _idx);
	_angle = round (random 360 / pi);
	_angArr set [_a,_angle];
	_radius = 50 + round (random 50);
	_fpos = [(_mpos select 0) - ((sin _angle) * _radius),(_mpos select 1) - ((cos _angle) * _radius)];
	_posArr set [_a,_fpos];
	
	// Debug patrol starting positions
	if (DMC_DEBUG_STARTINGPOSITIONS) then {
		_mkr = createMarker [format ["Marker_%1",random 100],_fPos];
		_mkr setMarkerColor "colorBlack";
		_mkr setMarkerType "mil_triangle";
		_mkr setMarkerText format [" Starting Position: %1",str _fPos];
	} else {
		{deleteMarker _x;} forEach ["mkrAirPatSta_01","mkrAirPatSta_02","mkrAirPatSta_03","mkrAirPatSta_04"];
	};
};

// Spawn air patrol group(s)
_spwArr = [];
for [{_b = 0},{_b < _patNUM},{_b = _b + 1}] do {
	_spwVeh = [(_posArr select _b),(_angArr select _b),_patVHT,_patSID] call BIS_fnc_spawnVehicle;
	(_spwVeh select 0) addeventhandler ["fired", "(_this select 0) setvehicleammo 1;"];
	_spwArr set [_b,_spwVeh];
};

// Plot flight path(s) for air patrol
for [{_c = 0},{_c < _patNUM},{_c = _c + 1}] do {
	_nPat = [
		(_spwArr select _c),_nLocs,_patALT,_patROE,_patBEH,_patSPE,_patWPT,_patSKL,
		_patMPT,_patRND,_locSRD,_patVHT,_patSID
	] spawn {
		private [
			"_veh","_units","_grp","_locs","_nLocs","_nLoc","_wp","_wpCount","_eLoc","_alt",
			"_roe","_beh","_spe","_wpt","_mpt","_rnd","_srd","_pst","_vht","_sid","_skl",
			"_am","_d","_idx","_air_patrol","_mkr","_wayP","_mColor"
		];

		// Fetch arguments
		_veh = (_this select 0) select 0; // Vehicle
		_units = (_this select 0) select 1; // Units
		_grp = (_this select 0) select 2; // Group
		_locs = _this select 1; // Patrol locations
		_alt = _this select 2; // Flight altitude
		_roe = _this select 3; // Rules of engagement
		_beh = _this select 4; // Combat Behaviour
		_spe = _this select 5; // Speed
		_wpt = _this select 6; // Waypoints
		_skl = _this select 7; // Unit skill
		_mpt = _this select 8; // Min patrol time
		_rnd = _this select 9; // Randomize waypoints
		_srd = _this select 10; // Search distance
		_vht = _this select 12;	// Vehicle type
		_sid = _this select 13;	// Side

		// Patrol vehicle properties
		_veh = vehicle leader _veh;
		_veh setVehicleLock "LOCKED";
		_veh flyInHeight _alt;

		// Air patrol behaviour
		_grp setCombatMode _roe;
		_grp setBehaviour _beh;
		_grp setSpeedMode _spe;
		{_x setSkill _skl} forEach _units;
		
		// Add waypoints on locations
		{
			_wp = _grp addWaypoint [getPos _x,500];
			_wp setWaypointType _wpt;
			_wp setWaypointSpeed _spe;
			_wp setWaypointBehaviour _beh;
		} forEach _locs;
		
		// Make sure at least 3 waypoints were generated
		_eLoc = _locs select 0; // Last location in locations array
		_wpCount = count (waypoints _grp); // Current amount of waypoints
		while {_wpCount <= 2} do {
			_wp = _grp addWaypoint [getPos _eLoc,500];
			_wp setWaypointType _wpt;
			_wp setWaypointBehaviour _beh;
			_wp setWaypointSpeed "LIMITED";
			_wpCount = _wpCount + 1;
		};
		
		// Add final cycle waypoint
		_wp = _grp addWaypoint [getPos _eLoc,500 + floor(random 1000)];
		_wp setWaypointType "CYCLE";
		_wp setWaypointBehaviour _beh;
		_wp setWaypointSpeed _spe;
		
		// Set waypoint completion radius for generated waypoints
		for [{_i=0},{_i<=count (waypoints _grp)},{_i=_i+1}] do {
			[_grp,_i] setWaypointCompletionRadius 250;
		};
		
		// Debug patrol waypoints
		if (DMC_DEBUG_PATROLWAYPOINTS) then {
			_wayP = waypoints _grp;
			[_wayP] call BIS_fnc_arrayShift;
			{
				_mkr = createMarker [format ["Marker_%1",random 100],waypointPosition _x];
				_mColor = switch (str _grp) do {
					case "B Alpha 1-1": {"colorBlue"};
					case "B Alpha 1-2": {"colorRed"};
					case "B Alpha 1-3": {"colorGreen"};
					case "B Alpha 2-1": {"colorYellow"};
					default {"colorBlack"};
				};
				_mkr setMarkerColor _mColor;
				_mkr setMarkerType "mil_dot";
				_mkr setMarkerText format [" Waypoint: %1",str _x];
			} forEach _wayP;
		};
		if (DMC_DEBUG_PATROL) then {
			[_veh,_grp] spawn {
				private ["_veh","_grp"];
				_veh = _this select 0;
				_grp = _this select 1;
				while {alive _veh && canMove _veh} do {
					_mkr = createMarker [format ["PosDebugMarker_%1",random 100],[(getPosASL _veh) select 0,(getPosASL _veh) select 1]];
					_mkr setMarkerColor "colorRed";
					_mkr setMarkerType "mil_dot";
					_mkr setMarkerText format ["Group %1 en-route to waypoint #%2",str _grp,currentWaypoint _grp];
					sleep 2;
					deleteMarker _mkr;
				};
			};
		};

		// Wait for minimum patrol timer to run out
		sleep _mpt;

		// Wait for patrol to be destroyed or immobilized (eg: ran out of fuel, crash landed ...)
		waitUntil {((!(alive vehicle _veh)) || (!(canMove vehicle _veh)))};

		if ([_sid] call BIS_fnc_respawnTickets > 10) then {
			// Recursively call function to spawn a replacement patrol for the destroyed instance using user supplied parameters
			_air_patrol = [
				_srd,	// Search radius for patrol locations (Starting from map center position)
	 			_vht,	// Air patrol vehicle type (Anything that can fly and has a crew)
	 			_sid,	// Side of air patrol (West,East,Resistance,Civilian)
	 			_alt,	// Patrol altitude (Meters above ground)
	 			_roe,	// Patrol combat mode (Blue / Green / White / Yellow / Red)
	 			_beh,	// Patrol behaviour (Careless / Safe / Aware / Combat)
	 			_spe,	// Patrol speed (Limited / Normal / Full)
	 			_wpt,	// Waypoint type (Move / Sad / Destroy)
	 			_skl,	// Skill of the crew steering the patrol vehicle (0.0 - 1.0)
				1,		// Amount of air patrols to spawn (spawn positions will be randomized based on above defined marker locations)
	 			_mpt,	// Minimum patrol time (used as timer for alive / canMove check)
	 			_rnd	// Randomize waypoints (True / False)] call DMC_Air_Patrol;
			] call DMC_fnc_spawnAirPatrol;
			[_sid, -10] call BIS_fnc_respawnTickets;//subtract tickets
		};
	};
};

// Return multidimensional array e.g: [[vehicle,[crew],group]]
_spwArr
