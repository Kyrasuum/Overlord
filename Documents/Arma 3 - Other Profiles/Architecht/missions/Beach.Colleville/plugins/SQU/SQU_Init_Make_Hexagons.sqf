private ["_locNum","_resArray","_hoz","_name","_Location","_pos","_m","_dir","_vert","_Color","_temp","_Percent"];
_resArray = [];
if(isNil{profileNameSpace getVariable "SQU_SavedColors"})then
{
	SQU_HexColors = ["ColorBLUFOR","ColorGUER","ColorOPFOR","ColorCIV"];
	SQU_HexTownColors = ["ColorBLUFOR","ColorGUER","ColorOPFOR","ColorCIV"];
}else{
	SQU_HexColors = ((profileNameSpace getVariable "SQU_SavedColors")select 0);
	SQU_HexTownColors = ((profileNameSpace getVariable "SQU_SavedColors")select 1);
};

_Color = SQU_HexColors select (Sides find _this);
for "_h" from 0 to SQU_HozAmount-1 do //rows
{
	_hoz = SQU_startX + (_h*(SQU_size+SQU_WallThickness)*3);
	_vert = SQU_startY + ((SQU_size * sqrt 3)+SQU_WallThickness)*(_h mod 2);
	for "_v" from 0 to SQU_VerAmount-1 do //columns
	{	
		for "_i" from 0 to 5 do //draw hexagon
		{
			if(_i == 0)then //create center
			{				
				_locNum = _h + (_v * .01);
				_name = format ["%1",_locNum]; 					

				_Location = createLocation ["NameVillage", [_hoz,_vert, 0], 100, 100];
				_Location setName _name;
				_pos = locationPosition _Location;

				_Location setVariable["SQU_HexName", _name];
				_Location setVariable["SQU_HexPos", _pos];				
				_Location setVariable["SQU_HexSide",_this];

				_temp = [];
				_j = 0;
				while {_j < (count Sides)} do {
					_temp = _temp + [0];
					_j = _j + 1;
				};
				_Location setVariable["SQU_Dispute", _temp];
				missionNamespace setVariable[format["%1",_locNum],_Location];
							
				_resArray = _resArray + [_name];
				SQU_HexagonLocArray = SQU_HexagonLocArray + [_Location];
			};

			if(!isDedicated)then
			{
				_m = createMarkerLocal[ format ["%1%2",_locNum,_i],[_hoz,_vert]];
				_m setMarkerShapeLocal "RECTANGLE";
				_m setMarkerSizeLocal [SQU_size, SQU_WallThickness/6];
				_m setMarkerColorLocal _Color;
				if (SQU_MapMode == 2) then {_m setMarkerAlphaLocal 0;};
				_m setMarkerBrushLocal "SOLID";
				_dir = [0,60,300,0,60,300]select _i;
				_m setMarkerDirLocal _dir;
				_m setMarkerPosLocal [ [_hoz,_hoz+(SQU_size*1.5),_hoz+(SQU_size*1.5),_hoz,_hoz-(SQU_size*1.5),_hoz-(SQU_size*1.5)]select _i,
					[_vert+(SQU_size*sqrt 3),_vert+(SQU_size*sqrt 3)/2,_vert-(SQU_size*sqrt 3)/2,_vert-(SQU_size*sqrt 3),_vert-(SQU_size*sqrt 3)/2,_vert+(SQU_size*sqrt 3)/2]select _i,0];
			};
		};
		_vert = _vert + (SQU_size*(sqrt 3)+SQU_WallThickness)*2;
	};
};
_h = round(SQU_HozAmount / 2);
_v = round(SQU_VerAmount / 2);
_v = _v	* .01;
_locNum = _h+_v;
_name = format ["%1",_locNum];

SQU_CenterMapPos = (missionNamespace getVariable _name)getVariable "SQU_HexPos";
SQU_numberOfHex = count SQU_HexagonLocArray;

_Percent = 0;
while{true}do
{
	if(_Percent > SQU_HexWin) exitwith{};
	_Percent = round((SQU_numberOfHexsWin/SQU_numberOfHex)*100);
	SQU_numberOfHexsWin = SQU_numberOfHexsWin + 1;
};
//start all as param
SQU_SideOwnedResourceNames set[(Sides find _this),_resArray];
SQU_SideOwnedHex set[(Sides find _this), SQU_numberOfHex];	

{
	_si = Sides find _x;
	{
		if (_x find (format ["respawn_",SidesTxt select _si]) >= 0) then {
			_loc = (getMarkerPos _x) call SQU_Find_Loc;
			_temp = [_loc getVariable "SQU_HexName", _loc getVariable "SQU_HexPos"];
			SQU_Base set [_si, _temp];
		};
	}forEach allMapMarkers;
}forEach Sides;

if(isServer)then{
	publicVariable "SQU_HexagonLocArray";
	publicVariable "SQU_Base";	
};
SQU_MapFinished = true;