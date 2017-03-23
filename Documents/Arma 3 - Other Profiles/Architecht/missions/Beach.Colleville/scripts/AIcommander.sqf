//Takes a position to start from and a position you want cover from
//this returns a position that is behind cover
AI_findCover = {
	_pos = _this select 0;
	_direc = _this select 1;
	//this gives us the yaw direction of our direction
	_target = atan( (_direc select 0)/(_direc select 1) );
	_dist = 50;
	//search for cover
	_possibles = nearestObjects [_pos, [], _dist];
	_cover = objNull;
	{
		//setup initial choice
		if (_cover == objNull) then {
			_cover = _x;
		}else{
			//prioritize closest building
			if (_x isKindOf "House" || _x isKindOf "Building")then{
				if (_cover isKindOf "House" || _cover isKindOf "Building" && 
					_pos distance (position _cover) > _pos distance (position _x) ) then {
					_cover = _x;
				}else{
					_cover = _x;
				};
			}else{
				//keep building if already found
				if (_cover isKindOf "House" || _cover isKindOf "Building" || _x isKindOf "Man")then{
				}else{
					//find closest possible cover
					if (_pos distance (position _cover) > _pos distance (position _x))then{
						_cover = _x;
					};
				};
			};
		};
	}forEach _possibles;


	_movePos = _pos;//failsafe
	if (!isNil"_cover") then {
		if (_cover isKindOf "House" || _cover isKindOf "Building")then{
			//select building position
			//we want to find position closest to enemy with height being weighted
			_j = 0;
			_posAct = _cover buildingPos _j;
			//_posAct is internal building position being tested
			while {((_posAct distance [0,0,0]) > 0)}do{	
				//check if a good location by compairing to '_target' our engagement direction
				_dist1 = _direc distance _posAct;
				if (_dist1 < _dist) then {
					_movePos = _posAct;
					_dist = _dist1;
				};
				//test next set
				_j = _j + 1;
				_posAct = _cover buildingpos _j;
			};
		}else{
			//find position along cover
			//find position opposite enemy and then verify if free of obstructions
			
			//first find how far away from the prop would be valid
			_bbr = boundingBoxReal _cover;
			_p1 = _bbr select 0;
			_p2 = _bbr select 1;
			_maxWidth = abs ((_p2 select 0) - (_p1 select 0));
			_maxLength = abs ((_p2 select 1) - (_p1 select 1));

			//trig to find how far of an offset we need given our bounding box
			_dist = tan( _target%90 ) * ( [_maxLength,_maxWidth] select ( floor(_target/45) %2) );
			//now we find the position that is _dist far away and opposite from our _target
			_ang = (_target +180 -(direction _cover) +360) %360;
			_movePos = _cover getRelPos [_dist, _ang];

			//now we are going to perform a final check to make sure we are safe
			_j = 1;
			_posAct = [_movePos, 0, _j, 1, 0, 20, 0] call BIS_fnc_findSafePos;
			//verify it meets criteria
			while {_posAct isEqualTo getArray(configFile >> "CfgWorlds" >> worldName >> "centerPosition")}do{
				_j = _j + 1;
				_posAct = [_movePos, 0, _j, 1, 0, 20, 0] call BIS_fnc_findSafePos;
			};

			//now that our position is 'safe' we can continue
			_movePos = _posAct;
		};
	};
	_movePos
};

//Takes a group and requested type as parameters
//types: "COAST" or "any", "LAND", "WATER", "PLANE"
//searches for a vehicle that the group can enter
AI_findVeh = {
	_grp = _this select 0;
	_type = _this select 1;
	_veh = objNull;

	if (!isNil("_grp") && !isNil("_type"))then{
		_unit = leader _grp;
		_pos = position _unit;
		switch (_type) do { 
			case "any" : {_type = ["LandVehicle","Ship","Plane"];}; 
			case "COAST" : {_type = ["LandVehicle","Ship","Plane"];}; 
			case "LAND" : {_type = ["LandVehicle"];}; 
			case "WATER" : {_type = ["Ship"];}; 
			case "PLANE" : {_type = ["Plane"];}; 
			default {_type = [];}; 
		};
		//check if we can board a vehicle first... do this check to avoid relatively expensive 'near' check
		if( (vehicle _unit) == _unit )then{
			_list = _pos nearEntities [_type,SQU_capRad*3];
			if(count _list != 0)then{
				{//we have a vehicle
					if ((({alive (_x select 0)} count fullCrew[_x,"",false]) + (count(units _grp))) <= (count fullCrew[_x,"",true]))exitWith{
						//there is room for us
						_veh = _x;
					};
				}forEach _list;
			};
		};
	};
	_veh
};

