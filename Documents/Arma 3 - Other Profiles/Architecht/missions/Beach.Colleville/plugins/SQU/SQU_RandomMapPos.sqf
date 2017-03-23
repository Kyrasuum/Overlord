// Changed by Squeeze, get orginal here: https://dl.dropboxusercontent.com/u/96095460/ARMA3/randomMapPos.Stratis.rar
////////////////////////////////////////////////////////////////////////////////////////////////////////
// Author: Bruce Worrall  
///////////////////////////////////////////////////////////////////////////////////////////////////////
//
// [[Basics],[Whitelist],[Blacklist],[Elevation MIN, MAX], edge distance, Debug, limit]
//
// ["water", "land", "edge"]
//		Basics selections. "edge" is per Whitelist area. defaults to everywhere is a viable position
//
// ["MARKER NAME", OBJECT (trigger), ARRAY [[position3D], #radius]
//		White & Black lists. Supplying no Whitelists selects random position using whole map
//
// [MIN, MAX] - NUMBERS (optional)
//		Elevation range that position must be in. default -1000,1000 meters
//
// edge distance - NUMBER (optional)
//		Meters within edge of Whitelist areas to choose a position. default is 200m
//
// Debug - BOOL (optional)
//		Turns on debug markers and diag_log
//
//	limit - NUMBER (optional)
//		Number of attempts to find a position. Default 100. Use 0 to disable limit. 
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

/******************
***  Varaibles  ***
******************/

private ["_Basics",
			"_WL",
			"_BL",
			"_elevationRange",
			"_edgeDist",
			"_debug",
			"_elevationRangeMin",
			"_elevationRangeMax",
			"_GetWaterDepth",
			"_fnc_testMarker",
			"_vars",
			"_WL_Triggers",
			"_BL_Triggers",
			"_varname",
			"_worldTrig",
			"_posOK",
			"_randomMapPos",
			"_waterDepth",
			"_isWater",
			"_inElevationRange",
			"_inMap",
			"_randomWL",
			"_tempTrigs",
			"_trig",
			"_attempts",
			"_limit"];

/*** Params ***/
_Basics = [_this,0,[""],[""]] call BIS_fnc_param;
_WL = [_this,1,[],["",objNull,[]]] call BIS_fnc_param;
_BL = [_this,2,[],["",objNull,[]]] call BIS_fnc_param;
_elevationRange = [_this,3,[-1000,1000],[[]],[2]] call BIS_fnc_param;
_edgeDist = ([_this,4,200,[0]] call BIS_fnc_param) * -1;
_debug = [_this,5,false] call BIS_fnc_param;
_limit = [_this,6,100,[0]] call BIS_fnc_param;


/*** Others ***/
_elevationRangeMin = _elevationRange select 0;
_elevationRangeMax = _elevationRange select 1;
_WL_Triggers = [];
_BL_Triggers = [];
_tempTrigs = [];


/******************
***  Sort Lists ***
******************/

_vars = ["WL","BL"];
{
	_varname = _vars select _forEachIndex;
	{

		switch (typeName _x) do {
			//Markers
			case ("STRING"): {
				_trig = [objNull, _x] call BIS_fnc_triggerToMarker;
				call compile format ["_%1_Triggers set [count _%1_Triggers, _trig]",_varname];
				_tempTrigs set [count _tempTrigs, _trig];
			};
			//Triggers
			case ("OBJECT"): {
				if (_x isKindOf "EmptyDetector") then {
					call compile format ["_%1_Triggers set [count _%1_Triggers, _x]",_varname];
				};
			};
			//[pos, radius]
			case ("ARRAY"): {
				_trig = createTrigger["EmptyDetector",(_x select 0)];
				_trig setTriggerArea[(_x select 1), (_x select 1), 0, false];
				call compile format ["_%1_Triggers set [count _%1_Triggers, _trig]",_varname];
				_tempTrigs set [count _tempTrigs, _trig];
			};
			//default { //handle error msg// };
		};

	} forEach _x;
} forEach [_WL,_BL];
_fnc_testMarker ={
	private ["_passedPos","_color","_mrk"];
  _passedPos = _this select 0;
  _color = _this select 1;
  
  _mrk = createMarker [(format["%1",_passedPos]), _passedPos];
  _mrk setMarkerColor (_color);
  _mrk setMarkerBrush "Solid";
  _mrk setMarkerShape "ELLIPSE";
  _mrk setMarkerSize [4,4];
};
/**********************
***  Find position  ***
**********************/
_attempts = 0;

_posOK = false;

//set trig size of map
_worldTrig = call BIS_fnc_worldArea;

while {!(_posOK)} do {

	if ((count _WL_Triggers) > 0) then {
		_randomWL = (_WL_Triggers select (floor (random (count _WL_Triggers))));
	}else{
		_randomWL = _worldTrig;
	};
	
	_randomMapPos = _randomWL call BIS_fnc_randomPosTrigger;

	//Get elevation
	_waterDepth = [_randomMapPos] call SQU_GetWaterDepth;

	if (_waterDepth < 0) then {
		_isWater = true;
	}else{
		_isWater = false;
	};

	if ((_waterDepth > _elevationRangeMin) && (_waterDepth < _elevationRangeMax)) then {
		_inElevationRange = true;
	}else{
		_inElevationRange = false;
	};

	//Make sure position falls within map bounds
	_inMap = [_worldTrig, _randomMapPos] call BIS_fnc_inTrigger;

	//Check Basics
	if ({

		switch (toLower _x) do {

			case (""): {
				if (_inElevationRange && _inMap) then {true}
			};

			case ("water"): {
				if (_isWater && _inElevationRange && _inMap) then {true}
			};

			case ("land"): {
				if ((!_isWater) && _inElevationRange && _inMap) then {true}
			};

			case ("edge"): {
				if (([_randomWL, _randomMapPos, true] call BIS_fnc_inTrigger) > _edgeDist) then {
					if (_inMap) then {
						true
					}else{
						false
					};
				};

			};

		};
	} count _Basics == count _Basics) then {

		//Check BL Triggers
		if ({
				[_x,	_randomMapPos] call BIS_fnc_inTrigger
			} count _BL_Triggers == 0) then {

			//Position is GOOD
			_posOK = true;

			if (_debug) then {
				[_randomMapPos,"ColorGreen"] call _fnc_testMarker;
				diag_log format["passed : %1",_randomMapPos];
				diag_log format["attempts : %1",_attempts];
			};

		}else{ //Cascade of Debugs
			if (_debug) then {
				[_randomMapPos,"ColorBlack"] call _fnc_testMarker;
				diag_log format["failed BL : %1",_randomMapPos];
			};
		};
	}else{
		if (_debug) then {
			[_randomMapPos,"ColorBlack"] call _fnc_testMarker;
			diag_log format["failed Basics : %1",_randomMapPos];
		};
	};
	_attempts = _attempts +1;
	if ((_attempts > _limit) && (_limit > 0)) exitWith {
		//_msg = format["attempts to find a position exceeded %1, please reasses your areas", _limit];
		//diag_log _msg;
		//_msg call BIS_fnc_errorMsg;
		//hint _msg;
		_randomMapPos = [0,0,0];
	};		
};

//Clean up

//deleteVehicle _worldTrig;
{
	deleteVehicle _x;
} forEach _tempTrigs;

_randomMapPos