if !(hasInterface) exitWith {};
//--- Wind & Dust
[] spawn {
    waituntil {isplayer player};
    setwind [0.201112,0.204166,true];
    while {true} do {
        _obj = vehicle player;
        _pos = position _obj;

        //--- Dust
            setwind [0.201112*2,0.204166*2,false];
        _velocity = [random 10,random 10,-1];
        _color = [1.0, 0.9, 0.8];
        _alpha = 0.02 + random 0.02;
        _ps = "#particlesource" createVehicleLocal _pos;  
        _ps setParticleParams [["\Ca\Data\ParticleEffects\Universal\universal.p3d", 16, 12, 8], "", "Billboard", 1, 3, [0, 0, -6], _velocity, 1, 1.275, 1, 0, [9], [_color + [0], _color + [_alpha], _color + [0]], [1000], 1, 0, "", "", _obj];
        _ps setParticleRandom [3, [30, 30, 0], [0, 0, 0], 1, 0, [0, 0, 0, 0.01], 0, 0];
        _ps setParticleCircle [0.1, [0, 0, 0]];
        _ps setDropInterval 0.01;

        sleep (random 1);
        deletevehicle _ps;
        _delay = 10 + random 20;
        sleep _delay;
    };
};

//--- Ash
[] spawn {
    waituntil {isplayer player};
    _pos = position player;
    _parray = [
    /* 00 */        ["\Ca\Data\ParticleEffects\Universal\Universal", 16, 12, 8, 1],//"\Ca\Data\cl_water",
    /* 01 */        "",
    /* 02 */        "Billboard",
    /* 03 */        1,
    /* 04 */        4,
    /* 05 */        [0,0,0],
    /* 06 */        [0,0,0],
    /* 07 */        1,
    /* 08 */        0.000001,
    /* 09 */        0,
    /* 10 */        1.4,
    /* 11 */        [0.05,0.05],
    /* 12 */        [[0.1,0.1,0.1,1]],
    /* 13 */        [0,1],
    /* 14 */        0.2,
    /* 15 */        1.2,
    /* 16 */        "",
    /* 17 */        "",
    /* 18 */        vehicle player
    ];
    _snow = "#particlesource" createVehicleLocal _pos;  
    _snow setParticleParams _parray;
    _snow setParticleRandom [0, [10, 10, 7], [0, 0, 0], 0, 0.01, [0, 0, 0, 0.1], 0, 0];
    _snow setParticleCircle [0.0, [0, 0, 0]];
    _snow setDropInterval 0.01;

    _oldPlayer = vehicle player;
    while {true} do {
        waituntil {vehicle player != _oldPlayer};
        _parray set [18,vehicle player];
        _snow setParticleParams _parray;
        _oldPlayer = vehicle player;
    };
};

//Breath	
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