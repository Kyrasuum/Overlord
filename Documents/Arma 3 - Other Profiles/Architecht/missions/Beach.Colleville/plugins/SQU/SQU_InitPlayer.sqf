SQU_Init_JIP_Player = compile preprocessFileLineNumbers "plugins\SQU\SQU_Init_JIP_Player.sqf";
if(SQU_didJIP)then
{
	waitUntil{(count SQU_id) == 1};
	publicVariableServer "SQU_id";
	SQU_id = [];
	waitUntil{(count SQU_id) > 1};

	SQU_Base = SQU_id select 0;
	SQU_SideOwnedResourceNames = SQU_id select 1;
	SQU_SideOwnedHex = SQU_id select 2;
	SQU_SideOwnedTownsNames = SQU_id select 3;
};
if(SQU_didJIP)then{[]call SQU_Init_JIP_Player};
SQU_ClientDone = true;