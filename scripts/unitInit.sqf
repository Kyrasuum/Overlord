//Initialize unit with handlers and variables needed on all active units
AI_initUnit = {
	//stop picking up additional magazines
	_this addEventHandler ["Take",{
		_unit = _this select 0;
		_cont = _this select 1;
		_item = _this select 2;

		if (_item == "ItemMap" || _item == "FirstAidKit" || _item == "Medikit") then {
			_unit unassignItem _item;
			_unit removeItem _item;
		};
	}];
	//fuel overhaul
	_this addEventHandler ["GetInMan", { 
		[[ [_this select 0, _this select 2, 60, 180], KP_Fuel ],"BIS_fnc_spawn", (_this select 0),false,true] call BIS_fnc_MP;
    }];
	//ammo system
	_this addEventHandler ["Fired",{
		[[ _this, {
			_unit = _this select 0;
			_ammo = _this select 4;
			_mag = _this select 5;
			_projectile = _this select 6;
			_cost = getNumber (configFile >> "CfgAmmo" >> _ammo >> "hit");
			if (isnil("_cost")) then {_cost = 1;};

			//throw ammo
			if ((_this select 1) == "Throw" && missionNamespace getVariable ["DE_var_throwMag", ""] != "") then
			{
				_pos = getPosATL _projectile;
				_vel = velocity _projectile;
				_obj = createVehicle ["WeaponHolderSimulated", _pos, [], 0, "CAN_COLLIDE"];
				_obj addMagazineAmmoCargo [DE_var_throwMag, 1, 30];
				//player removeItem DE_var_throwMag;
				_obj setVelocity _vel;
				deleteVehicle _projectile;

				_num = missionNamespace getVariable ["DE_var_throwEvents", 0];
				_event = "DE_throwEvent_" + (str _num);
				[_event, "onEachFrame",
				{
					_near = (nearestObjects [_this select 1, ["MAN"], 3]) - [player];
					if (count _near > 0) then
					{
						[_this select 0, "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
						deleteVehicle (_this select 1);
						//(_near select 0) addMagazine [_this select 2, 30];
					};
					if (speed (_this select 1) == 0) then
					{
						[_this select 0, "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
					};
				}, [_event, _obj, DE_var_throwMag]] call BIS_fnc_addStackedEventHandler;
				DE_var_throwEvents = _num + 1;
				DE_var_throwMag = "";
			}else{
				//suppression mechanic
				_num = missionNamespace getVariable ["SQU_ProjEvents", 0];
				_event = "SQU_ProjEvents" + (str _num);
				[_event, "onEachFrame",
				{
					_proj = _this select 0;
					_ammo = _this select 1;
					_src = _this select 2;
					_cost = getNumber (configFile >> "CfgAmmo" >> _ammo >> "hit");
					if (isnil("_cost")) then {_cost = 1;};

					_near = (nearestObjects [_this select 0, ["MAN"], 20]);
					{
						_unit = _x;
						if (alive _unit && _unit != _src) then {
							if (isPlayer _unit) then {
								_addval = (1-(_unit getVariable "Suppression")) * 2.35^(1/log(1/_cost));
								_unit setVariable ["Suppression", ( (_unit getVariable "Suppression") + _addval)];
								_Suppress = _unit getVariable "Suppression";

								addCamShake [_Suppress*20, 0.1, 25];
								"ChromAberration" ppEffectEnable true;
								"ChromAberration" ppEffectAdjust [(_Suppress)/3, (_Suppress)/3,true];
								"ChromAberration" ppEffectCommit 0;

								[_unit, _cost, _addval, _Suppress] spawn {
									_unit = _this select 0;
									_cost = _this select 1;
									_addval = _this select 2;
									_Suppress = _this select 3;

									sleep (_Suppress*_cost^2);
									_unit setVariable ["Suppression", ( (_unit getVariable "Suppression") - _addval)];
									if ((_unit getVariable "Suppression") < 0) then {_unit setVariable ["Suppression", 0];};
									_Suppress = _unit getVariable "Suppression";

									"ChromAberration" ppEffectEnable true;
									"ChromAberration" ppEffectAdjust [(_Suppress)/3, (_Suppress)/3,true];
									"ChromAberration" ppEffectCommit 0;
								};
							}else{
								//validity checks
								if (vehicle _unit == _unit && (_unit getVariable "Suppression") > 5) then {
									[_unit,_cost] spawn {
										_unit = _this select 0;
										_cost = _this select 1;

										//suppress
										_addval = (1-(_unit getVariable "Suppression")) * 2.35^(1/log(1/_cost));
										_unit setVariable ["Suppression", ( (_unit getVariable "Suppression") + _addval)];

										//lower stance
										_stances = ["Up","Middle","Down"];
										_stance = unitPos _unit;
										if (_stance != _stances select 2) then {
											_unit setUnitPos (_stances select ((_stance find _stance) +1));
										};

										[_unit, _cost, _addval, _stance] spawn {
											_unit = _this select 0;
											_cost = _this select 1;
											_addval = _this select 2;
											_stance = _this select 3;

											sleep _cost;
											//return to original stance
											_unit setUnitPos _stance;

											_unit setVariable ["Suppression", ( (_unit getVariable "Suppression") - _addval)];
											if ((_unit getVariable "Suppression") < 0) then {_unit setVariable ["Suppression", 0];};
										};
									};
								};
							};
						};
					}forEach _near;

					if (speed (_this select 0) <= 0) then
					{
						[_this select 3, "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
					};
				}, [_projectile, _ammo, _unit, _event]] call BIS_fnc_addStackedEventHandler;
				SQU_ProjEvents = _num + 1;
			};
			//prevent magazine exploits
			_mags = [];
			{
			   	if (_x in _mags) then{
			   		_unit removeMagazine _x;
			   	}else{
			   		_mags = _mags + [_x];
				};
			} forEach magazines _unit;

			_newLogistic = round( (_unit getVariable "Logistic")-1);
			//_newLogistic = round( (_unit getVariable "Logistic")-_cost);
			if ({_x isEqualTo _mag} count magazines _unit < 1 && _newLogistic >= 0) then 
			{ 
				_unit addMagazines [_mag, 1];
				//subtract logistic points
				_unit setVariable ["Logistic", _newLogistic];
			}; 
			//firing lowers suppression
			// _addval =  (_unit getVariable "Suppression") * 2.35^(1/log(1/_cost));
			// _unit setVariable ["Suppression", ( (_unit getVariable "Suppression") - _addval )];
			// _Suppress = _unit getVariable "Suppression";
			// "ChromAberration" ppEffectEnable true;
			// "ChromAberration" ppEffectAdjust [(_Suppress)/3, (_Suppress)/3,true];
			// "ChromAberration" ppEffectCommit 0;
		}],"BIS_fnc_spawn", (_this select 0),false,true] call BIS_fnc_MP;}];
	//suppression

	group _this allowFleeing 0;
	_this disableAI "SUPPRESSION"; 
	_this disableAI "AIMINGERROR"; 
	_this disableAI "fsm"; 
	_this setSkill ["aimingAccuracy", 9999.0];
	_this setSkill ["aimingShake", 9999.0];
	_this setSkill ["aimingSpeed", 9999.0];
	_this setSkill ["commanding", 9999.0];
	_this setSkill ["courage", 9999.0];
	_this setSkill ["endurance", 9999.0];
	_this setSkill ["general", 9999.0];
	_this setSkill ["reloadSpeed", 9999.0];
	_this setSkill ["spotDistance", 9999.0];
	_this setSkill ["spotTime", 9999.0]; 	

	_this setVariable ["Suppression", 0];//suppression init
	_this setVariable ["Logistic", LogisticStart];//logistic init
	_this unassignItem "FirstAidKit";
	_this removeItems "FirstAidKit";
	_this unassignItem "Medikit";
	_this removeItems "Medikit";
	_this enableStamina false;

	//remove extra magazines
	_mags = [];
	{
	   	if (_x in _mags) then{
	   		_this removeMagazine _x;
	   	}else{
	   		_mags = _mags + [_x];
		};
	} forEach magazines _this;
	//revive system
	[_this] call compile preprocessFile (TCB_AIS_PATH + "init_ais.sqf");
};
//Initialize unit with handlers and variables needed on players only
AI_initPlayer = {
	//try to force initializing value
	[[ _this, {
		uiNamespace setVariable ["SQU_Side", side player];
	}],"BIS_fnc_spawn", _this,false,true] call BIS_fnc_MP;
	//respawn menu hook
	_killed = _this addEventHandler ["killed",{	
		[[ _this,{
			_this spawn {
				uiNamespace setVariable ["SQU_RespawnLB", nil];
				(uiNamespace getVariable ["SQU_Side", selectRandom Sides]) spawn SQU_openRespawnMenu;
				player spawn {
					waitUntil { sleep 2; !(isNil {uiNamespace getVariable "SQU_RespawnLB"}) };
					sleep 2;
					_agent = (uiNamespace getVariable "SQU_RespawnLB");

					_pos = [position _agent, 1, 50, 3, 0, 20, 0] call BIS_fnc_findSafePos;

					//pick class
					_class = selectRandom(SidesAgents select _si);

					//make unit
					_ply = createAgent [_class,_pos,[],0,"NONE"];

					addSwitchableUnit _ply;
					setPlayable  _ply;

					[_side, -1] call BIS_fnc_respawnTickets;
					_ply call AI_initUnit;

					selectPlayer _ply;
					_ply spawn AI_initPlayer;
				};
			};
		}],"BIS_fnc_spawn", (_this select 0),false,true] call BIS_fnc_MP;}];
	//cleanup after respawn hook
	_respawn = _this addEventHandler ["Respawn",{
		_this spawn {_unit = _this select 0;
		waitUntil { sleep 5; !isPlayer _unit};
		_unit setPos (position _unit vectorDiff [0,0,100]);
		_unit setDamage 1;
		deleteVehicle _unit;};
	}];
	//add support requests
	_arty = [_this, "Support_Artillery",nil,nil,""] call BIS_fnc_addCommMenuItem;
	//wait until player is no longer this unit from disconnect or respawn
	waitUntil {sleep 5; !(isPlayer _this)};
	//cleanup our event handlers
	_this removeEventHandler ["Killed",_killed];
	_this removeEventHandler ["Respawn",_respawn];
};
//Function to attempt spawning the next wave of units for each side.
AI_spawnWave = {
	//for each side attempt to respawn a new wave of agents
	{
		//find how many units we have
		_side = _x; 
		_si = Sides find _side;
		_count = count (AI_Groups select {side _x == _side});
		//fill out the ranks
		while {_count < ForceSize} do {
			//check for tickets
			if ([_side] call BIS_fnc_respawnTickets > 0) then {
				//find valid locations
				_locs = (SQU_SideOwnedResourceNames select _si) select { typeName (missionNamespace getVariable _x) == "LOCATION" };
				_locs = ((_locs apply { missionNamespace getVariable _x }) select { !isNil{ locationPosition _x } }) apply { locationPosition _x };
				//decide if we should include base position
				if (count (SQU_Base select _si) > 0) then {
					_locs = _locs + [(SQU_Base select _si) select 1];
				};
				//validate
				_locs = (_locs select { count _x > 1 }) select { typeName _x == "ARRAY" };
				//only include land positions
				_positions = (_locs apply { [_x, 1, SQU_capRad, 3, 0, 20, 0, [], [_x, _x]] call BIS_fnc_findSafePos }) select { !surfaceIsWater _x };

				//fix any errors in our output
				if(isNil "_positions" || count _positions < 1)then{_positions = [[]];};
				_pos = selectRandom _positions;
				if(count _pos == 2)then{_pos = [_pos select 0, _pos select 1, 0];};
				//check if we found a result
				if (count _pos == 3) then {
					_grp = [_pos, _side, SidesAgents select _si] call BIS_fnc_spawnGroup;
					
					//initialize the units
					{
						_x call AI_initUnit;
						[_side, -1] call BIS_fnc_respawnTickets;
					}forEach units _grp;
				};
				AI_Groups = AI_Groups + [_grp]
			};
			_count = _count + 1;
		};
	}forEach Sides;
};