//Takes a group and vehicle as parameters
//makes the group board into the vehicle prioritzing non cargo slots
AI_boardVeh = {
	_grp = _this select 0;
	_veh = _this select 1;

	if (!isNil("_grp")&&!isNil("_veh"))then{
		{
			if (!isPlayer _x) then {
				if (_veh emptyPositions "Driver" > 0) then {
					//Driver
					_x moveInDriver _veh;
				}else{
					if (_veh emptyPositions "Gunner" > 0) then {
						//Gunner
						_x moveInGunner _veh;
					}else{
						if (_veh emptyPositions "Commander" > 0) then {
							//Commander
							_x moveInCommander _veh;
						}else{
							//cargo
							_x moveInCargo _veh;
						};
					};
				};
			};
		}forEach (units _grp);
	};
};

//Takes a starting pos/hex, ending pos/hex, a hex type ("LAND","WATER","ANY"), and a optional filter [locations]
//This is a recursive function that looks for a valid path to a destination
AI_findPath = {
	_objHex = (_this select 0);//our starting hex or a position
	_objDest = (_this select 1);//the hex we are trying to path to
	_type = (_this select 2);//valid types of hex.  valid entries are "LAND", "WATER", "ANY"
	_FindFilter = (_this select 3);//filters out hexes we have already seen
	_ret = false;
	_hex = objNull;
	_dest = objNull;

	if(isNil("_FindFilter")) then {
		_FindFilter = [];
	};

	if(!isNil("_FindFilter") && !isNil("_objHex") && !isNil("_objDest") && !isNil("_type")) then {
		//convert obj to a hex
		if (typeName _objHex == "ARRAY")then{
			_hex = _objHex call SQU_Find_Loc;
		}else{
			_hex = _objHex;
		};
		if (typeName _objDest == "ARRAY")then{
			_dest = _objDest call SQU_Find_Loc;
		}else{
			_dest = _objDest;
		};
		//format our type filter
		switch (_type) do { 
			case "LAND" : {_type = ["LAND","COAST"];}; 
			case "WATER" : {_type = ["WATER","COAST"];}; 
			case "ANY" : {_type = ["ANY","LAND","WATER","COAST"];}; 
			default {_type = [""];}; 
		};
		//all data is valid... attempt resolving
		//find neighboring hexes
		_StrLocs = [_hex] call SQU_ReturnNeighbours;
		_locs = [];
		{
			if (!isNil{missionNamespace getVariable [_x,nil]} && (missionNamespace getVariable _x)getVariable "SQU_HexType" in _type) then {
				_locs = _locs + [missionNamespace getVariable _x];
			};
		} forEach _StrLocs;

		//remove any previously seen hexes and add our current to filter
		_locs = [_locs,[locationposition _dest],{_input0 distance (locationposition _x)},"ASCEND"] call BIS_fnc_sortBy;
		_locs = _locs - _FindFilter;
		_FindFilter = _FindFilter + _locs;
		//check if we have any neighbors
		if (count _locs > 0) then {
			//sort by distance
			//check if we reached destination
			if (_dest in _locs || _hex == _dest) then {
				//we found destination... unwind the stack
				_ret = true;
			}else{
				//if we havent found our destination yet then recurse
				{ if (!_ret) then {_ret = ([_x,_dest,(_type select 0),_FindFilter] call AI_findPath); }; }forEach _locs;
			};
		}else{
			_ret = false;
		};
	};
	_ret
};

