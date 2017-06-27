fndone = false;
waitUntil {sleep 5; fnDone};

["Initialize"] call BIS_fnc_dynamicGroups; // Initializes the Dynamic Groups framework
//rapelling	
[] execVM "plugins\rappelling\functions\fn_advancedRappellingInit.sqf"; 
[] execVM "plugins\rappelling\functions\fn_advancedUrbanRappellingInit.sqf";
["center", 2500, 20] execVM "plugins\ambient\ambientLightning.sqf";

//handle editor placed objects
{ 
	if (_x isKindOf "LandVehicle" || _x isKindOf "Plane" || _x isKindOf "Ship") then {
		_side = _x call findFaction;
		if (!isNil("_side")) then {[_x,_side] execVM "scripts\objRespawn.sqf";};
	};
}forEach vehicles;

{
	if !(isPlayer _x) then {
		_x call AI_initUnit;
	};
}forEach allUnits;

//German air patrols
//This piggy backs off the DMC air patrol script
DMC_DEBUG_MAPCENTER = false;
DMC_DEBUG_STARTINGPOSITIONS = false;
DMC_DEBUG_NEARESTLOCATIONS = false;
DMC_DEBUG_PATROLWAYPOINTS = false;
DMC_DEBUG_PATROL = false;
private ["_air_patrol"];
_air_patrol = [
	3000,												// Search radius for patrol locations (Starting from map center position)
	"center",											// Marker name representing the area of operations centre for the air patrol
 	"LIB_FW190F8",										// Fw 190
	WEST,												// Side of air patrol (West,East,Guer,Civ)
 	100,												// Patrol altitude (Meters above ground)
 	"RED",												// Patrol combat mode (Blue / Green / White / Yellow / Red)
 	"COMBAT",											// Patrol behaviour (Careless / Safe / Aware / Combat)
 	"Limited",											// Patrol speed (Limited / Normal / Full)
 	"SAD",												// Waypoint type (Move / Sad / Destroy)
	1.0,												// Skill of the crew steering the patrol vehicle (0.0 - 1.0)
	paramsArray select 6,								// Amount of air patrols to spawn (spawn positions will be randomized based on above defined marker locations)
 	3600,												// Minimum patrol time (used as timer for alive / canMove check)
 	TRUE												// Randomize waypoints (True / False)
] call DMC_fnc_spawnAirPatrol;


//Mission Defeat/Victory
_endGameThread = [] spawn {
	while {SQU_GameOn} do {
		//wait for players
		waitUntil {
			sleep 5;
			count allPlayers >= 1
		};

		_ply2 = {
			_return = false;
			if (side _x == (Sides select 1) ) then {
				if( playersNumber (Sides select 1) > 0 ) then {
					_return = (alive _x && isPlayer _x);
				}else{
					_return = alive _x
				};
			};
			_return
		} count allUnits;

		if ( (count(SQU_SideOwnedTownsNames select Attacker) >= SQU_numberOfTownsWin && SQU_numberOfTowns > 0)
			 || SQU_SideOwnedHex select Attacker >= SQU_numberOfHexsWin ) then {
			SQU_GameOn = false;
			[ ["GermanLost", false, 2], "BIS_fnc_endMission", Sides select Defender, false] call BIS_fnc_MP;
			[ ["USWon", true, true], "BIS_fnc_endMission", Sides select Attacker, false] call BIS_fnc_MP;
		};

		if ( _ply2<= 0 && [Sides select Attacker] call BIS_fnc_respawnTickets <= 0 ) then {
			SQU_GameOn = false;
			[ ["GermanWon", true, true], "BIS_fnc_endMission", Sides select Defender, false] call BIS_fnc_MP;
			[ ["USLost", false, 2], "BIS_fnc_endMission", Sides select Attacker, false] call BIS_fnc_MP;
		};
		sleep 120;//how often to check end game conditions
	};
};

