#include "plank_macros.h"
if (isDedicated) exitWith {};
waitUntil {
    !isNil{BIS_fnc_init} && {BIS_fnc_init};
};
plankDir = "plugins\plank\";
// These are the available fortifications. Add or take as you wish.
// Action text      - The text displayed by the action.
// Classname        - The classname of the object to be placed.
// Distance         - Minimum distance of the object from the player, in metres.
// Direction        - Direction the object will be rotated initially, in degrees (minimum 0, maximum 360).
// Direction range  - The range you can turn the object, in degrees (minimum 0, maximum 360).
//                    This means that the player will be able to set the direction of the object between `direction - direction_range / 2` and `direction + direction_range / 2` degrees.
//                    For example given 180 direction and 60 direction range, player will be able turn the object between 150 and 210 degrees.
// Code             - A piece of code that will be executed when the object placement is confirmed.
//                    Set it to {}, if you don't want to use it. The unit who confirmed the placement and the object placed, are passed as arguments to the code.
//                    An example code that hints the players name could look like {hint str (_this select 0);}.
plank_deploy_fortData = [
// Action text                      |  Classname                            |  Distance     |  Direction     |  Direction Range  |  Code
//--------------------------------------------------------------------------------------------------------------------------------------
["Sandbag fence",                       "Land_BagFence_Long_F",                 4,              0,                  360,            {}],
["Razor Wire",                          "Land_Razorwire_F",                     6,              0,                  360,            {}]
];
plank_deploy_fnc_setFortDirection = {
    FUN_ARGS_3(_unit,_fort,_fortIndex);

    private "_direction";
    _direction = _unit getVariable ["plank_deploy_fortDirection", GET_FORT_DIRECTION(_fortIndex)];
    _fort setDir ((getDir _unit) + _direction);
};

plank_deploy_fnc_setFortPosition = {
    FUN_ARGS_2(_unit,_fort);

    private ["_heightMode", "_newPostion"];
    _heightMode = _unit getVariable ["plank_deploy_heightMode", RELATIVE_TO_UNIT];
    _newPostion = _unit modelToWorld [0, [_unit] call plank_deploy_fnc_getFortDistance, 0];
    call {
        if (_heightMode == RELATIVE_TO_TERRAIN) exitWith {
            _newPostion set [2, 0];
            _fort setPos _newPostion;
        };
        if (_heightMode == RELATIVE_TO_UNIT) exitWith {
            _newPostion set [2, ((getPosASL _unit) select 2) + (_unit getVariable ["plank_deploy_fortRelativeHeight", 0])];
            _fort setPosASL _newPostion;
        };
    };
};

plank_deploy_fnc_setFortVariables = {
    FUN_ARGS_7(_fortIndex,_fort,_relativeHeight,_direction,_distance,_pitch,_bank);
    
    _unit setVariable ["plank_deploy_fortIndex", _fortIndex, false];
    _unit setVariable ["plank_deploy_fort", _fort, false];
    _unit setVariable ["plank_deploy_fortRelativeHeight", _relativeHeight, false];
    _unit setVariable ["plank_deploy_fortDirection", _direction, false];
    _unit setVariable ["plank_deploy_fortDistance", _distance, false];
    _unit setVariable ["plank_deploy_fortPitch", _pitch, false];
    _unit setVariable ["plank_deploy_fortBank", _bank, false];
};

plank_deploy_fnc_setFortPitchAndBank = {
    FUN_ARGS_2(_unit,_fort);

    [_fort, _unit getVariable ["plank_deploy_fortPitch", 0], _unit getVariable ["plank_deploy_fortBank", 0]] call BIS_fnc_setPitchBank;
};

plank_deploy_fnc_getFortDistance = {
    FUN_ARGS_1(_unit);

    _unit getVariable ["plank_deploy_fortDistance", GET_FORT_DISTANCE((_unit getVariable "plank_deploy_fortIndex"))];
};

