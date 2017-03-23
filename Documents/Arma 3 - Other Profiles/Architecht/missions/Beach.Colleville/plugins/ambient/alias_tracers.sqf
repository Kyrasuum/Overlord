// by ALIAS
_pos = _this select 0;
_ro = 1;_ve = 0;_bl = 0;//color

_dir=0;
_range_trace= 500;

_li_tracer = "#lightpoint" createVehicleLocal [(_pos select 0),_pos select 1,(_pos select 2)+_range_trace+25];
_li_tracer setLightDayLight true;	
_li_tracer setLightUseFlare true;
_li_tracer setLightFlareSize 0;
_li_tracer setLightFlareMaxDistance 2000;	
_li_tracer setLightAmbient[_ro, _ve, _bl];
_li_tracer setLightColor[_ro, _ve, _bl];
_li_tracer say3d "ground_air";	

_li_tracer setLightIntensity 3000+random 500;
_li_tracer setLightAttenuation [/*start*/ 1000, /*constant*/100, /*linear*/ 100, /*quadratic*/ 0, /*hardlimitstart*/5,/* hardlimitend*/1000];  
_dir	= [random 180*-1,random 180*1] call BIS_fnc_selectRandom;
_xx 	= 90+_dir;
_dir	= [random 180*1,random 180*-1] call BIS_fnc_selectRandom;
_yy 	= 90+_dir;

_poc_mic = "#particlesource" createVehicleLocal _pos;		
_poc_mic setParticleCircle [0, [0, 0, 0]];
_poc_mic setParticleRandom [0, [0, 0, 0], [0, 0, 0], 0, 0, [0, 0,0, 0], 0, 0];
_poc_mic setParticleParams [["\A3\data_f\cl_exp", 1, 0, 1], "", "Billboard", 1, 4, [0, 0, 0], [_xx, _yy, 100], 0, 20, 0, 0, [1,1], [[_ro, _ve,_bl, 1],[_ro, _ve, _bl, 1]], [0.08], 1, 0, "", "",_li_tracer];
_poc_mic setDropInterval 0.05;
_poc_mic say3d "ground_air";	
sleep random 1;
deleteVehicle _poc_mic;