//Takes a starting pos/hex, a hex type ("LAND","WATER","ANY"), and a optional filter [locations]
//This is a recursive function that checks if we have any paths to hexes which are not of the same side
AI_pathExists = {
	_objHex = (_this select 0);//our starting hex or a position
	_type = (_this select 1);//valid types of hex.  valid entries are "LAND", "WATER", "ANY"
	_FindFilter = (_this select 2);//filters out hexes we have already seen
	_ret = false;
	_hex = objNull;
	_dest = objNull;

	if(isNil("_FindFilter")) then {
		_FindFilter = [];
	};

	if(!isNil("_FindFilter") && !isNil("_objHex") && !isNil("_type")) then {
		//convert obj to a hex
		if (typeName _objHex == "ARRAY")then{
			_hex = _objHex call SQU_Find_Loc;
		}else{
			_hex = _objHex;
		};
		//format our type filter
		switch (_type) do { 
			case "LAND" : {_type = ["LAND","COAST"];}; 
			case "WATER" : {_type = ["WATER","COAST"];}; 
			case "ANY" : {_type = ["ANY","LAND","WATER","COAST"];}; 
			default {_type = [""];}; 
		};
		//all data is valid... attempt resolving
		//find neighboring hexes
		_StrLocs = [_hex] call SQU_ReturnNeighbours;
		_locs = [];
		{
			if (!isNil{missionNamespace getVariable _x}) then {
				_locs = _locs + [missionNamespace getVariable _x];
			};
		} forEach _StrLocs;

		//remove any previously seen hexes and add our current to filter
		_locs = _locs - _FindFilter;
		_FindFilter = _FindFilter + _locs;
		//check if we have any neighbors
		if (count _locs > 0) then {
			//only look at valid types of hexes
			_locs = [_locs,[_type],{_x},"ASCEND",{(_x getVariable "SQU_HexType") in _input0}] call BIS_fnc_sortBy;
			//check if any neighbors have a different side
			{ 
				if(_x getVariable "SQU_HexSide" != _hex getVariable "SQU_HexSide" || [_hex,_type,_FindFilter] call AI_pathExists)exitWith{_ret = true;}
			}forEach _locs;
		}else{
			_ret = false;
		};
	};
	_ret
};

