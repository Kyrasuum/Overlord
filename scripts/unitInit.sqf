//Suppression Mechanic
addMissionEventHandler ["Draw3D", {
		{
			_src = _x;
			{
				_proj = _x select 0;
				_ammo = _x select 1;
				_objs = _proj nearEntities [ "Man", 10 ];
				{
					//call on each object affected by projectile
					[[ [_proj, _ammo, _src, _x], {
						_this spawn {
							_proj = _this select 0;
							_ammo = _this select 0;
							_src = _this select 2;
							_unit = _this select 3;
							_cost = getNumber (configFile >> "CfgAmmo" >> _ammo >> "hit");
							if (isnil("_cost")) then {_cost = 1;};

							if (alive _unit && _unit != _src) then {
								if (isPlayer _unit) then {
									_addval = (1-(_unit getVariable "Suppression")) * 2.35^(1/log(1/_cost));
									_unit setVariable ["Suppression", ( (_unit getVariable "Suppression") + _addval)];
									_Suppress = _unit getVariable "Suppression";

									addCamShake [_Suppress*20, 0.1, 25];
									"ChromAberration" ppEffectEnable true;
									"ChromAberration" ppEffectAdjust [(_Suppress)/3, (_Suppress)/3,true];
									"ChromAberration" ppEffectCommit 0;

									sleep (_Suppress*_cost^2);
									_unit setVariable ["Suppression", ( (_unit getVariable "Suppression") - _addval)];
									if ((_unit getVariable "Suppression") < 0) then {_unit setVariable ["Suppression", 0];};
									_Suppress = _unit getVariable "Suppression";

									"ChromAberration" ppEffectEnable true;
									"ChromAberration" ppEffectAdjust [(_Suppress)/3, (_Suppress)/3,true];
									"ChromAberration" ppEffectCommit 0;
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
					}],"BIS_fnc_spawn", _x,false,true] call BIS_fnc_MP;
				}forEach _objs;
			}forEach (_src getVariable ["SQU_Projectiles",[]]);
		}forEach (AI_agents);
	}];

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
		[[ [_this select 0, _this select 2, 60, 180], "scripts\kp_fuel_consumption.sqf" ],"BIS_fnc_execVM", (_this select 0),false,true] call BIS_fnc_MP;
		/*[_this select 0, _this select 2, 60, 180] execVM "scripts\kp_fuel_consumption.sqf";*/}];
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
			_addval = 2.35^(1/log(1/_cost)) + (_unit getVariable "Suppression")*0.2;
			_unit setVariable ["Suppression", ( (_unit getVariable "Suppression") - _addval )];
			_Suppress = _unit getVariable "Suppression";
			"ChromAberration" ppEffectEnable true;
			"ChromAberration" ppEffectAdjust [(_Suppress)/3, (_Suppress)/3,true];
			"ChromAberration" ppEffectCommit 0;

			_projs = _unit getVariable "SQU_Projectiles";
			_projs = _projs + [_projectile, _ammo];
			_unit setVariable ["SQU_Projectiles", _projs];
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

	_this setVariable ["SQU_Projectiles", []];
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
					waitUntil { !(isNil {uiNamespace getVariable "SQU_RespawnLB"}) };
					_agent = (uiNamespace getVariable "SQU_RespawnLB");
					selectPlayer _agent;
					_agent spawn AI_initPlayer;
					sleep 1;
					cutText ["","BLACK IN"];//failsafe for singleplayer bug
				};
			};
		}],"BIS_fnc_spawn", (_this select 0),false,true] call BIS_fnc_MP;}];
	//cleanup after respawn hook
	_respawn = _this addEventHandler ["Respawn",{
		_this spawn {_unit = _this select 0;
		waitUntil {!isPlayer _unit};
		_unit setPos (position _unit vectorDiff [0,0,100]);
		_unit setDamage 1;
		deleteVehicle _unit;};
	}];	
	//wait until player is no longer this unit from disconnect or respawn
	waitUntil {sleep 5; !(isPlayer _this)};
	//cleanup our event handlers
	_this removeEventHandler ["Killed",_killed];
	_this removeEventHandler ["Respawn",_respawn];
};

AI_spawnWave = {
	while {SQU_GameOn} do {
		//remove dead agents from our array
		[] spawn {
			{
				_arr = _x;
				_i = _forEachIndex;
				{
				  	if (!alive _x)then{
						_arr = _arr - [_x];
						AI_agents set [ _i, _arr ];
					};
				} forEach _arr;
			} forEach AI_agents;
		};
		//for each side attempt to respawn a new wave of agents
		{
			_x spawn {
				//find how many units we have
				_side = _this; 
				_si = Sides find _side;
				_count = count (AI_agents select _si);
				//fill out the ranks
				while {_count < ForceSize} do {
					//check for tickets
					if ([_side] call BIS_fnc_respawnTickets > 0) then {
						//find position
						_locs = [];
						{
							if (!isNil {(missionNamespace getVariable _x)})then{
								_loc = missionNamespace getVariable _x;
								if (typeName _loc == "LOCATION") then {
									if (!isNil {(locationPosition _loc)}) then {
										_locs = _locs + [ locationPosition _loc ];
									};
								};
							};
						}forEach (SQU_SideOwnedResourceNames select _si);
						//decide if we should include base position
						if (count (SQU_Base select _si) > 0) then {
							_locs = _locs + [(SQU_Base select _si) select 1];
						};
						//only include land positions
						_positions = [];
						{
							if (count _x > 1 && typeName _x == "ARRAY")then{
								_pos = [_x, 1, SQU_capRad, 3, 0, 20, 0, [], [_x, _x]] call BIS_fnc_findSafePos;
								if (!(surfaceIsWater _pos))then {
									_positions = _positions + [_pos];
								};
							};
						}forEach _locs;
						//fix any errors in our output
						if(isNil "_positions" || count _positions < 1)then{_positions = [[]];};
						_pos = selectRandom _positions;
						if(count _pos == 2)then{_pos = [_pos select 0, _pos select 1, 0];};
						//check if we found a result
						if (count _pos == 3) then {
							//pick class
							_class = selectRandom(SidesAgents select _si);

							//make unit
							_agent = createAgent [_class,_pos,[],0,"NONE"];

							//seach for a group to join
							//finding nearby units
							_units = (nearestObjects [_pos,["Man"],SQU_HexRadius]);
							//sort to only friendlies and groups we have not found yet
							_groups = [];
							{
								if(side _x == _side && !(group _x in _groups)) then {
									_groups = _groups + group _x;
								};
							} forEach _units;

							_grp = grpNull;
							if (count _groups == 0) then {
								//if none found then create a new group
								_grp = createGroup _side;
								[_agent] join _grp;
								_grp selectLeader _unit;
							}else{
								//else select a random one to join
								_grp = selectRandom _groups;
								[_agent] join _grp;
							};
							addSwitchableUnit _agent;
							setPlayable  _agent;
							AI_agents set [ _si, (AI_agents select _si) + [_agent] ];

							[_side, -1] call BIS_fnc_respawnTickets;
							_agent call AI_initUnit;
						};
					};
					_count = _count + 1;
				};
			};
		}forEach Sides;
		sleep 60;//wave timer
	};
};