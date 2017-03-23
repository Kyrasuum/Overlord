// by ALIAS
_artPos  = _this select 0;
_range_art = 300;
_dire	= [random _range_art*-1,random _range_art*1] call BIS_fnc_selectRandom;
_xx 	= (_artPos select 0)+_dire;
_dire	= [random _range_art*-1,random _range_art*1] call BIS_fnc_selectRandom;
_yy 	= (_artPos select 1)+_dire;
_pos= [_xx, _yy, 0];

_intens_li = 500+random 500;

_li_art = "#lightpoint" createVehicleLocal _pos;
_li_art setLightAttenuation [/*start*/ 2000, /*constant*/50+random 100, /*linear*/ 50, /*quadratic*/ 0, /*hardlimitstart*/random 5,2000];  
_li_art setLightIntensity _intens_li;
_li_art setLightDayLight true;	
_li_art setLightUseFlare true;
_li_art setLightFlareSize 30;
_li_art setLightFlareMaxDistance 2000;	
_li_art setLightAmbient[1, 0.5, 0];
_li_art setLightColor[1, 0.5, 0];
_li_art say3d "expozie";

_fum = "#particlesource" createVehicleLocal _pos;
_fum setParticleCircle [0, [0, 0, 0]];
_fum setParticleRandom [0, [0, 0, 0], [0, 0, 0], 0, 0, [0, 0, 0, 0], 0, 0];
_fum setParticleParams [["\A3\data_f\cl_basic", 1, 0, 1], "", "Billboard", 1, 7, [0, 0, 0], [0, 0, 1], 30, 0.01, 0.007, 0, [10,30,40], [[1, 1, 1, 1], [0, 0, 0, 0.5], [.5, .5, .5, 0]], [0.08], 1, 0, "", "", _li_art];
_fum setDropInterval 0.05;
_fum say3d "expozie";	

while {_intens_li>0} do {
	_li_art setLightIntensity _intens_li;
	_intens_li = _intens_li-10;
	sleep 0.01;
};

deleteVehicle _fum;
deleteVehicle _li_art;