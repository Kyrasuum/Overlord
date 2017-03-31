waitUntil {time > 0};
enableEnvironment [true, true];
//parameters
if (isNil "paramsArray") then {
	paramsArray = [10,2,90,90,500,5000,1,2,10,1,10,0];
};
enableSaving [false,false];
RscSpectator_allowFreeCam = true;
RscSpectator_hints = [true,true,true];

//functions
SQU_Find_Loc = compileFinal preprocessFileLineNumbers "plugins\SQU\SQU_Find_Location.sqf";
SQU_RecieveChangeHexSidePacket = compileFinal preprocessFileLineNumbers "plugins\SQU\SQU_RecieveChangeHexSidePacket.sqf";
SQU_ReturnNeighbours = compileFinal preprocessFileLineNumbers "plugins\SQU\SQU_ReturnNeighbours.sqf";
SQU_CheckSideBaseNeighbours = compileFinal preprocessFileLineNumbers "plugins\SQU\SQU_CheckSideBaseNeighbours.sqf";
SQU_FindClosestTown = compileFinal preprocessFileLineNumbers "plugins\SQU\SQU_FindClosestTown.sqf";
SQU_FindClosestEnemyTOWN = compileFinal preprocessFileLineNumbers "plugins\SQU\SQU_FindClosestEnemyTOWN.sqf";
SQU_FindClosestEnemyHEX = compileFinal preprocessFileLineNumbers "plugins\SQU\SQU_FindClosestEnemyHEX.sqf";
SQU_GetWaterDepth = compileFinal preprocessFileLineNumbers "plugins\SQU\SQU_GetWaterDepth.sqf";
SQU_RandomMapPos = compileFinal preprocessFileLineNumbers "plugins\SQU\SQU_RandomMapPos.sqf";
SQU_checkIfEnemyisClose = compileFinal preprocessFileLineNumbers "plugins\SQU\SQU_checkIfEnemyisClose.sqf";
SQU_FindClosestFriendlyHex = compileFinal preprocessFileLineNumbers "plugins\SQU\SQU_FindClosestFriendlyHex.sqf";
findFaction = compileFinal preprocessFileLineNumbers "scripts\findFaction.sqf";//parses the objects side
"SQU_pvChangeHexSidePacket" addPublicVariableEventHandler {(_this select 1) call SQU_RecieveChangeHexSidePacket};//updates all clients
call compileFinal preprocessFileLineNumbers "plugins\plank\plank_init.sqf";
call compileFinal preprocessFileLineNumbers "scripts\RespawnMenu.sqf";
call compileFinal preprocessFileLineNumbers "scripts\unitInit.sqf";
call compileFinal preprocessFileLineNumbers "scripts\Recruit.sqf";
call compileFinal preprocessFileLineNumbers "scripts\AIcommander.sqf";
TCB_AIS_PATH = "plugins\ais_injury\";

//defines
SQU_Names = ["Caen","Cherbourg","Carentan","Coleville","St. Vierville","Bayeux","Trevieres","St. Laurent","Isigny","Villars","St. Lo"];

//Params
SQU_Center = getArray(configFile >> "CfgWorlds" >> worldName >> "centerPosition");
SQU_VerAmount = paramsArray select 0;
SQU_size = (SQU_Center select 1)*2 / (sqrt(3) + 3/5 + (sqrt(3)+1/5)*SQU_VerAmount*2);
SQU_HozAmount = round(((SQU_Center select 0)*2 - SQU_size*sqrt(3)*7/5) / SQU_size*5/18);
SQU_WallThickness = SQU_size/5;
SQU_MapMode = paramsArray select 1;
SQU_TownWin = paramsArray select 2;	
SQU_HexWin = paramsArray select 3;
LogisticStart = paramsArray select 7;
LogisticMax = paramsArray select 8;
LogisticSupply = paramsArray select 9;
PatrolPerc = (paramsArray select 10)/100;
SQU_NoMap = (paramsArray select 11)==1;
ForceSize = 10;

//--//
//Change this section to customize the sides and general feel of the mission
Attacker = 1;
Defender = 0;
Sides = [west, resistance];
//definition of equivalent static weapon for each side
//each sub array is an array of a type of static like: AA gun, or AT gun, or Mortar
SideStaticArr = [["",""],["",""],["",""],["",""]];
//note this is also used by the 'Recruit.sqf' to know which units to spawn
SidesAgents = [["LIB_GER_rifleman","LIB_GER_medic","LIB_GER_smgunner","LIB_GER_mgunner","LIB_GER_AT_soldier","LIB_GER_captain"],
	["LIB_US_rifleman","LIB_US_medic","LIB_US_smgunner","LIB_US_mgunner","LIB_US_AT_soldier","LIB_US_captain"]];
//--//
if (isserver) then {
	[Sides select Defender, paramsArray select 4] call BIS_fnc_respawnTickets;
	[Sides select Attacker, paramsArray select 5] call BIS_fnc_respawnTickets;
};

