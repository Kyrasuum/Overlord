if !(hasInterface) exitWith {};
[] spawn {
	while {true} do {
		_nearUnits = getposASL player nearEntities ["CAManBase", 75];
		if (count _nearUnits > 0) then {
			{
				_unit = _x;
				[_unit] spawn {
					private ["_unit"];
					_unit = _this select 0;
					if !(_unit isEqualTo (vehicle _unit)) exitWith {};
					_vl = velocity _unit; 

					_source = "logic" createVehicleLocal (getpos _unit);
					_fog = "#particlesource" createVehicleLocal getpos _source;
					_fog setParticleParams [["\A3\data_f\ParticleEffects\Universal\Universal", 16, 12, 13,0],
						"", "Billboard", 1, 0.75, [0,0,0], [_vl select 0,(_vl select 1) + 0.2,(_vl select 2) - 0.2],  
						1, 1.275, 1, 0.2, [0, 0.2,0], [[0.5,0.5,0.5, 0], [0.5,0.5,0.5, 0.01]], [100], 1, 0.04, "", "", _source];
					_fog setParticleRandom [0.5, [0, 0, 0], [0.25, 0.25, 0.25], 0, 0.5, [0, 0, 0, 0.1], 0, 0, 10];
					_fog setDropInterval 0.001;

					_source attachto [_unit,[0,0.15,0], "neck"];
					sleep 0.5;
					deletevehicle _source;
				};
			} forEach _nearUnits;
		};
		playSound (["rafala_1","rafala_2","rafala_4_dr","rafala_5_st","rafala_6","rafala_7","rafala_8","rafala_9"] call BIS_fnc_selectRandom);
		sleep 10;
	};
};