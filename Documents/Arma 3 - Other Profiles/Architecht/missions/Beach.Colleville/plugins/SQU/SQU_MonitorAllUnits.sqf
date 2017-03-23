//loop for territory contestion
Territory_thread = [] spawn {
	private ["_wLost","_eLost","_goodToCapture","_si","_dispute","_c","_loc","_side","_e","_w","_r","_allOwnedHexagons","_neighbours","_percentW","_percentE","_percentR","_temp"];
	_loc = locationNull;
	//wait until after init
	waitUntil {SQU_GameOn && fnDone};
	//start monitoring while game is active
	while {SQU_GameOn} do {
		//first loop over all units to find what territory is contested
		{
			_unit = _x;
			//must be a 
			if(alive _unit && (side _unit) in Sides) then {	
				//we are going to loop over all territory that meets the criteria
				_si = Sides find (side _unit);
				_locs = nearestLocations [getPos _unit, ["NameVillage"], SQU_capRad];
				if (count _locs > 0)then{
					//check if we can resupply
					if ((_locs select 0) getVariable "SQU_HexSide" == side _unit && _unit getVariable "Logistic" < LogisticMax)then{
						_mag = currentMagazine _unit;
						if ({_x isEqualTo _mag} count magazines _unit < 1) then 
						{ 
							_unit addMagazines [_mag, 1];
						}else{
							_unit setVariable ["Logistic", (_unit getVariable "Logistic")+LogisticSupply];
						};
					};
					//contest territory
					{
						_goodToCapture = true;
						//check if we border this territory...
						if(count (SQU_Base select _si) != 0 && SQU_SideOwnedHex select _si != 0)then{
							_goodToCapture = false;
			  				_allOwnedHexagons = (SQU_SideOwnedResourceNames select _si);
			  				_neighbours = [_x] call SQU_ReturnNeighbours;
			  				{if(_x in _allOwnedHexagons)exitwith{_goodToCapture = true;};}foreach _neighbours;	
		  				};
						//if we are good to go then update hex
			      		if(_goodToCapture)then
			      		{
							_dispute = _x getVariable "SQU_Dispute";						
							if (!isNil "_dispute") then {
								_dispute set[_si, (_dispute select _si) + SQU_capRad/(Position _unit distance _x)];
								_x setVariable["SQU_Dispute", _dispute];						
								if(!(_x in SQU_HexagonsInDispute))then{SQU_HexagonsInDispute = SQU_HexagonsInDispute + [_x]};
							};
			      		};
					}forEach _locs;
				};
			};						
		}forEach allUnits; 

		//now we need to resolve all calculated contestions
		{
			_side = _x getVariable "SQU_HexSide";
			_dispute = _x getVariable "SQU_Dispute";
							
			if (!isNil "_x" && !isNil "_side" && !isNil "_dispute") then {
				//find greatest side
				_max = (_dispute call BIS_fnc_greatestNum);
				_si = (Sides select (_dispute find _max));

				//if different faction is dominant
				if (_si != _side) then {
					[_si, _x, _side] call SQU_ChangeHexSide;
				};

				_temp = [];
				_j = 0;
				while {_j < (count Sides)} do {
					_temp = _temp + [0];
					_j = _j + 1;
				};
				_x setVariable["SQU_Dispute", _temp];	
			};
		}forEach SQU_HexagonsInDispute;	

		SQU_HexagonsInDispute = [];

		//now we need to send the data over the net to update the map
		if((count SQU_pvChangeHexSidePacket) > 0)then
		{
			SQU_pvChangeHexSidePacket = SQU_pvChangeHexSidePacket + [[SQU_SideOwnedTownsNames]];
			publicVariable "SQU_pvChangeHexSidePacket";
			SQU_pvChangeHexSidePacket call SQU_RecieveChangeHexSidePacket;
		};

		//now that the map is updated we can do some territory checks	
		sleep 0.5;
		_changed = SQU_pvChangeHexSidePacket;
		SQU_pvChangeHexSidePacket = [];	

		
		//lose territory that isnt connected
		{
			if (count _x != 3) exitWith{};
			_win = _this select 0;
			_loc = _this select 1;
			_lose = _this select 2;

			_temp = [Sides find _lose,_lose] call SQU_CheckSideBaseNeighbours;
			{[_win, _x, _lose] call SQU_ChangeHexSide} forEach _temp;
		} forEach _changed;	
		
		if((count SQU_pvChangeHexSidePacket) > 0)then
		{
			SQU_pvChangeHexSidePacket = SQU_pvChangeHexSidePacket + [[SQU_SideOwnedTownsNames]];
			publicVariable "SQU_pvChangeHexSidePacket";
			SQU_pvChangeHexSidePacket call SQU_RecieveChangeHexSidePacket;
		};
		
		sleep 0.5;
		SQU_HexagonsInDispute = [];
		SQU_pvChangeHexSidePacket = [];	
		sleep 60;//how often to calculate territory disputes
	};
};