plank_deploy_fnc_createFortification = {
    FUN_ARGS_2(_unit,_fortIndex);

    private "_fort";
    _fort = createVehicle [GET_FORT_CLASS_NAME(_fortIndex), [0,0,0], [], 0, "NONE"];
    [_fortIndex, _fort, 0, GET_FORT_DIRECTION(_fortIndex), GET_FORT_DISTANCE(_fortIndex), 0, 0] call plank_deploy_fnc_setFortVariables;
    [_unit, _fort, _fortIndex] call plank_deploy_fnc_setFortDirection;
    [_unit, _fort] call plank_deploy_fnc_setFortPosition;

    _fort;
};

plank_deploy_fnc_addPlacementActions = {
    FUN_ARGS_1(_unit);

    private ["_confirmActionId", "_cancelActionId", "_openActionId"];
    _confirmActionId = _unit addAction ['<t color="#3748E3">Confirm Deployment</t>', plankDir+"confirm_fort_action.sqf", [], 100, false, false, "", "driver _target == _this"];
    _cancelActionId = _unit addAction ['<t color="#FF0000">Cancel Deployment</t>', plankDir+"cancel_fort_action.sqf", [], 99, false, false, "", "driver _target == _this"];
    _openActionId = _unit addAction ['<t color="#00FF00">Open Settings</t>', plankDir+"open_settings_action.sqf", [], 98, false, false, "", "driver _target == _this"];
    _unit setVariable ["plank_deploy_confirmActionId", _confirmActionId, false];
    _unit setVariable ["plank_deploy_cancelActionId", _cancelActionId, false];
    _unit setVariable ["plank_deploy_openActionId", _openActionId, false];
};

plank_deploy_fnc_removePlacementActions = {
    FUN_ARGS_1(_unit);

    private "_actionIdNames";
    _actionIdNames = ["plank_deploy_confirmActionId", "plank_deploy_cancelActionId", "plank_deploy_openActionId"];
    {
        private "_actionId";
        _actionId = _unit getVariable _x;
        if (!isNil {_actionId}) then {
            _unit removeAction _actionId;
        };
    } foreach _actionIdNames;
};

plank_deploy_fnc_updateFortPlacement = {
    FUN_ARGS_1(_unit);

    waitUntil {
        private ["_fort", "_fortIndex"];
        _fort = _unit getVariable "plank_deploy_fort";
        _fortIndex = _unit getVariable "plank_deploy_fortIndex";
        if (!isNil {_fort} && {!isNil {_fortIndex}}) then {
            [_unit, _fort, _fortIndex] call plank_deploy_fnc_setFortDirection;
            [_unit, _fort] call plank_deploy_fnc_setFortPosition;
            [_unit, _fort] call plank_deploy_fnc_setFortPitchAndBank;
        };

        _unit getVariable ["plank_deploy_placementState", STATE_PLACEMENT_INIT] != STATE_PLACEMENT_IN_PROGRESS;
    };
};

plank_deploy_fnc_startFortPlacement = {
    FUN_ARGS_3(_unit,_actionId,_fortIndex);

    if ((_unit getVariable ["plank_deploy_placementState", STATE_PLACEMENT_INIT]) != STATE_PLACEMENT_IN_PROGRESS) then {
        _unit removeAction _actionId;
        _unit setVariable ["plank_deploy_heightMode", RELATIVE_TO_UNIT, false];
        _unit setVariable ["plank_deploy_placementState", STATE_PLACEMENT_IN_PROGRESS, false];
        [_unit, _fortIndex] call plank_deploy_fnc_createFortification;
        [_unit] call plank_deploy_fnc_addPlacementActions;
        [_unit] spawn plank_deploy_fnc_updateFortPlacement;
    };
};

plank_deploy_fnc_deleteFort = {
    FUN_ARGS_1(_unit);

    deleteVehicle (_unit getVariable "plank_deploy_fort");
    [_unit] call plank_deploy_fnc_resetFort;
};

