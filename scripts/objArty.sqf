//Creates an arty target centered around the called position with random spread
//this object depends on the amount of arty defined as being alive
_pos = _this select 0;
_side = _this select 1;
[[[_pos],"plugins\ambient\alias_artillery.sqf"],"BIS_fnc_execVM",false,false] spawn BIS_fnc_MP;
{
	_pos spawn {
		_clk = time + 60;
		while{time<_clk}do{
			//"ModuleOrdnanceRocket_F" "ModuleOrdnanceHowitzer_F" "ModuleOrdnanceMortar_F"
			_prjctl = "ModuleOrdnanceMortar_F";
			_origin = (_this vectorAdd [(random 200) - 100, (random 200) - 100, 5000]);
			_bullet = _prjctl createVehicle _origin;
			sleep 2;
		};
	};
	_pos spawn {
		_clk = time + 60;
		while{time<_clk}do{
			_prjctl = "Sh_82mm_AMOS";
			_origin = (_this vectorAdd [(random 200) - 100, (random 200) - 100, 5000]);
			_bullet = _prjctl createVehicle _origin;
			_bullet setVelocity [0,0,-1000];
			sleep 2;
		};
	};
	[_pos,_x] spawn {
		_clk = time + 60;
		_gun = _this select 1;
		_origin = ((_this select 0) vectorAdd [(random 200) - 100, (random 200) - 100, 5000]);
		_gun doWatch _origin;
		while{time<_clk}do{
			sleep 5;
			_gun fire ((weapons _gun) select 0);
			_gun setVehicleAmmoDef 1;
		};
	};
}forEach (ArtyAlive select (Sides find _side));