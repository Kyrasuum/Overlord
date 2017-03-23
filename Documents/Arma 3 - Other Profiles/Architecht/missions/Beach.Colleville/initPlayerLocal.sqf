fnDone = false;
disableRemoteSensors true;
player allowDamage false;

////////////////////////////////////////////////////////////////////////////////////
//Intro
_intro =
{
	waitUntil {cutText ["Waiting for map to populate...","BLACK FADED"]; uiSleep 5; fnDone};
	uiSleep 5;
	cutText ["","BLACK FADED"];

	[
		[
			["Omaha Beach","<t align = 'center' shadow = '1' size = '1' font='PuristaBold'>%1</t><br/>"], 
			["THE FIRST DAY", "<t align = 'center' shadow = '1' size = '1.0'>%1</t><br/>"], 
			["Operation Overlord", "<t align = 'center' shadow = '1' size = '1.0'>%1</t>"]
		] , 0, 0.5, "<t align = 'center' shadow = '1' size = '1.0'>%1</t>"
	] spawn BIS_fnc_typeText;
	#define DELAY_CHARACTER	0.06;
	#define DELAY_CURSOR	0.04;

	uiSleep 10;
	cutText ["","BLACK IN"];
};
[] spawn _intro;	
player allowDamage true;
waituntil{sleep 5; fnDone};
////////////////////////////////////////////////////////////////////////////////////
//new key binds
waituntil {!isnull (finddisplay 46)};
eventOnKeyDown = compileFinal preprocessFileLineNumbers "scripts\eventOnKeyDown.sqf";
(findDisplay 46) displayAddEventHandler ["KeyDown", { _this call eventOnKeyDown; }];
//display logistics system
addMissionEventHandler ["Draw3D", {
	drawIcon3D ["", [1,0,0,1], player modelToWorld ( player selectionPosition "lefthand" ), 
		0, 0, 0, format["%1",player getVariable "Logistic"], 1, 0.05, "PuristaMedium"];
}];
//open menu
createDialog'RscDisplayServerInfoMenu';
////////////////////////////////////////////////////////////////////////////////////
//fastrope include
#include "plugins\rappelling\functions\SHK_Fastrope.sqf"
//Chemlights
0 = [true] execVM 'scripts\chemlights.sqf';  
// Initializes the player/client side Dynamic Groups framework
["InitializePlayer", [player]] call BIS_fnc_dynamicGroups;	
////////////////////////////////////////////////////////////////////////////////////
//Effects
"colorCorrections" ppEffectEnable true; 
"colorCorrections" ppEffectAdjust [1,1,0,[0.1,0.15,0.25,-0.41],[0.87,0.77,0.83,0.42],[0.5,0.2,0,1]];
"colorCorrections" ppEffectCommit 0;

"FilmGrain" ppEffectEnable true; 
"FilmGrain" ppEffectAdjust [0.1,1.5,1.7,0.2,1.0,true];
"FilmGrain" ppEffectCommit 0;
[] execVM "scripts\breathfog.sqf";
////////////////////////////////////////////////////////////////////////////////////
//Ambient Radio
[] spawn {
	while {SQU_GameOn} do
	{
		(0 fadeMusic 0.2);
		sleep random 300;
		[["RadioAmbient2", "RadioAmbient3", "RadioAmbient4", "RadioAmbient5", "RadioAmbient6", "RadioAmbient7", "RadioAmbient8", "RadioAmbient9", "RadioAmbient10", "RadioAmbient11", "RadioAmbient12", "RadioAmbient13", "RadioAmbient14", "RadioAmbient15", "RadioAmbient16", "RadioAmbient17", "RadioAmbient18", "RadioAmbient19", "RadioAmbient20", "RadioAmbient21", "RadioAmbient22", "RadioAmbient23", "RadioAmbient24", "RadioAmbient25", "RadioAmbient26", "RadioAmbient27", "RadioAmbient28", "RadioAmbient29", "RadioAmbient30"], 300] spawn BIS_fnc_music;
	};
};
//Ambient Sound
[] spawn {
	while {SQU_GameOn} do
	{
		_explosions = [
			"BattlefieldExplosions1_3D",
			"BattlefieldExplosions2_3D",
			"BattlefieldExplosions5_3D",
			"bariera_1",
			"bariera_2",
			"bariera_3",
			"bariera_4", 
			"bariera_5"
		];
		_fireFights = [
			"BattlefieldFirefight1_3D",
			"BattlefieldFirefight2_3D",
			"ground_air",
			"expozie"
		];

		playSound (_explosions call BIS_fnc_selectRandom);
		sleep random 30;
		playSound (_fireFights call BIS_fnc_selectRandom);
		sleep random 30;
	};
};