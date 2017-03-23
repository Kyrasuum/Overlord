/*
Name: SHPambientLightning
Author: Shpook
Purpose: Spawn lighting around a defined center, in a defined radius, at a defined random interval. There is a chance for lightning to strike buildings in the area.

Based on Bohemia's Zeus lightning function.

Parameters:
_center - OBJECT, MARKER, or POSITION. Marker must have quotes(""). Position must be array[]. Default is player.
_radius - Radius around center that lightning is randomly spawned. Default is 800 meters.
_interval - Maximum duration in which lightning strikes. Default is 60 seconds.

	_nul = [_center, _radius, _interval] execVM "scripts\SHPambientLightning.sqf";



Examples:

Spawn lightning with defaults of player center, 800m radius, and 60s interval:

	_nul = [] execVM "scripts\SHPambientLightning.sqf";

Spawn lightning with transportHelicopter as center, 300m radius, and 20s interval:

	_nul = [transportHelicopter, 300, 20] execVM "scripts\SHPambientLightning.sqf";

Spawn lightning with marker as center, 500m radius, and default interval:

	_nul = ["lightningCenter", 500] execVM "scripts\SHPambientLightning.sqf";

Spawn lightning with position array as center, default radius, and default interval:

	_nul = [[2482.0117,32.202206,22100.438]] execVM "scripts\SHPambientLightning.sqf";



To stop the lightning script, type the following in a trigger or script:

	SHPLightningRun = false;
	publicVariable "SHPLightningRun";


TODO:

May not work properly in multiplayer


Changelog:

(7/11/2014) v1.0 - Initial release.
(7/12/2014) v1.1 - Added chance of building and structure strikes.
				   Added check variable to allow loop cancellation.
				   Fixed a bug preventing the center from following a moving player or object.



*/


_center = [_this, 0, player, ["", [], objNull], [3]] call BIS_fnc_param;
_radius = [_this, 1, 800, [0]] call BIS_fnc_param;
_interval = [_this, 2, 60, [0]] call BIS_fnc_param;

_strikeCenter = [];
_currentTarget = "";
SHPLightningRun = true;
publicVariable "SHPLightningRun";
_centerPos = [];

while {SHPLightningRun} do {
	if (typename _center == "STRING") then {_centerPos = markerpos _center};									// Check if _center is marker or object, get position.
	if (typename _center == "OBJECT") then {_centerPos = position _center};

	sleep random _interval;																						// Sleep defined by _interval.

	_randomx = (_centerPos select 0) + (_radius - (random (2*_radius)));										// Randomize _center X and Y axis.
	_randomY = (_centerPos select 1) + (_radius - (random (2*_radius)));
	_strikeCenter = [_randomx, _randomY, (_centerPos select 2)];

	_dir =random 360;

	_bolt = createvehicle ["LightningBolt",_strikeCenter,[],0,"can collide"];								// Create lightning sound and destruction.
	_bolt setposatl _strikeCenter;
	_bolt setdamage 1;																						// SetDamage required for proper lightning effect. Also does damage to strike location.

	_light = "#lightpoint" createvehiclelocal _strikeCenter;												// Create light flash effect.
	_light setposatl [_strikeCenter select 0,_strikeCenter select 1,(_strikeCenter select 2) + 10];
	_light setLightDayLight true;
	_light setLightBrightness 300;
	_light setLightAmbient [0.05, 0.05, 0.1];
	_light setlightcolor [1, 1, 2];
	sleep 0.1;
	_light setLightBrightness 0;
	sleep (random 0.1);

	_class = ["lightning1_F","lightning2_F"] call bis_Fnc_selectrandom;										// Choose and create visible lightning bolt object.
	_lightning = _class createvehiclelocal [100,100,100];
	_lightning setdir _dir;
	_lightning setpos _strikeCenter;

	_duration = random 2;																					// Keep bolt on screen for random duration. Also adds a second flash of light for a bit more realism.
	for "_i" from 0 to _duration do {
		_time = time + 0.1;
		_light setLightBrightness (100 + random 100);
		waituntil {time > _time};
	};
	deletevehicle _lightning;																				// Delete lightning bolt and light object.
	deletevehicle _light;
};