//handle commands within group
//this does the individual unit movement
AI_squadCom = {
	// order types we need to handle:
	// attack/ambush (SAD or HOLD/SENTRY)
	// garrison/patrol (GUARD/SUPPORT)
	// take town/territory (MOVE)
	// entering / exiting vehicles (GETIN/GETOUT)
	_clk = time + 90;
	_grp = _this select 0;
	_order =  _this select 1;
	while {time < _clk} do {
		//check if we have atleast one unit alive
		_grpAlive = false;
		if ({alive _x} count units _grp > 0) then {_grpAlive = true;};
		//if none are alive exit
		if (!_grpAlive) exitWith {
			//removing previous assignments
			if (waypointType _order == "SUPPORT") then { SQU_Patrols set [_si, (SQU_Patrols select _si) - 1]; };
			if (waypointType _order == "GUARD") then { ((position _order) call SQU_Find_Loc) setVariable ["SQU_Garrison", nil]; };
			deleteWaypoint [_grp, currentWaypoint _grp];//cleaning up our waypoint
		};

		_ldr = leader _grp;
		_pos = position _ldr;
		_movePos = _pos;
		/*loop over all units in group*/{
			_unit = _x;
			if (alive _unit && !isPlayer _unit) then {
				//prevent crappy unit formations
				//if (unitReady _unit) then {doStop _unit;};
				//used to assault location or simply change position
				if (waypointType _order == "MOVE") then {
					//switch speed based on distance and enemies
					if (waypointPosition _order distance (position _unit) < SQU_HexRadius || 
						(position (_unit findNearestEnemy _unit)) distance (position _unit) < SQU_HexRadius*3 ) then {
						//either close to target or enemies engaged
						_order setWaypointSpeed "LIMITED";
						_order setWaypointBehaviour "COMBAT";
						_order setWaypointType "SAD";
					}else{
						_order setWaypointSpeed "FULL";
						_order setWaypointBehaviour "AWARE";
						if (_unit == _ldr && vehicle _unit == _unit) then {
							//we are squad leader and we are not already in a vehicle
							_veh = [_grp, (_pos call SQU_Find_Loc) getVariable "SQU_HexType"] call AI_findVeh;
							//check if we found a vehicle
							if (_veh != objNull) then {
								//board vehicle
								_newOrder = _grp addWaypoint [position _veh, 0];
								_newOrder setWaypointType "GETIN";
								_newOrder waypointAttachVehicle _veh;
								_grp setCurrentWaypoint _newOrder;
							};
						};
					};
					if (vehicle _unit == _unit) then {
						//infantry movement
						if (_unit == _ldr) then {
							//move to point
							_movePos = waypointPosition _order;
							_unit doMove _movePos;
						}else{
							//follow the leader
							_unit doFollow _ldr;
						};
					}else{
						//in vehicle
						if (driver vehicle _unit == _unit) then {
							//drive baby drive
							_movePos = waypointPosition _order;
							_unit doMove _movePos;
						}else{
							//we are a passenger
						};
					};
				};
				//engage enemy defensively and offensively
				if (waypointType _order == "SAD" || waypointType _order == "HOLD" || waypointType _order == "SENTRY") then {
					_unit setSpeedMode "full"; 
					_unit setbehaviour "combat";
					if (waypointType _order == "SENTRY") then {
						//AMBUSH!!!!!... setup a defensive location at our order position
						_pos = waypointPosition _order;
					}else{
						_pos = position _unit;
					};
					//find enemy directions
					_target = [];
					{
						if (_x != side _unit) then {
							_targets = _unit targetsQuery [objNull, _x, "", [], 10];
							{
								_dist1 = (position _unit) distance (_pos);
								if (_dist1 < SQU_HexRadius*3) then {
									_target = _target + [[_pos, _x select 4] call BIS_fnc_dirTo];
								};
							}forEach _targets;
						};
					} forEach Sides;	
					//find average enemy direction
					if (count _target > 0) then {
						_t = 0;
						{
							_t = _t + _x;
						}forEach _target;
						//now we have the enemies direction
						_target = _t / count(_target);
					}else{
						//if no enemies known give a random direction
						_target = random(360);
					};
					_direc = _pos getPos [SQU_HexRadius,_target];

					//handle infantry
					if (vehicle _unit == _unit) then{
						_cover = (_unit nearEntities 20) select 0;
						if (_unit distance _cover > sizeOf(typeOf _cover)+10) then {
							//search for statics
							_list = _pos nearObjects ["StaticWeapon", 300];
							_staticWeapons = [];

							/*searching for valid statics*/{
								if ((_x emptyPositions "gunner") > 0) then {
									_staticWeapons pushBack _x;	
									};
							}forEach _list;

							//if we have a static available then prioritze taking it
							if (count _staticWeapons > 0)then{
								_unit assignAsGunner (_staticWeapons select 0);
								[_unit] orderGetIn true;
							}else{
								_movePos = [_pos,_direc] call AI_findCover;
								//our movepos is now a valid position behind cover so we can move to our new cover position
								_unit doMove _movePos;
							};
						}else{//already in cover
							_unit doWatch _direc;
							if (waypointType _order == "SAD") then{
								//be aggressive
								_target = _unit findNearestEnemy _unit;
								_unit doTarget _target;
								_unit doFire _target;
								//check if we are effective... if not switch waypoint to HOLD
								if (_unit getVariable "Suppression" > 0.5) then {
									_order setWaypointType "HOLD";
								};
							}else{
								//be defensive
								_target = _unit findNearestEnemy _unit;
								_unit doTarget _target;
								//throw grenades
								_mags = magazinesDetail _unit;
								_grens = [];
								{
									_mag = _x splitString "([ ]/:)";
									if ("Grenade" in _mag) exitWith {
										_unit action ["UseMagazine", _unit, _unit, 0, _mag select ((count _mag)-1)];
									};
								}forEach _mags;
								//suppress enemies for friendlies
								_unit doSuppressiveFire _target;
								//request support
								[_direc,side _ldr] execVM "scripts\objArty.sqf";
								//check if we are effective... if so switch waypoint to SAD
								if (_unit getVariable "Suppression" < 0.5) then {
									_order setWaypointType "SAD";
								};
							};
						};
					}else{//handle vehicles
						_veh = vehicle _unit;
						if (_veh isKindOf "LandVehicle") then {
							//disembark if we are non critical personel or no guns are manned/available
							if ((count(fullCrew[_veh, "gunner", false])+count(fullCrew[_veh, "turret", false])) == 0 
								|| _unit in fullCrew[_veh, "cargo", false] ) then {
								unassignVehicle _unit;
								doGetOut _unit;
							};
						};
						//decide if we should be aggressive
						if (waypointType _order == "SAD") then {
							//set our movepos at the enemy center
							_movePos = _direc;
							_unit doWatch _direc;
							//check if we are effective... if not switch to HOLD
							if (_unit getVariable "Suppression" > 0.5) then {
								_order setWaypointType "HOLD";
							};
						}else{
							//set our movepos to be a retreat
							_movePos = getPos [100,_target+180];
							//request support
							[_direc,side _ldr] execVM "scripts\objArty.sqf";
							//check if we are effective... if so switch to SAD
							if (_unit getVariable "Suppression" < 0.5) then {
								_order setWaypointType "SAD";
							};
						};
						if (driver _veh == _unit) then {
							//move towards ordered movepos
							_unit doMove _movePos;
						};
					};
					//check if engagement is over... if so change to move
					if ( {alive (_x select 1)} count (_unit targetsQuery [objNull, sideUnknown, "", [], 60]) > 0 ) then {
						_order setWaypointType "MOVE";
					};
				};
				//we are a patrol unit... move along frontline and await support request
				if (waypointType _order == "SUPPORT") then {
					_pos = waypointPosition _order;

					_ldr = leader group _unit;
					if (_ldr == _unit) then {
						_target = [];//initialize it
						if (isnil {_unit getVariable "PatrolTarget"}) then {
							//no patrol target set... we will make one
							_target = [ ["land"],[_pos, SQU_capRad],[],[0,99999],0,false,500 ] call SQU_RandomMapPos;
							_unit setVariable ["PatrolTarget",_target];
						}else{
							//retrieve our patrol target
							_target = _unit getVariable "PatrolTarget";
						};

						//check if we have reached our patrol target
						while {_unit distance _target < 10} do {
							//assign a new patrol target until we have a valid one
							_target = [ ["land"],[_pos, SQU_HexRadius],[],[0,99999],0,false,500 ] call SQU_RandomMapPos;
						};
						_unit setVariable ["PatrolTarget",_target];
						//advance with patrol
						_unit doMove _target;
						_unit doWatch _target;
						_order setWaypointSpeed "FULL";
						_order setWaypointBehaviour "AWARE";
					}else{
						//assign an abitrary position which depends on our squad member number and squad size
						_target = (_forEachIndex/count(units group _unit))*180 + (getDir _ldr);//watch a half circle direction to our front
						_direc = _pos getPos [SQU_HexRadius, _target];
						//advance with patrol
						_unit doFollow _ldr;
						_unit doWatch _direc;
					};
					//check if we engaged an enemy
					if (_unit findNearestEnemy _pos distance _pos < SQU_HexRadius) then {
						//if so switch to SAD
						_order setWaypointType "SAD";
						_order setWaypointBehaviour "COMBAT";
						//we are no longer on patrol
						SQU_Patrols set [_si, (SQU_Patrols select _si) - 1];
					};
					//TBD: check for units requesting support here
				};
				//we are a garrison... we need to guard our target town
				if (waypointType _order == "GUARD") then {
					_pos = waypointPosition _order;
					//assign an abitrary position which depends on our squad member number and squad size
					_target = (_forEachIndex/count(units group _unit))*360;
					_direc = _pos getPos [SQU_HexRadius, _target];

					if (vehicle _x == _x) then{
						//handle infantry
						_cover = (_unit nearEntities 20) select 0;
						if (_unit distance _cover > sizeOf(typeOf _cover)+10) then {
							//search for statics
							_list = _pos nearObjects ["StaticWeapon", 300];
							_staticWeapons = [];

							/*searching for valid statics*/{
								if ((_x emptyPositions "gunner") > 0) then {
									_staticWeapons pushBack _x;	
									};
							}forEach _list;

							//if we have a static available then prioritze taking it
							if (count _staticWeapons > 0)then{
								_unit assignAsGunner (_staticWeapons select 0);
								[_unit] orderGetIn true;
							}else{
								_movePos = [_pos,_direc] call AI_findCover;
								//our movepos is now a valid position behind cover so we can move to our new cover position
								_unit doMove _movePos;
								_order setWaypointSpeed "FULL";
								_order setWaypointBehaviour "AWARE";
							};
						}else{
							//already in cover
							//be a garrison... cards anyone?
							_x doWatch _direc;
							_order setWaypointBehaviour "AWARE";

							//check if we engaged an enemy so we can hide in a hole
							if (_unit findNearestEnemy _pos distance _pos < SQU_HexRadius) then {
								//if so switch to HOLD
								_order setWaypointType "HOLD";
								_order setWaypointBehaviour "COMBAT";
								//we are no longer in garrison
								(position _order) call SQU_Find_Loc setVariable ["SQU_Garrison", nil]
							};
						};
					}else{
						//currently in a vehicle
						if (position _x distance _pos > SQU_HexRadius) then {
							//we are far from our guard objective
							if (driver vehicle _x == _x) then {
								//we are the driver
								_x doMove _pos;
								_order setWaypointSpeed "FULL";
								_order setWaypointBehaviour "AWARE";
							};
						}else{
							//we are at our objective
							if (!(vehicle _x isKindOf "Plane")) then {
								//we are not in a plane... we can dismount
								unassignVehicle _x;
								doGetOut _x;
							};
						};
					};
				};
				//we are boarding a vehicle
				if (waypointType _order == "GETIN" && !isNil{waypointAttachedVehicle _order}) then {
					_veh = waypointAttachedVehicle _order;
					if (_veh distance _pos < (20 + sizeOf(typeOf(_veh)))) then {
						//just get in the fuckin vehicle already
						[_grp, _veh] call AI_boardVeh;
						//_order setWaypointType "MOVE";
					}else{
						//move along, nothing to see here.
						_unit doMove (position _veh);
					};
				};
				//we are exiting a vehicle
				if (waypointType _order == "GETOUT") then {
					_veh = vehicle _unit;
					if (_veh isKindOf "PLANE") then {
						//we are in a plane
						if ( (waypointPosition _order) distance2D _pos < 100) exitWith {
							[_veh, (units _grp)] execVM "scripts\paradrop.sqf";
							_order setWaypointType "MOVE";
						};
					}else{
						//we are in a land vehicle or boat
						if ( (waypointPosition _order) distance _pos < 100) then {
							//close enough is close enough
							{unassignVehicle _x; doGetOut _x;}forEach (units _grp);
							_order setWaypointType "MOVE";
						};
					};
				};
			};
		}forEach (units _grp);
		sleep 0.1;
	};
};