//generation constants
SQU_HexRadius = SQU_size+SQU_WallThickness*2;
SQU_capRad = SQU_HexRadius*3;
SQU_startX = SQU_HexRadius+SQU_WallThickness*sqrt(3)*2;
SQU_startY = SQU_HexRadius+SQU_WallThickness*2;
SQU_GameOn = true;
SQU_didJIP = false;
SQU_ServerDone = false;
SQU_ClientDone = false;
SQU_MapFinished = false;
SQU_TownDone = false;
SQU_id = [];
SQU_pvChangeHexSidePacket = [];
SQU_HexagonCoastalArray = [];
SQU_HexagonLocArray = [];
SQU_HexagonTownArray = [];											
SQU_HexagonsInDispute = [];	
SQU_numberOfTowns = 0;
SQU_numberOfTownsWin = 0;
SQU_numberOfHex = 0;
SQU_numberOfHexsWin = 0;

//variables that need to be sized according to sides
SQU_SideOwnedTownsNames = [];
SQU_SideOwnedResourceNames = [];
SQU_Base = [];
SQU_SideOwnedHex = [];
SQU_Frontlines = [];
SQU_Patrols = [];
AI_agents = [];

_i = 0;
while {_i < (count Sides)} do {
	SQU_SideOwnedTownsNames = SQU_SideOwnedTownsNames + [[]];
	SQU_SideOwnedResourceNames = SQU_SideOwnedResourceNames + [[]];
	SQU_Base = SQU_Base + [[]];
	SQU_SideOwnedHex = SQU_SideOwnedHex + [0];
	SQU_Frontlines = SQU_Frontlines + [[]];
	SQU_Patrols = SQU_Patrols + [0];
	AI_agents = AI_agents + [[]];
	_i = _i + 1;
};

//init
enableSaving [false,false];
enableTeamswitch false;

[] call BIS_fnc_showMissionStatus;
[] execVM "briefing.sqf";
[] execVM "plugins\rappelling\functions\fn_advancedSlingLoadingInit.sqf";

//generate map
(Sides select Defender) execVM "plugins\SQU\SQU_Init_Make_Hexagons.sqf";
waituntil{sleep 5; SQU_MapFinished};

if (!isDedicated) then {
	_didJIP = (isNull player);
	waitUntil{sleep 5; !isNull player};
};
//pass default side and array of towns
[] execVM "plugins\SQU\SQU_init_Towns.sqf";
waituntil{sleep 5; SQU_TownDone};
//done with map generation

if (isserver) then {
	SQU_ChangeHexSide = compileFinal preprocessFileLineNumbers "plugins\SQU\SQU_ChangeHexSide.sqf";
	[] execVM "plugins\SQU\SQU_MonitorAllUnits.sqf";
	[] spawn AI_spawnWave;

	SQU_onPlayerConnected = compileFinal preprocessFileLineNumbers "plugins\SQU\SQU_onPlayerConnected.sqf";
	SQU_onPlayerDisConnected = compileFinal preprocessFileLineNumbers "plugins\SQU\SQU_onPlayerDisConnected.sqf";	
	onPlayerConnected {[ _name, _uid, _id] spawn SQU_onPlayerConnected};
	onPlayerDisconnected {[ _name, _uid, _id] call SQU_onPlayerDisConnected};

	_commander = [] spawn {
		while{SQU_GameOn}do{
			_clk = time + 100;
			{/*Looping over all groups*/
				if (count (units _x) > 0)then{
					//give orders
					[_x, _clk] spawn AI_aiComm;
				}else{
					//cleanup
					deleteGroup _x;
				};
			}forEach allGroups;
			waitUntil {sleep 5; time > _clk};
		};
	};
};

if (!isDedicated) then {
	[] spawn {
		SQU_Init_JIP_Player = compile preprocessFileLineNumbers "plugins\SQU\SQU_Init_JIP_Player.sqf";
		if(SQU_didJIP)then
		{
			waitUntil{(count SQU_id) == 1};
			publicVariableServer "SQU_id";
			SQU_id = [];
			waitUntil{(count SQU_id) > 1};

			SQU_Base = SQU_id select 0;
			SQU_SideOwnedResourceNames = SQU_id select 1;
			SQU_SideOwnedHex = SQU_id select 2;
			SQU_SideOwnedTownsNames = SQU_id select 3;
		};
		if(SQU_didJIP)then{[]call SQU_Init_JIP_Player};
		SQU_ClientDone = true;
	};

	[player, [2, 2]] call plank_deploy_fnc_init;
};

fnDone = true;


//while{SQU_GameOn}do{
/*
{
	_x spawn{
		_snow = [];
		_pos = position _this;
		for "_i" from 0 to 1000 do {
			for "_j" from 0 to 1000 do {
				_spos = (_pos)vectorAdd( [(_i-500)*10, (_j-500)*10, 0] );
				_obj = "snow" createVehicle _spos;	
				_obj setVectorUp (surfaceNormal _spos);
				_snow = _snow + [_obj];
			};
		};
		sleep 30;
		{deleteVehicle _x}forEach _snow;
	};
}forEach allPlayers;
//*/
//};