plank_deploy_fnc_resetFort = {
    FUN_ARGS_1(_unit);

    _unit setVariable ["plank_deploy_fortIndex", -1, false];
    private "_variableNames";
    _variableNames = ["plank_deploy_fort", "plank_deploy_fortRelativeHeight", "plank_deploy_fortRelativeHeight",
        "plank_deploy_fortDirection", "plank_deploy_fortDistance", "plank_deploy_fortPitch",
        "plank_deploy_fortBank", "plank_deploy_heightMode"
    ];
    {
        _unit setVariable [_x, nil, false];
    } foreach _variableNames;
};

plank_deploy_fnc_reAddFortificationAction = {
    FUN_ARGS_2(_unit,_resetFunc);

    private ["_fortIndex", "_fortCounts"];
    _fortIndex = _unit getVariable ["plank_deploy_fortIndex", -1];
    _fortCounts = _unit getVariable ["plank_deploy_fortCounts", []];
    [_unit] call _resetFunc;
    [_unit, _fortCounts select _fortIndex, _fortIndex] call plank_deploy_fnc_addFortificationAction;
};

plank_deploy_fnc_cancelFortPlacement = {
    FUN_ARGS_1(_unit);

    _unit setVariable ["plank_deploy_placementState", STATE_PLACEMENT_CANCELLED, false];
    [_unit] call plank_deploy_fnc_removePlacementActions;
    [_unit, plank_deploy_fnc_deleteFort] call plank_deploy_fnc_reAddFortificationAction;
};

plank_deploy_fnc_decreaseFortCount = {
    FUN_ARGS_1(_unit);

    private ["_fortIndex", "_fortCounts"];
    _fortIndex = _unit getVariable ["plank_deploy_fortIndex", -1];
    _fortCounts = _unit getVariable ["plank_deploy_fortCounts", []];
    if (_fortIndex != -1 && {count _fortCounts >= _fortIndex}) then {
        _fortCounts set [_fortIndex, (_fortCounts select _fortIndex) - 1];
    };
};

plank_deploy_fnc_confirmFortPlacement = {
    FUN_ARGS_1(_unit);

    _unit setVariable ["plank_deploy_placementState", STATE_PLACEMENT_DONE, false];
    [_unit] call plank_deploy_fnc_removePlacementActions;
    [_unit] call plank_deploy_fnc_decreaseFortCount;
    [_unit, _unit getVariable "plank_deploy_fort"] call GET_FORT_CODE((_unit getVariable "plank_deploy_fortIndex"));
    [_unit, plank_deploy_fnc_resetFort] call plank_deploy_fnc_reAddFortificationAction;
};

plank_deploy_fnc_addFortificationAction = {
    FUN_ARGS_3(_unit,_count,_fortIndex);

    plankDir = "plugins\plank\";

    if (_count > 0 && {_unit getVariable ["plank_deploy_fortIndex", -1] != _fortIndex}) then {
        _unit addAction [format ["Place %1 (%2 left)", GET_FORT_DISPLAY_NAME(_fortIndex), _count], plankDir+"place_fort_action.sqf", [_fortIndex], _fortIndex + 50, false, false, "", "driver _target == _this"];
    };
};

plank_deploy_fnc_addFortificationActions = {
    FUN_ARGS_1(_unit);

    {
        [_unit, _x, _forEachIndex] call plank_deploy_fnc_addFortificationAction;
    } foreach (_unit getVariable ["plank_deploy_fortCounts", []]);
};

plank_deploy_fnc_initUnitVariables = {
    FUN_ARGS_2(_unit,_fortifications);

    _unit setVariable ["plank_deploy_fortCounts", _fortifications, false];
    [_unit] call plank_deploy_fnc_resetFort;
};

