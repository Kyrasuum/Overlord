private ["_name","_loc","_sideIndex","_forEachIndex"];
SQU_didJIP = false;
{
	_si = _forEachIndex;
	{
		_name = _x;
		_loc = missionNamespace getVariable _name;
    _loc setVariable["SQU_HexSide",Sides select _si];
    
    //Battlelines style
    if (SQU_MapMode == 2) then {
        //make border lines visible
        _borders = nearestLocations [locationPosition _loc, ["NameVillage"], SQU_capRad];
        {
            _hex = _x;
            
            _dir = round(((locationPosition _loc getDir locationPosition _hex)%360) /60)%6;
            if (_hex getVariable "SQU_HexSide" != _loc getVariable "SQU_HexSide" && _hex != _loc)then{
                (format["%1%2",name _loc,_dir]) setMarkerAlphaLocal 1;
            }else{
                (format["%1%2",name _loc,_dir]) setMarkerAlphaLocal 0;
            };
            if(!(_loc in SQU_HexagonTownArray))then{
                (format["%1%2",name _loc,_dir]) setMarkerColorLocal (SQU_HexColors select (Sides find (_loc getVariable "SQU_HexSide") ) );
            }else{
                (format["%1%2",name _loc,_dir]) setMarkerColorLocal (SQU_HexBaseColors select (Sides find (_loc getVariable "SQU_HexSide") ) );
            };
        } forEach _borders; 
    };
    //Board game style
    //the whole map is known to you
    if (SQU_MapMode == 1) then {
        if(!(_loc in SQU_HexagonTownArray))then
        {
            {(format["%1%2",name _loc,_x]) setMarkerColorLocal (SQU_HexColors select _si)}forEach [0,1,2,3,4,5];
        }else{
            {(format["%1%2",name _loc,_x]) setMarkerColorLocal (SQU_HexBaseColors select _si)}forEach [0,1,2,3,4,5];
        };    
    };
    //Fog of War game style
    //like edge game but you can see your whole territory
    if (SQU_MapMode == 0) then {       
        if (_loseSide == side player || _winside == side player) then {
            if(!(_loc in SQU_HexagonTownArray))then
            {
                {(format["%1%2",name _loc,_x]) setMarkerColorLocal (SQU_HexColors select _si)}forEach [0,1,2,3,4,5];
            }else{
                {(format["%1%2",name _loc,_x]) setMarkerColorLocal (SQU_HexBaseColors select _si)}forEach [0,1,2,3,4,5];
            };
        };
    };
  }forEach _x;
}forEach SQU_SideOwnedResourceNames;