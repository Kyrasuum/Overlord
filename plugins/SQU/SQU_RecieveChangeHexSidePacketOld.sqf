private ["_chill","_msg","_countLose","_countWin","_winside","_loseSide","_resOwned","_eastOwned","_westOwned","_loc","_name","_westOwnedResourceNames","_eastOwnedResourceNames","_resOwnedResourceNames","_update_info"];

_update_info = _this;

SQU_pvChangeHexSidePacket = [];
_countWin = 0;
_countLose = 0;

{
    if((count _x) == 1)exitwith{//update SQU_SideOwnedTowns from server and exit
        SQU_SideOwnedTownsNames = _x select 0;
    };
        
    _winSide = _x select 0;
    _name = _x select 1;
    _loseSide = _x select 2;
        
    _loc = missionNamespace getVariable _name;
    
    _si = Sides find _winSide;    
    _siL = Sides find _loseSide;    

    _loc setVariable["SQU_HexSide", _winSide];
    SQU_SideOwnedHex set[_si, (SQU_SideOwnedHex select _si) + 1];
    SQU_SideOwnedResourceNames set[_si, (SQU_SideOwnedResourceNames select _si) + [_name]];

    SQU_SideOwnedHex set[_siL, (SQU_SideOwnedHex select _siL) - 1];
    SQU_SideOwnedResourceNames set[_siL, (SQU_SideOwnedResourceNames select _siL) - [_name]];

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

            //repeat for adjacent hexes
            {
                _edge = _x;
                _dir = round(((locationPosition _hex getDir locationPosition _edge)%360) /60)%6;
                if (_edge getVariable "SQU_HexSide" != _hex getVariable "SQU_HexSide" && _edge != _hex)then{
                    (format["%1%2",name _hex,_dir]) setMarkerAlphaLocal 1;
                }else{
                    (format["%1%2",name _hex,_dir]) setMarkerAlphaLocal 0;
                };
                if(!(_loc in SQU_HexagonTownArray))then{
                    (format["%1%2",name _hex,_dir]) setMarkerColorLocal (SQU_HexColors select (Sides find (_hex getVariable "SQU_HexSide") ) );
                }else{
                    (format["%1%2",name _hex,_dir]) setMarkerColorLocal (SQU_HexBaseColors select (Sides find (_hex getVariable "SQU_HexSide") ) );
                };
            } forEach nearestLocations [locationPosition _hex, ["NameVillage"], SQU_capRad]; 
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

    //update count for player notification
    if(!isDedicated) then
    {  
        if (_winSide == playerSide) then {
            _countWin = _countWin + 1;
        };
        if (_loseSide == playerSide) then {
            _countLose = _countLose + 1;
        };
    };
}forEach _update_info;

if(!isDedicated) then
{   
    _msg = format["You WON %1 hexagons and LOST %2.",_countWin,_countLose];
    if((_countWin > 0) || (_countLose > 0)) then{[_msg,-1,-1,10]spawn BIS_fnc_dynamicText;};
};