plank_deploy_fnc_init = {
    FUN_ARGS_2(_unit,_fortifications);

    [_unit, _fortifications] call plank_deploy_fnc_initUnitVariables;
    [_unit] call plank_deploy_fnc_addFortificationActions;
};
plank_ui_fnc_createSettingsDialog = {
    if (!dialog) then {
        private "_isDialogCreated";
        _isDialogCreated = createDialog "PlankSettingsDialog";
        if (_isDialogCreated) then {
            [] call plank_ui_fnc_initDialog;
        };
    };
};

plank_ui_fnc_resetHeightSlider = {
    sliderSetPosition [SETTINGS_HEIGHT_SLIDER_IDC, 0];
    [0] call plank_ui_fnc_updateHeightSliderValue;
};

plank_ui_fnc_resetDirectionSlider = {
    private "_fortDirection";
    _fortDirection = GET_FORT_DIRECTION((player getVariable "plank_deploy_fortIndex"));
    sliderSetPosition [SETTINGS_DIRECTION_SLIDER_IDC, _fortDirection];
    [_fortDirection] call plank_ui_fnc_updateDirectiontSliderValue;
};

plank_ui_fnc_resetDistanceSlider = {
    private "_fortDistance";
    _fortDistance = GET_FORT_DISTANCE((player getVariable "plank_deploy_fortIndex"));
    sliderSetPosition [SETTINGS_DISTANCE_SLIDER_IDC, _fortDistance];
    [_fortDistance] call plank_ui_fnc_updateDistanceSliderValue;
};

plank_ui_fnc_resetPitchSlider = {
    sliderSetPosition [SETTINGS_PITCH_SLIDER_IDC, 0];
    [0] call plank_ui_fnc_updatePitchSliderValue;
};

plank_ui_fnc_resetBankSlider = {
    sliderSetPosition [SETTINGS_BANK_SLIDER_IDC, 0];
    [0] call plank_ui_fnc_updateBankSliderValue;
};

plank_ui_fnc_heightModeButtonClick = {
    private "_heightMode";
    _heightMode = player getVariable ["plank_deploy_heightMode", RELATIVE_TO_UNIT];
    call {
        if (_heightMode == RELATIVE_TO_TERRAIN) exitWith {
            _heightMode = RELATIVE_TO_UNIT;
        };
        if (_heightMode == RELATIVE_TO_UNIT) exitWith {
            _heightMode = RELATIVE_TO_TERRAIN;
        };
    };
    [_heightMode] call plank_ui_fnc_setHeightModeButton;
};

plank_ui_fnc_updateHeightSliderValue = {
    FUN_ARGS_1(_value);

    [SETTINGS_HEIGHT_VALUE_IDC, "plank_deploy_fortRelativeHeight",_value] call plank_ui_fnc_updateSliderValue;
};

plank_ui_fnc_updateDirectiontSliderValue = {
    FUN_ARGS_1(_value);

    [SETTINGS_DIRECTION_VALUE_IDC, "plank_deploy_fortDirection", _value] call plank_ui_fnc_updateSliderValue;
};

plank_ui_fnc_updateDistanceSliderValue = {
    FUN_ARGS_1(_value);

    [SETTINGS_DISTANCE_VALUE_IDC, "plank_deploy_fortDistance", _value] call plank_ui_fnc_updateSliderValue;
};

plank_ui_fnc_updatePitchSliderValue = {
    FUN_ARGS_1(_value);

    [SETTINGS_PITCH_VALUE_IDC, "plank_deploy_fortPitch", _value] call plank_ui_fnc_updateSliderValue;
};

plank_ui_fnc_updateBankSliderValue = {
    FUN_ARGS_1(_value);

    [SETTINGS_BANK_VALUE_IDC, "plank_deploy_fortBank", _value] call plank_ui_fnc_updateSliderValue;
};

plank_ui_fnc_updateSliderValue = {
    FUN_ARGS_3(_idc,_varName,_value);

    ctrlSetText [_idc, str _value];
    player setVariable [_varName, _value, false]
};

