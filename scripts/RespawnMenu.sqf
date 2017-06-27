//this creates a gui for respawning
SQU_openRespawnMenu = { 
	//initialize section
	disableSerialization;
	_side = _this;
	_si = Sides find _side;

	uiNamespace setVariable ["SQU_Respawn_shown", true];
	uiNamespace setVariable ["SQU_RespawnLB", nil];
	uiNamespace setVariable ["SQU_Side", _side];
	_display = findDisplay 46 createDisplay "RscDisplayEmpty";

	_resmap = _display ctrlCreate ["RscMapControl", -1]; 
	_resmap ctrlSetPosition [safezoneX, safezoneY, safezoneW*0.25, safezoneH*0.25]; 
	_resmap ctrlCommit 0; 

	_restip = _display ctrlCreate ["RscText", -1];
	_restip ctrlSetPosition [safezoneX + safezoneW*0.25, safezoneY, safezoneW*0.75, safezoneH*0.05];
	_restip ctrlSetText "Press 'Escape' to hide this menu.  Press 'Enter' to respawn on the selected unit along the left.";
	_restip ctrlCommit 0;

	_resList = _display ctrlCreate ["RscListBox", -1]; 
	_resList ctrlSetPosition [safezoneX, safezoneY + safezoneH*0.25, safezoneW*0.25, safezoneH*0.75]; 
	_resList ctrlSetFont "EtelkaMonospacePro"; 
	_resList ctrlSetFontHeight 0.03; 
	_resList ctrlSetBackgroundColor [0,0,0,1];
	_resList ctrlCommit 0; 
	_resList setVariable ["objects", []];
	_resList lbSetCurSel 1;
	uiNamespace setVariable ["RespawnList",_resList];
	//handle key presses
	_display displayAddEventHandler ["KeyDown",{
			//esc key
			if ((_this select 1) in actionKeys "IngamePause")then{
				//close gui
				uiNamespace setVariable ["SQU_Respawn_shown", false];
				//display tool tip
				["Press the 'Enter' key to bring the respawn menu back up.",-1,0,10]spawn BIS_fnc_dynamicText;
				//allow us to get back
				uiNamespace setVariable ["RespawnHandler",nil];
				_handler = (findDisplay 46) displayAddEventHandler ["KeyDown",{
					if ((_this select 1) == 28)then{
						(uiNamespace getVariable ["SQU_Side", selectrandom Sides]) spawn SQU_openRespawnMenu;
						(findDisplay 46) displayRemoveEventHandler ["KeyDown", uiNamespace getVariable "RespawnHandler"];
					};
				}];
				uiNamespace setVariable ["RespawnHandler",_handler];
			};
			//enter key
			if ((_this select 1) == 28)then{
				//we are exiting with a valid query
				_resList = uiNamespace getVariable "RespawnList";
				_objs = _resList getVariable ["objects", []];
				_sel = lbCurSel _resList;
				_obj = objNull;
				{
					if (_forEachIndex == _sel) then {
						_obj = _x;
					};
				}forEach _objs;
				if (_obj != objNull) then {
					uiNamespace setVariable ["SQU_Respawn_shown", false];
					uiNamespace setVariable ["SQU_RespawnLB", _obj];
				};
			};
		}];
	//update section
	cutText ["","BLACK IN"];//failsafe for singleplayer bug
	while {uiNamespace getVariable ["SQU_Respawn_shown", false]} do {
		_objs = _resList getVariable ["objects", []];
		_sel = lbCurSel _resList;
		if (_sel < 0) then {_sel = 0;};
		_obj = objNull;
		lbClear _resList;
		{
			if (!(_x in _objs))then{
				_objs = _objs + [_x];
			};
		}forEach (allUnits select {side _x == _side});

		{
			if (_forEachIndex == _sel) then {
				_obj = _x;
			};
			if (!alive _x)then{
				_objs = _objs - [_x];
			}else{
				_index = _resList lbAdd (gettext (configfile >> "cfgvehicles" >> typeof _x >> "displayName"));
				_resList lbSetPicture [_index, (gettext (configfile >> "cfgvehicles" >> typeof _x >> "icon") call bis_fnc_textureVehicleIcon)];
			};
		}forEach _objs;
		_resList setVariable ["objects", _objs];
		_resList lbSetCurSel _sel;

		_zoom = 0.05;
		_vec =  [100*safezoneW,-75*safezoneH,0] vectorMultiply ((1-_zoom));
		_resmap ctrlMapAnimAdd [0, _zoom, (position _obj) vectorAdd (_vec)]; 
		ctrlMapAnimCommit _resmap;
		_obj switchCamera "EXTERNAL";

		sleep 0.1; 
	}; 
	//exiting section
	ctrlDelete _resmap;
	ctrlDelete _restip;
	ctrlDelete _resList;
	_display closeDisplay 1;
};