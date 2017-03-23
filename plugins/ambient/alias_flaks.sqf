// by ALIAS
if (!hasInterface) exitWith {};

_pos	= _this select 0;

_flak_sound = ["bariera_1","bariera_2","bariera_3","bariera_4", "bariera_5"] call BIS_fnc_selectRandom;

_li_aaa = "#lightpoint" createVehicleLocal _pos;
_li_aaa setLightAttenuation [/*start*/ 1000, /*constant*/100, /*linear*/ 100, /*quadratic*/ 0, /*hardlimitstart*/5,/* hardlimitend*/1000];  
_li_aaa setLightIntensity 500+random 500;
_li_aaa setLightDayLight true;	
_li_aaa setLightUseFlare true;
_li_aaa setLightFlareSize 10+random 100;
_li_aaa setLightFlareMaxDistance 2000;	
_li_aaa setLightAmbient[0.9, 0.9, 0.9];
_li_aaa setLightColor[0.9, 0.9, 0.9];
_li_aaa say3D _flak_sound;

_range_aaa = 600;

_direx	= [(50+random _range_aaa)*-1,(50+random _range_aaa)*1] call BIS_fnc_selectRandom;
_xx 	= (_pos select 0)+_direx;
_direx	= [(50+random _range_aaa)*-1,(50+random _range_aaa)*1] call BIS_fnc_selectRandom;
_yy 	= (_pos select 1)+_direx;
_zz 	= (_pos select 2)+ 100+random 300;
_rel_poz = [_xx, _yy, _zz];
_li_aaa setPosATL _rel_poz;
	
_fum = "#particlesource" createVehicleLocal getPosATL _li_aaa;
_fum setParticleCircle [0, [0, 0, 0]];
_fum setParticleRandom [0, [0, 0, 0], [0, 0, 0], 0, 0, [0, 0, 0, 0], 0, 0];
_fum setParticleParams [["\A3\data_f\cl_basic", 1, 0, 1], "", "Billboard", 1, 3, [0, 0, 0], [0, 0, 1], 30, 0.01, 0.007, 0, [5,20,30,40], [[0.6, 0.3, 0.2, 0.5], [0, 0, 0, 0.5], [0, 0, 0, 1], [0, 0, 0, 0]], [0.08], 1, 0, "", "", _li_aaa];
_fum setDropInterval 0.9;
_fum say3D _flak_sound;


sleep 0.1+random 0.2;
deleteVehicle _li_aaa;

_mult = 100/(player distance _li_aaa);
if (_mult >= 0.5) then {
	enableCamShake true;
	addCamShake [0.5 * _mult, 10 * _mult, 35 * _mult];
	sleep 1+random 1;
	enableCamShake false;
};

// _aaa_air_sound  = "land_helipadempty_f" createVehicleLocal _rel_poz;
// _aaa_air_sound say3D _flak_sound;
// sleep 4;
// deleteVehicle _aaa_air_sound;