plank_ui_fnc_initSliders = {
    sliderSetRange [SETTINGS_HEIGHT_SLIDER_IDC, MIN_HEIGHT, MAX_HEIGHT];
    sliderSetRange [
        SETTINGS_DIRECTION_SLIDER_IDC,
        GET_FORT_DIRECTION((player getVariable "plank_deploy_fortIndex")) - GET_FORT_DIRECTION_RANGE((player getVariable "plank_deploy_fortIndex")) / 2,
        GET_FORT_DIRECTION((player getVariable "plank_deploy_fortIndex")) + GET_FORT_DIRECTION_RANGE((player getVariable "plank_deploy_fortIndex")) / 2
    ];
    sliderSetRange [SETTINGS_DISTANCE_SLIDER_IDC, GET_FORT_DISTANCE((player getVariable "plank_deploy_fortIndex")), GET_FORT_DISTANCE((player getVariable "plank_deploy_fortIndex")) + MAX_DISTANCE_ADD];
    sliderSetRange [SETTINGS_PITCH_SLIDER_IDC, MIN_PITCH, MAX_PITCH];
    sliderSetRange [SETTINGS_BANK_SLIDER_IDC, MIN_BANK, MAX_BANK];
};

plank_ui_fnc_initSliderValues = {
    sliderSetPosition [SETTINGS_HEIGHT_SLIDER_IDC, player getVariable ["plank_deploy_fortRelativeHeight", 0]];
    sliderSetPosition [SETTINGS_DIRECTION_SLIDER_IDC, player getVariable ["plank_deploy_fortDirection", GET_FORT_DIRECTION((player getVariable "plank_deploy_fortIndex"))]];
    sliderSetPosition [SETTINGS_DISTANCE_SLIDER_IDC, player getVariable ["plank_deploy_fortDistance", GET_FORT_DISTANCE((player getVariable "plank_deploy_fortIndex"))]];
    sliderSetPosition [SETTINGS_PITCH_SLIDER_IDC, player getVariable ["plank_deploy_fortPitch", 0]];
    sliderSetPosition [SETTINGS_BANK_SLIDER_IDC, player getVariable ["plank_deploy_fortBank", 0]];
};

plank_ui_fnc_initSliderTextValues = {
    ctrlSetText [SETTINGS_HEIGHT_VALUE_IDC, str (player getVariable ["plank_deploy_fortRelativeHeight", 0])];
    ctrlSetText [SETTINGS_DIRECTION_VALUE_IDC, str (player getVariable ["plank_deploy_fortDirection", GET_FORT_DIRECTION((player getVariable "plank_deploy_fortIndex"))])];
    ctrlSetText [SETTINGS_DISTANCE_VALUE_IDC, str (player getVariable ["plank_deploy_fortDistance", GET_FORT_DISTANCE((player getVariable "plank_deploy_fortIndex"))])];
    ctrlSetText [SETTINGS_PITCH_VALUE_IDC, str (player getVariable ["plank_deploy_fortPitch", 0])];
    ctrlSetText [SETTINGS_BANK_VALUE_IDC, str (player getVariable ["plank_deploy_fortBank", 0])];
};

plank_ui_fnc_setHeightModeButton = {
    FUN_ARGS_1(_heightMode);

    player setVariable ["plank_deploy_heightMode", _heightMode, false];
    ctrlSetText [SETTINGS_HEIGHT_MODE_BUTTON_IDC, STR_HEIGHT_MODES select _heightMode];
};

plank_ui_fnc_initDialog = {
    [] call plank_ui_fnc_initSliders;
    [] call plank_ui_fnc_initSliderValues;
    [] call plank_ui_fnc_initSliderTextValues;
    [player getVariable ["plank_deploy_heightMode", RELATIVE_TO_UNIT]] call plank_ui_fnc_setHeightModeButton;
};