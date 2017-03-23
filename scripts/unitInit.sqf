_initUnit = {
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
		}],"BIS_fnc_spawn", (_this select 0),false,true] call BIS_fnc_MP;}];
	//suppression
	_this addeventhandler ["FiredNear",{
		[[ _this,{
			_this spawn {_unit = _this select 0;
			_ammo = _this select 6;
			_cost = getNumber (configFile >> "CfgAmmo" >> _ammo >> "hit");
			if (isnil("_cost")) then {_cost = 1;};

			if (alive _unit) then {
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
			};};
		}],"BIS_fnc_spawn", (_this select 0),false,true] call BIS_fnc_MP;}];

	if (isPlayer _this)then{
		[_this, [missionNamespace, "inventory_var"]] call BIS_fnc_loadInventory;
	}else{
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
	};
	_this setVariable ["Suppression", 0];//suppression init
	_this setVariable ["Logistic", LogisticStart];//logistic init
	_this unassignItem "FirstAidKit";
	_this removeItems "FirstAidKit";
	_this unassignItem "Medikit";
	_this removeItems "Medikit";
	_this enableStamina false;
};

//Initializes and sets up all units with our event handlers/variables
{
	_x spawn _initUnit;
	//run this everytime this unit respawns
	_x addEventHandler ["Respawn", {
		_x spawn _initUnit;
	}];
	_x addEventHandler ["Killed",{
		_unit = _this select 0;
		_side = _unit call findFaction;
		if (!isNil("_side")) then {
			_tickets = [_side] call BIS_fnc_respawnTickets;
			if (_tickets > 0) then {
				if (isPlayer _unit) then {[_unit, [missionNamespace, "inventory_var"]] call BIS_fnc_saveInventory;};
				[_side, -1] call BIS_fnc_respawnTickets;
			}else{
				if (isPlayer _unit) then {
					//we are a player... make us into a spectator
					setPlayerRespawnTime 9999;
					RscSpectator_allowFreeCam = true;
					RscSpectator_hints = [true,true,true];
					_layer = ["specator_layer"] call BIS_fnc_rscLayer;
					_layer cutrsc ["RscSpectator","plain"];
				}else{
					//disable unit once spawned
					waitUntil {sleep 5; alive _unit};
					_pos = position _unit;
					_unit setPos [0,0,-1000];//hopefully hiding the unit
					_unit enableSimulation false;
					//now wait until we can 'spawn'
					waitUntil {sleep 20; [_side] call BIS_fnc_respawnTickets > 0};
					_unit enableSimulation true;
					_unit setPos _pos;
				}
			};
		};
	}];
}forEach (allUnits);