//Defender manpower reinforcements
_reinforcementsThread = [] spawn {
	while {SQU_GameOn} do {
		//wait for players
		waitUntil {
			sleep 5;
			count allPlayers >= 1
		};

		sleep 360;//how long before we can reinforce

		//reinforce the defender's tickets
		[Sides select Defender, (paramsArray select 4)/100] call BIS_fnc_respawnTickets;		
	};	
};

//Tasks
	//this section is localized specifically for this mission
	//This should be customized on a per mission basis
_taskThread = [] spawn {
	//allied tasks
		//Sabotage Tasks
	[Sides select Attacker,["ArtyTask","Side Tasks"],
		["The Germans are going to continue shelling our men on the beach until these guns are silenced.","Sabotage German Artillery"],
		objNull,"CREATED",2,true,"destroy",true] call BIS_fnc_taskCreate;
	[Sides select Attacker,["AATask","Side Tasks"],
		["Our birds in the air are going to have a hard time until the closer flak batteries are disabled.","Sabotage German Anti-Aircraft Guns"],
		objNull,"CREATED",2,true,"destroy",true] call BIS_fnc_taskCreate;

		//Assault Tasks
	[Sides select Attacker,["StartTask","Commander Order"],
		["Sail into the beach and take control of the french beach that German soldiers have control over! Go Go Go!","Get Ready!"],
		objNull,"CREATED",2,true,"attack",true] call BIS_fnc_taskCreate;
	//german tasks
		//Sabotage Tasks
	[Sides select Defender,["BoatTask","Side Tasks"],
		["The allies are advancing under the cover of support from their destoryers.  Take them out and their invasion will follow shortly after.","Eliminate Allied Destroyers"],
		objNull,"CREATED",2,true,"destroy",true] call BIS_fnc_taskCreate;

		//Assault Tasks
	[Sides select Defender,["BeachTask","Commander Order"],
		["Sail into the beach and take control of the french beach that German soldiers have control over! Go Go Go!","Get Ready!"],
		objNull,"CREATED",2,true,"defend",true] call BIS_fnc_taskCreate;

	//Advances onto the next task
	NextTask = {
		if (["PushTask"] call BIS_fnc_taskState == "Succeeded") then {
			[Sides select Attacker,["TakeTask","Commander Order"],
				["We have almost won this... wipe out all remaining German resistance by securing Carentan and all surrounding territory!","Take Normandy!"],
				objNull,"CREATED",2,true,"attack",true] call BIS_fnc_taskCreate;
			[Sides select Defender,["SurviveTask","Commander Order"],
				["We have no more room left to retreat.  Not another step back, drive the allies back into the sea or die trying!","Stop the Allies!"],
				objNull,"CREATED",2,true,"defend",true] call BIS_fnc_taskCreate;
		};
		if (["SecureTask"] call BIS_fnc_taskState == "Succeeded") then {
			[Sides select Attacker,["PushTask","Commander Order"],
				["Now that we have a staging point on the beach, you need to use it to push the germans back from their lines.","Push the germans back!"],
				objNull,"CREATED",2,true,"attack",true] call BIS_fnc_taskCreate;
			[Sides select Defender,["SlowTask","Commander Order"],
				["The allied invasion was stronger than expected.  Stall the allies long enough for Reinforcements.","Prevent the Allies advance!"],
				objNull,"CREATED",2,true,"defend",true] call BIS_fnc_taskCreate;
		};
		if (["StartTask"] call BIS_fnc_taskState == "Succeeded") then {
			[Sides select Attacker,["SecureTask","Commander Order"],
				["The beach has little cover, move up and secure the beachhead for a better postion!","Secure Beachhead!"],
				objNull,"CREATED",2,true,"attack",true] call BIS_fnc_taskCreate;
			[Sides select Defender,["RepelTask","Commander Order"],
				["The allies are advancing on our beaches.   Make sure they regret it.","Stop them at the Beach!"],
				objNull,"CREATED",2,true,"defend",true] call BIS_fnc_taskCreate;
		};
	};

	//Task state checks
	while {SQU_GameOn} do {
		//Sabotage Tasks
			//Allied sabotage
		if (count (ArtyAlive select Defender) <= 0) then {
			["ArtyTask", "Succeeded",true] call BIS_fnc_taskSetState;
		};
		if ({toLower(typeOf _x) find "flak" >= 0} count vehicles < 1) then {
			["AATask", "Succeeded",true] call BIS_fnc_taskSetState;
		};
			//Axis sabotage
		if (count (ArtyAlive select Attacker) <= 0) then {
			["BoatTask", "Succeeded",true] call BIS_fnc_taskSetState;
		};

		//Assault Tasks
			//Checked from allied task point of view
		if (["StartTask"] call BIS_fnc_taskState != "Succeeded") then {
			//checking progress
			_tot = 0;
			_prog = 0;
			{
				if (_x getVariable "SQU_HexType" == "COAST") then {
					_tot = _tot + 1;
					if (_x getVariable "SQU_HexSide" == Sides select Attacker) then {
						_prog = _prog + 1;
					};
				};
			}forEach SQU_HexagonLocArray;
			//if we have 15% of the beach secured
			if (_prog / _tot+0.001 >= 0.25) then {
				//americans have landed
				["StartTask", "Succeeded",true] call BIS_fnc_taskSetState;
				["BeachTask", "Failed",true] call BIS_fnc_taskSetState;
				[] call NextTask;
			};
		};
		if (["SecureTask"] call BIS_fnc_taskState != "Succeeded") then {
			//checking progress
			_tot = 0;
			_prog = 0;
			{
				if (_x getVariable "SQU_HexType" == "COAST") then {
					_tot = _tot + 1;
					if (_x getVariable "SQU_HexSide" == Sides select Attacker) then {
						_prog = _prog + 1;
					};
				};
			}forEach SQU_HexagonLocArray;
			//if we have 30% of the beach secured
			if (_prog / _tot+0.001 >= 0.5) then {
				["SecureTask", "Succeeded",true] call BIS_fnc_taskSetState;
				["RepelTask", "Failed",true] call BIS_fnc_taskSetState;
				[] call NextTask;
			};
		};
		if (["PushTask"] call BIS_fnc_taskState != "Succeeded") then {
			//checking progress
			_tot = 0;
			_prog = 0;
			{
				_tot = _tot + 1;
				if (_x getVariable "SQU_HexSide" == Sides select Attacker) then {
					_prog = _prog + 1;
				};
			}forEach SQU_HexagonLocArray;
			//if we have 50% of the map secured
			if (_prog / _tot+0.001 >= 0.5) then {
				["PushTask", "Succeeded",true] call BIS_fnc_taskSetState;
				["SlowTask", "Failed",true] call BIS_fnc_taskSetState;
				[] call NextTask;
			};
		};
		if (["TakeTask"] call BIS_fnc_taskState != "Succeeded") then {
			//checking progress
			_tot = 0;
			_prog = 0;
			{
				_tot = _tot + 1;
				if (_x getVariable "SQU_HexSide" == Sides select Attacker) then {
					_prog = _prog + 1;
				};
			}forEach SQU_HexagonLocArray;
			//if we have 90% of the map secured
			if (_prog / _tot+0.001 >= 0.9) then {
				["TakeTask", "Succeeded",true] call BIS_fnc_taskSetState;
				["SurviveTask", "Failed",true] call BIS_fnc_taskSetState;
				//TBD: maybe give a win condition here?
			};
		};

		//Side mission call
			//Allies
		if (["SideMissionAllies"] call BIS_fnc_taskExists) then {
			//already assigned a side mission
		}else{

		};
			//Axis
		if (["SideMissionAxis"] call BIS_fnc_taskExists) then {
			//already assigned a side mission
		}else{

		};
		sleep 120;//update frequency
	};	
};