//this handles the Ai director which orders the squads around
AI_aiComm = {
	_grp = _this;
	_unit = leader _grp;

    if(alive _unit && _unit in (playableUnits+allPlayers+switchableUnits))then{
	    //declares
		_side = side _unit;
		_si = Sides find _side;
	    _pos = getPos _unit;
	    _movePos = _pos;
	    _type = "";//Stores the task type
		_results = [];//generic array to store search results
		_enemyStr = 0;//counter for how strong enemy is in the area
		_ownStr = 0;//counter for how strong we are in the area


		// priority list that we will follow:
		// attack/ambush (SAD/SENTRY)
		// garrison/patrol (GUARD/SUPPORT)
		// take town/territory (MOVE)

		/*find all known units stength*/{
			if (_x != _side)then{
				{
					_cost = _x select 3;
					if ( _cost > 1 )then{
						//increase enemy strength counter
						_enemyStr = _enemyStr + _cost;
					}else{
						//increase friendly strength counter
						_ownStr = _ownStr - _cost;
					};
				} forEach (_unit nearTargets (SQU_capRad));
			};
		} forEach Sides;

		// attack/ambush (SAD/SENTRY)
		//check if we have a target to react to
		_enemy = _unit findNearestEnemy _unit;
		if (_enemyStr > 0 && !isNil("_enemy"))then{
			_movePos = position _enemy;
			//check if we can win the engagement
			if (_enemyStr < _ownStr)then{
				//engage... react aggressively to enemy
				_type = "SAD"
				//no further orders neccesary... unit should cross border to engage them on their lines
			}else{
				//ambush... react defensively to enemy
				_type = "SENTRY";
				//find nearest frontline... this allows us to prioritize statically defending our lines
				_dist = _unit distance _enemy; 
				{
					_pos = locationPosition _x;
					_Tdist = _unit distance _pos;
					if (_Tdist < _dist )then{_movePos = _pos; _dist = _Tdist;};
				}forEach (SQU_Frontlines select _si);
			};
		}else{ 
			// garrison/patrol (GUARD/SUPPORT)
			// first check if we are a valid patrol unit and we dont have too many patrols
			if (vehicle _unit != _unit && !((vehicle _unit) isKindOf "Ship") && ((SQU_Patrols select _si) / (_side countSide allGroups)) < PatrolPerc) then {
				//find the biggest gap in defenses
				_dist = 0;//initializing
				_movePos = selectRandom SQU_Frontlines;//failsafe incase no friendlies along border
				{
					_hex = _x;
					//now find the postition with the furthest friendlies
					{
						if(side _x == _side) exitWith {
							if (_x distance _movePos > _dist) then {
								_movePos = locationPosition _hex;
								_dist = _x distance _movePos;
							};
						};
					} foreach nearestObjects [_movePos,["Man"],SQU_capRad*3];
				}forEach (SQU_Frontlines select _si);
				SQU_Patrols set [_si, (SQU_Patrols select _si) + 1];//increment patrol number
				_type = "SUPPORT";
			}else{
				//is there a friendly ungarrisoned town
				_towns = [SQU_HexagonTownArray,[_pos,_side],{_input0 distance (locationPosition _x)},"ASCEND",{_x getVariable "SQU_HexSide" == _input1 && isNil {_x getVariable "SQU_Garrison"} }] call BIS_fnc_sortBy;
				if (count _towns > 0) then {
					//if so then garrison it
					_movePos = locationPosition (_towns select 0);
					(_towns select 0) setVariable ["SQU_Garrison", _grp];//assign our unit as garrison
					_type = "GUARD";
				}else{
					// take town/territory (MOVE)
					//find what is closest... we need to check all types
					_results = [SQU_HexagonLocArray,[_pos,_side],{_input0 distance (locationposition _x)},"ASCEND",{(_x getVariable "SQU_HexSide") != _input1}] call BIS_fnc_sortBy;
		   	  		//now that we have possible targets we need to first look for territory easily moved towards before performing landing/boarding ops
		   	  		if(count _results > 0) then {
		   	  			//there are still enemy territory to take
						if ((vehicle _unit) isKindOf "Ship") then {    
							//Everybody look at me cause I'm sailin on a boat
							_water = [_results,[_pos],{_x},"ASCEND",{_x getVariable "SQU_HexType" != "LAND" && [_input0,_x,"WATER",[]] call AI_findPath}] call BIS_fnc_sortBy;
				   	  		if (count _water > 0) then {
				   	  			//take water
				   	  			_movePos = locationposition (_water select 0);
				   	  			_type = "MOVE";
				   	  		}else{
				   	  			//Land operation
				   	  			//very narrow search.  find all coastal hexes which can be pathed via water from our position and have a land path to some enemy territory
					   	  		_coast = [SQU_HexagonCoastalArray,[_pos],{_input0 distance (locationposition _x)},"ASCEND",{[_input0,_x,"WATER",[]] call AI_findPath && [_x,"LAND",[]] call AI_pathExists}] call BIS_fnc_sortBy;
				   	  			if (count _coast > 0) then {
					   	  			//we need to find our insertion point
					   	  			_movePos = [_coast select 0, 1, SQU_HexRadius, 3, 2, 20, 1] call BIS_fnc_findSafePos;
					   	  			_type = "GETOUT";//we will disembark
					   	  		}else{
					   	  			//cant find any coastal territory leading to enemy territory... 
					   	  			//we will try to resolve by landing along a random coastal hex
						   	  		_movePos = locationPosition (selectRandom SQU_HexagonCoastalArray);
						   	  		_type = "GETOUT";
					   	  		};
				   	  		};
					   	}else{
					   		//we are on land
							_land = [_results,[_pos],{_x},"ASCEND",{_x getVariable "SQU_HexType" != "WATER" && [_input0,_x,"LAND",[]] call AI_findPath}] call BIS_fnc_sortBy;
				      		if (count _land > 0) then {
				      			//take land
				   	  			_movePos = locationposition (_land select 0);
				   	  			_type = "MOVE";
				   	  		}else{
				   	  			//my kingdom, my kingdom for a BOAT
								{ if (!isPlayer _x) then {
									//unassign and leave any current vehicle
									unassignVehicle _x;
									moveOut _x;
								}; }forEach units _grp;
								//now look for a boat
								_veh = [_grp,"WATER"] call AI_findVeh;
								if (!isNil("_veh"))then{
									//get in vehicle
									_type = "GETIN";
									_movePos = _veh;
								}else{
									//no boats here, definitely no boats.
									//we will randomly patrol along our coast to hopefully find a boat
									_coast = [_land,[_pos],{_x},"ASCEND",{_x getVariable "SQU_HexType" == "COAST" && [_input0,_x,"LAND",[]] call AI_findPath}] call BIS_fnc_sortBy;
									_movePos = selectRandom _coast;
									_type = "MOVE";
								};
				   	  		};
				    	};
		   	  		}else{
		   	  			//we are bored and want orders :(
		   	  			_movePos = locationPosition (selectrandom SQU_HexagonLocArray);
		   	  			_type = "MOVE";
		   	  			//we will randomly patrol our territory
		   	  		};
				};
			};
		};//end of deciding type
		//check if we found a valid order
		//if so we will replace current order with our new one
		if (_type != "") then {
			//assign our given order
			if (isPlayer _unit)then{
				if (typeName _movePos != "ARRAY") then {
					//we are boarding a vehicle
					_movePos = position _movePos;
				}else{
					//we are not boarding a vehicle
					//we are searching for a safe position to allow for mistakes in position
					if (vehicle _unit isKindOf "SHIP") then {
		   	  			_movePos = [_movePos, 1, SQU_HexRadius, 3, 2, 20, 0, [], [_movePos, _movePos]] call BIS_fnc_findSafePos;
					}else{
		   	  			_movePos = [_movePos, 1, SQU_HexRadius, 3, 0, 20, 0, [], [_movePos, _movePos]] call BIS_fnc_findSafePos;
					};
				};
				//assign commander order as a task
				["Commander Order", true] call BIS_fnc_deleteTask;
				[_grp,["Commander Order"],
					["Your commander has issued you an order to "+_type+" in the assigned area.",_type],
					_movePos,1,2,true,"target",true] call BIS_fnc_taskCreate;
			}else{
				//assign order as a waypoint
				{deleteWaypoint [_grp,(_x select 1)];}forEach (waypoints _grp);
				_wp = _grp addWaypoint [_pos, 0];
				_grp setCurrentWaypoint _wp;
				if (typeName _movePos != "ARRAY") then {
					_wp waypointAttachVehicle _movePos;
					_movePos = position _movePos;
				}else{
					//we are not boarding a vehicle
					//we are searching for a safe position to allow for mistakes in position
					if (vehicle _unit isKindOf "SHIP") then {
		   	  			_movePos = [_movePos, 1, SQU_HexRadius, 3, 2, 20, 0, [], [_movePos, _movePos]] call BIS_fnc_findSafePos;
					}else{
		   	  			_movePos = [_movePos, 1, SQU_HexRadius, 3, 0, 20, 0, [], [_movePos, _movePos]] call BIS_fnc_findSafePos;
					};
				};
				_wp setWaypointType _type;
				_wp setWaypointPosition [_movePos, 0];
				_wp setWaypointCombatMode "RED";
				//do internal squad commands if no player squad leader
				[_grp,_wp] spawn AI_squadCom;
			};
		};
	};
};

//loop that actually does our work
while{SQU_GameOn}do{
	_clk = time + 100;
	{/*Looping over all groups*/
		_x spawn AI_aiComm;
	}forEach allGroups;
	waitUntil {sleep 5; time > _clk};
};
/*
while{SQU_GameOn}do{
	[] spawn{
		_snow = [];
		_pos = position player;
		for "_i" from 0 to 1000 do {
			for "_j" from 0 to 1000 do {
				_spos = (_pos)vectorAdd((_pos getPos [(_i-500)*10,0]) getPos [(_j-500)*10,90]);
				_obj = "snow" createVehicle _spos;	
				_obj setPosATL[_spos select 0, _spos select 1, 10];
				_snow = _snow + [_obj];
			};
		};
		sleep 30;
		{deleteVehicle _x}forEach _snow;
	};
};
*/