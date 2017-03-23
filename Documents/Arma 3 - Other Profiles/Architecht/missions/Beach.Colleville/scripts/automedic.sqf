_medic = _this;//Our medic unit
_injured = objNull;
_maxSearchUnitDistance	= 100;

//main loop
while {alive _medic} do {
	if (lifeState _medic != "INCAPACITATED") then {
		//heal medic
		if (damage _medic > 0.1) then {
			_injured = _medic;
		} else {
			{
				if ((damage _x > 0.1 || lifeState _x == "INCAPACITATED") && alive _x) then {			
					_injured = _x;
				};
				sleep 1;
			} forEach (_medic nearEntities ["Man", _maxSearchUnitDistance]);
		};

		//we have an injured
		if (!isNull _injured) then {
			//we have an injured, stop him
			if (!isPlayer _injured) then {
				_injured disableAI "MOVE";
				_injured setUnitPos "down";
			};
			//medic go for him
			_medic doMove (position _injured);
			while {_medic distance _injured > 3} do {		
				sleep 1;
				_medic doMove (position _injured);
			};
			//when medic is close enough to the injured...
			//...and injured is still alive
			//stop the medic
			_medic disableAI "MOVE";
			_medic setUnitPos "middle";
			//HEAL the injured
			// ******************************
			[ _medic, _injured ] remoteExec [ "Lar_fnc_wake", 2 ];
			// ******************************
			//healed soldier is ready to fight
			_injured enableAI "MOVE";
			_injured setUnitPos "auto";

			//we are ready for looking a new injured
			_injured = objNull;
			//set the medic to ready to looking for a new injured
			_medic enableAI "MOVE";
			_medic setUnitPos "auto";
			//doMove stops the medic, so we have to command him to follow his leader
			_medic doFollow (leader group _medic);
		};
	};
	sleep 10;
};